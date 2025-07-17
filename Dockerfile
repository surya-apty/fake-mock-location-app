# Use the official Flutter image (includes Flutter SDK & Android SDK)
FROM cirrusci/flutter:latest

# Set working directory
WORKDIR /app

# Copy pubspec files and get dependencies early
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the app source
COPY . .

# Run flutter build (e.g., for Android APK)
# For release APK:
RUN flutter build apk --release

# Alternatively, build debug APK:
# RUN flutter build apk --debug

# Output APK will be in build/app/outputs/flutter-apk/ 