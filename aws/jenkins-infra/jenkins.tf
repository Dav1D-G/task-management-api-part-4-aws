resource "aws_key_pair" "jenkins" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.jenkins_instance_type
  subnet_id                   = aws_subnet.private[0].id
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name
  key_name                    = aws_key_pair.jenkins.key_name
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    PLATFORM_DIR="/opt/jenkins-platform"

    dnf update -y
    dnf install -y docker git curl-minimal

    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -fsSL -o /usr/local/lib/docker/cli-plugins/docker-compose \
      https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    mkdir -p "$PLATFORM_DIR/agents/ci"
    mkdir -p "$PLATFORM_DIR/agents/docker"
    mkdir -p "$PLATFORM_DIR/agents/infra"

    cat > "$PLATFORM_DIR/docker-compose.yml" <<'YAML'
    services:
      jenkins:
        image: jenkins/jenkins:lts
        container_name: jenkins-part4-local
        restart: unless-stopped
        ports:
          - "8080:8080"
          - "50000:50000"
        volumes:
          - jenkins_home:/var/jenkins_home

      agent_ci:
        build: ./agents/ci
        image: jenkins-agent:ci
        container_name: jenkins-agent-ci
        restart: unless-stopped
        environment:
          - JENKINS_URL=$${JENKINS_URL:-http://jenkins:8080}
          - JENKINS_AGENT_NAME=$${CI_AGENT_NAME:-agent-ci}
          - JENKINS_SECRET=$${CI_AGENT_SECRET}
          - JENKINS_AGENT_WORKDIR=/home/jenkins/agent
        depends_on:
          - jenkins

      agent_docker:
        build: ./agents/docker
        image: jenkins-agent:docker
        container_name: jenkins-agent-docker
        restart: unless-stopped
        user: root
        environment:
          - JENKINS_URL=$${JENKINS_URL:-http://jenkins:8080}
          - JENKINS_AGENT_NAME=$${DOCKER_AGENT_NAME:-agent-docker}
          - JENKINS_SECRET=$${DOCKER_AGENT_SECRET}
          - JENKINS_AGENT_WORKDIR=/home/jenkins/agent
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
        depends_on:
          - jenkins

      agent_infra:
        build: ./agents/infra
        image: jenkins-agent:infra
        container_name: jenkins-agent-infra
        restart: unless-stopped
        environment:
          - JENKINS_URL=$${JENKINS_URL:-http://jenkins:8080}
          - JENKINS_AGENT_NAME=$${INFRA_AGENT_NAME:-agent-infra}
          - JENKINS_SECRET=$${INFRA_AGENT_SECRET}
          - JENKINS_AGENT_WORKDIR=/home/jenkins/agent
        depends_on:
          - jenkins

    volumes:
      jenkins_home:
    YAML

    cat > "$PLATFORM_DIR/.env" <<'ENV'
    JENKINS_URL=http://jenkins:8080

    CI_AGENT_NAME=agent-ci
    CI_AGENT_SECRET=REPLACE_CI_AGENT_SECRET

    DOCKER_AGENT_NAME=agent-docker
    DOCKER_AGENT_SECRET=REPLACE_DOCKER_AGENT_SECRET

    INFRA_AGENT_NAME=agent-infra
    INFRA_AGENT_SECRET=REPLACE_INFRA_AGENT_SECRET
    ENV

    cat > "$PLATFORM_DIR/agents/ci/Dockerfile" <<'DOCKERFILE'
    FROM jenkins/inbound-agent:latest

    USER root
    RUN apt-get update \
      && apt-get install -y --no-install-recommends git nodejs npm ca-certificates curl \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*
    USER jenkins
    DOCKERFILE

    cat > "$PLATFORM_DIR/agents/docker/Dockerfile" <<'DOCKERFILE'
    FROM jenkins/inbound-agent:latest

    USER root
    ARG DOCKER_VERSION=26.1.4
    RUN apt-get update \
      && apt-get install -y --no-install-recommends git nodejs npm ca-certificates curl \
      && curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-$${DOCKER_VERSION}.tgz" \
        | tar -xz -C /usr/local/bin --strip-components=1 docker/docker \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*
    USER jenkins
    DOCKERFILE

    cat > "$PLATFORM_DIR/agents/infra/Dockerfile" <<'DOCKERFILE'
    FROM jenkins/inbound-agent:latest

    USER root
    ARG TERRAFORM_VERSION=1.8.4
    ARG AWSCLI_VERSION=2.31.22
    RUN apt-get update \
      && apt-get install -y --no-install-recommends git curl unzip ca-certificates \
      && curl -fsSL -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip" \
      && unzip /tmp/terraform.zip -d /usr/local/bin \
      && rm -f /tmp/terraform.zip \
      && curl -fsSL -o /tmp/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-$${AWSCLI_VERSION}.zip" \
      && unzip /tmp/awscliv2.zip -d /tmp \
      && /tmp/aws/install \
      && rm -rf /tmp/aws /tmp/awscliv2.zip \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*
    USER jenkins
    DOCKERFILE

    cd "$PLATFORM_DIR"
    docker compose build agent_ci agent_docker agent_infra
    docker compose up -d jenkins
  EOF

  tags = { Name = "${var.name_prefix}-jenkins" }
}

resource "aws_iam_role" "jenkins" {
  name               = "${var.name_prefix}-jenkins-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "jenkins_admin" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.name_prefix}-jenkins-profile"
  role = aws_iam_role.jenkins.name
}
