# Dockerfile
FROM jenkins/jenkins:lts

USER root

# Fix SSL and cert issues
RUN apt-get update && apt-get install --reinstall -y \
    ca-certificates openssl libssl-dev curl ca-certificates-java

# Install required packages
RUN apt-get install -y --no-install-recommends \
    unzip git openjdk-17-jdk wget bash xz-utils zip libglu1-mesa \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Android SDK setup
ENV ANDROID_SDK_ROOT=/opt/android-sdk
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    curl -fsSL -o sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip && \
    unzip -q sdk.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm sdk.zip

ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"

# Accept Android licenses and install essential tools
RUN yes | sdkmanager --licenses && \
    sdkmanager --no_https "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Flutter SDK setup
ENV FLUTTER_VERSION=3.29.3
RUN curl -fsSL -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -C /opt && \
    rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Fix permissions
RUN chown -R jenkins:jenkins /opt/flutter /opt/android-sdk /var/jenkins_home

USER jenkins

# Flutter setup
RUN git config --global --add safe.directory /opt/flutter && \
    flutter doctor -v && \
    flutter precache

# Disable Jenkins setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

WORKDIR /var/jenkins_home
