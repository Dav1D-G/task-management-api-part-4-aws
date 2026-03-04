FROM jenkins/inbound-agent:latest

USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends git nodejs npm ca-certificates curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER jenkins
