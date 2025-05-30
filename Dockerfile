# Dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip xz-utils zip git openjdk-17-jdk bash wget libglu1-mesa ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    curl -fsSL -o sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip && \
    unzip -q sdk.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm sdk.zip

ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"

# Accept Android SDK licenses and install components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Flutter SDK
ENV FLUTTER_VERSION=3.19.5
RUN curl -fsSL -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -C /opt && \
    rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Precache Flutter and run doctor
RUN git config --global --add safe.directory /opt/flutter && \
    flutter doctor -v && \
    flutter precache

WORKDIR /workspace

CMD ["bash"]
