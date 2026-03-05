FROM jenkins/inbound-agent:latest

USER root
ARG DOCKER_VERSION=26.1.4
RUN apt-get update \
  && apt-get install -y --no-install-recommends git nodejs npm ca-certificates curl awscli \
  && curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
    | tar -xz -C /usr/local/bin --strip-components=1 docker/docker \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER jenkins
