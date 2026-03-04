FROM jenkins/inbound-agent:latest

USER root
ARG TERRAFORM_VERSION=1.8.4
ARG AWSCLI_VERSION=2.31.22
RUN apt-get update \
  && apt-get install -y --no-install-recommends git curl unzip ca-certificates \
  && curl -fsSL -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && unzip /tmp/terraform.zip -d /usr/local/bin \
  && rm -f /tmp/terraform.zip \
  && curl -fsSL -o /tmp/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" \
  && unzip /tmp/awscliv2.zip -d /tmp \
  && /tmp/aws/install \
  && rm -rf /tmp/aws /tmp/awscliv2.zip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER jenkins
