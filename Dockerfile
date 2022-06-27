# This image is based off the latest Jenkins LTS
FROM jenkins/jenkins:lts

# Install common build tools

USER root

# Node/Npm
RUN bash -c "curl -sL https://deb.nodesource.com/setup_14.x | bash -"
RUN apt-get update && apt-get install -y nodejs

# Python/pip, and wget
RUN apt-get install -y python3 python3-dev python3-pip wget

# Java
# This image based on a openjdk image.  Java already installed.

# Scala/sbt
COPY install-sbt.sh /tmp/install-sbt.sh
ENV SBT_VERSION=1.6.2
RUN \
  sh /tmp/install-sbt.sh "${SBT_VERSION}" && \
  sbt sbtVersion -Dsbt.rootdir=true && \
  rm /tmp/install-sbt.sh

# Go
RUN wget https://dl.google.com/go/go1.15.1.linux-amd64.tar.gz
RUN tar -xvf go1.15.1.linux-amd64.tar.gz -C /usr/local

# AWS CLI
RUN pip install awscli --upgrade

# Docker
RUN apt-get install -y apt-transport-https ca-certificates software-properties-common
RUN sh -c "curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -"
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update && apt-get install -y docker-ce 

# Docker Compose
RUN \
  curl -L "https://github.com/docker/compose/releases/download/2.3.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose

# Other Utils
RUN apt-get install -y zip jq gettext

USER jenkins

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Duser.timezone=America/New_York"

RUN java -jar jenkins-plugin-manager.jar --plugins antisamy-markup-formatter matrix-auth blueocean --verbose

