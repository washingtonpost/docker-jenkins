# This image is based off the latest Jenkins LTS
FROM jenkins/jenkins:latest-jdk17

# Install common build tools

USER root

# Node/Npm
# https://github.com/nodesource/distributions
RUN bash -c "curl -sL https://deb.nodesource.com/setup_22.x | bash -"
RUN apt-get update && apt-get install -y nodejs

# Python/pip, and wget
RUN apt-get install -y python3 python3-dev python3-pip wget

# Java
# This image based on a openjdk image.  Java already installed.

# Scala/sbt
# https://www.scala-sbt.org/
COPY install-sbt.sh /tmp/install-sbt.sh
ENV SBT_VERSION=1.10.1
RUN \
  sh /tmp/install-sbt.sh "${SBT_VERSION}" && \
  sbt sbtVersion -Dsbt.rootdir=true && \
  rm /tmp/install-sbt.sh

# Go
# https://go.dev/dl/
RUN wget https://dl.google.com/go/go1.24.5.linux-amd64.tar.gz
RUN tar -xvf go1.24.5.linux-amd64.tar.gz -C /usr/local

# Firebase
# https://firebase.google.com/docs/cli#install-cli-mac-linux
RUN npm install -g firebase-tools

# AWS CLI
RUN pip install awscli --upgrade --break-system-packages

# Docker Tools

# Other Utils
RUN apt-get install -y zip jq gettext

# Install minimal tools for fetching keys and HTTPS transport
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Setup the GPG key in the modern 'keyrings' directory
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg

# Add the Docker repository manually
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install the Docker CE components
RUN apt-get update && apt-get install -y \
    docker-ce \
    && rm -rf /var/lib/apt/lists/*

# Docker Compose
RUN \
  curl -L "https://github.com/docker/compose/releases/download/v2.3.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose

# Android Tools
# https://developer.android.com/studio

# Set environment variables
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

# Download and unpack Android Command Line Tools
# Note: Check the Android Studio downloads page for the latest URL
ARG CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip"

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    curl -fsSL ${CMDLINE_TOOLS_URL} -o /tmp/cmdline-tools.zip && \
    unzip /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

# 4. Accept licenses (Crucial for CI/CD pipelines)
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-36" && \
    sdkmanager "build-tools;36.0.0"

USER jenkins

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Duser.timezone=America/New_York"

RUN java -jar opt/jenkins-plugin-manager.jar --plugins antisamy-markup-formatter matrix-auth blueocean --verbose
