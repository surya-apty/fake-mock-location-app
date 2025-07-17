# Use a more recent Flutter image with Dart SDK 3.0+
FROM ubuntu:20.04

# Set environment variables
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -ms /bin/bash flutter
USER flutter
WORKDIR /home/flutter

# Download and install Flutter (latest stable)
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME
RUN flutter channel stable
RUN flutter upgrade
RUN flutter doctor

# Download and install Android SDK
RUN mkdir -p $ANDROID_HOME
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O /tmp/cmdline-tools.zip
RUN unzip -q /tmp/cmdline-tools.zip -d /tmp
RUN mkdir -p $ANDROID_HOME/cmdline-tools
RUN mv /tmp/cmdline-tools $ANDROID_HOME/cmdline-tools/latest

# Accept Android licenses
RUN yes | sdkmanager --licenses || true

# Install Android SDK components
RUN sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Set working directory for the app
WORKDIR /home/flutter/app

# Copy pubspec files and get dependencies early
COPY --chown=flutter:flutter pubspec.* ./
RUN flutter pub get

# Copy the rest of the app source
COPY --chown=flutter:flutter . .

# Run flutter build for release APK
RUN flutter build apk --release

# Output APK will be in build/app/outputs/flutter-apk/ 