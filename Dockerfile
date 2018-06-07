# This image is based off the latest Jenkins LTS
FROM jenkins/jenkins:lts

# Install common build tools

USER root

# Node/Npm
RUN bash -c "curl -sL https://deb.nodesource.com/setup_8.x | bash -"
RUN apt-get update && apt-get install -y nodejs

# Python/pip
RUN apt-get install -y docker python python-dev python-pip

# Java
# This image based on a openjdk image.  Java already installed.

# Scala/sbt
ENV SBT_VERSION=1.1.6
RUN \
  curl -L -o sbt-$SBT_VERSION.deb http://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion

# Go
RUN wget https://dl.google.com/go/go1.10.2.linux-amd64.tar.gz
RUN tar -xvf go1.10.1.linux-amd64.tar.gz -C /usr/local

# AWS CLI
RUN pip install awscli --upgrade

# Docker
RUN apt-get install -y docker

USER jenkins

RUN install-plugins.sh antisamy-markup-formatter matrix-auth blueocean:$BLUEOCEAN_VERSION

