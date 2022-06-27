# This image is based off the latest Jenkins LTS
FROM jenkins/jenkins:lts

# Install common build tools

USER root

# Node/Npm
RUN bash -c "curl -sL https://deb.nodesource.com/setup_14.x | bash -"
RUN apt-get update && apt-get install -y nodejs

# Python/pip
RUN apt-get install -y python3 python3-dev python3-pip

# Java
# This image based on a openjdk image.  Java already installed.

# Scala/sbt
# SBT versions here: https://scala.jfrog.io/ui/native/debian/
COPY install-sbt.sh /tmp/install-sbt.sh
ENV SBT_VERSION=1.6.2
RUN \
  sh /tmp/install-sbt.sh && \
  sbt sbtVersion \
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
  curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose

# MySQL Client
ENV MYSQL_VERSION=0.8.16-1
RUN \
  curl -L -o mysql-apt-config_${MYSQL_VERSION}_all.deb https://dev.mysql.com/get/mysql-apt-config_${MYSQL_VERSION}_all.deb
RUN \
  echo 4 | dpkg -i mysql-apt-config_${MYSQL_VERSION}_all.deb
RUN \
  rm mysql-apt-config_${MYSQL_VERSION}_all.deb && \
  apt-get update && \
  apt-get install -y mysql-client
  
# Other Utils
RUN apt-get install -y zip jq gettext

USER jenkins

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Duser.timezone=America/New_York"

RUN install-plugins.sh antisamy-markup-formatter matrix-auth blueocean:$BLUEOCEAN_VERSION

