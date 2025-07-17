# 🏗️ Build Guide - Mock GPS Location App

This guide covers all the build options available for the Mock GPS Location app.

## 📋 Prerequisites

### For Docker Builds
- Docker installed and running
- Google Maps API key configured

### For Local Builds
- Flutter SDK (3.0.0 or higher)
- Android SDK
- Google Maps API key configured

## 🐳 Docker Build (Recommended)

The Docker build system allows you to build the app without installing Flutter SDK locally.

### Quick Start
```bash
# Build release APK
./build.sh release

# Build debug APK
./build.sh debug

# Clean build artifacts
./build.sh clean
```

### What the Docker Build Does
1. Uses the official Flutter Docker image (`cirrusci/flutter:latest`)
2. Copies your app source code into the container
3. Installs dependencies (`flutter pub get`)
4. Builds the Android APK
5. Extracts the APK to your local `build/outputs/` directory

### Build Output
- **Release APK**: `build/outputs/mock-gps-location-app.apk`
- **Debug APK**: `build/outputs/mock-gps-location-app-debug.apk`

### Docker Build Options
```bash
# Show help
./build.sh help

# Build release APK (default)
./build.sh release

# Build debug APK
./build.sh debug

# Clean everything
./build.sh clean
```

## 🔧 Makefile Build

The Makefile provides convenient shortcuts for common build tasks.

### Available Commands
```bash
# Show all available commands
make help

# Build release APK
make build

# Build debug APK
make build-debug

# Build Docker image only
make docker-build

# Clean build artifacts
make clean

# Install dependencies (requires Flutter SDK)
make install-deps

# Run tests (requires Flutter SDK)
make test
```

### Quick Development Setup
```bash
# Setup development environment
make dev-setup

# Build the app
make build
```

## 🚀 Local Flutter Build

If you have Flutter SDK installed locally, you can build directly:

### Install Dependencies
```bash
flutter pub get
```

### Build Commands
```bash
# Build release APK
flutter build apk --release

# Build debug APK
flutter build apk --debug

# Build app bundle (for Play Store)
flutter build appbundle --release
```

### Local Build Output
- **Release APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

## 🔄 GitHub Actions CI/CD

The project includes automated builds via GitHub Actions.

### Triggers
- Push to main/master branch
- Pull requests
- Release creation

### What Happens
1. Code is checked out
2. Docker Buildx is set up
3. Release APK is built
4. Debug APK is built
5. APKs are uploaded as artifacts
6. Docker images are cleaned up

### Accessing Build Artifacts
1. Go to your GitHub repository
2. Click on "Actions" tab
3. Select the latest workflow run
4. Download the "android-apks" artifact

## 🔑 Google Maps API Key Setup

### Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Places API (optional)
4. Create credentials (API Key)
5. Restrict the API key to Android apps with your package name

### Configure in App
Replace `YOUR_GOOGLE_MAPS_API_KEY` in `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE" />
```

## 🐛 Troubleshooting

### Docker Issues

#### "Docker is not installed"
```bash
# Install Docker Desktop
# Visit: https://www.docker.com/products/docker-desktop
```

#### "Docker is not running"
```bash
# Start Docker Desktop
# Or on Linux:
sudo systemctl start docker
```

#### "Permission denied" on Docker commands
```bash
# Add your user to docker group
sudo usermod -aG docker $USER
# Log out and log back in
```

### Build Issues

#### "Google Maps API key not configured"
- Follow the API key setup guide above
- Or run with `--force` flag (maps won't work)

#### "Build failed"
```bash
# Clean and retry
./build.sh clean
./build.sh release
```

#### "Out of disk space"
```bash
# Clean Docker images
docker system prune -a
```

### Flutter Issues

#### "Flutter not found"
```bash
# Install Flutter SDK
# Visit: https://flutter.dev/docs/get-started/install
```

#### "Android SDK not found"
```bash
# Install Android Studio
# Or set ANDROID_HOME environment variable
export ANDROID_HOME=/path/to/android/sdk
```

## 📱 Installing the APK

### On Android Device
1. Enable "Install from Unknown Sources" in Settings
2. Transfer APK to device
3. Tap the APK file to install

### Via ADB
```bash
# Install APK
adb install build/outputs/mock-gps-location-app.apk

# Uninstall if needed
adb uninstall com.example.mock_gps_location_app
```

## 🔒 Security Notes

### API Key Security
- Never commit API keys to version control
- Use environment variables in CI/CD
- Restrict API keys to specific apps and APIs

### APK Signing
- Release builds should be signed with a proper keystore
- Debug builds use debug keystore automatically
- For Play Store, use app bundles instead of APKs

## 📊 Build Performance

### Docker Build Times
- **First build**: ~10-15 minutes (downloads Flutter image)
- **Subsequent builds**: ~5-8 minutes
- **Clean builds**: ~8-10 minutes

### Local Build Times
- **First build**: ~3-5 minutes
- **Incremental builds**: ~30 seconds - 2 minutes

### Optimization Tips
- Use `.dockerignore` to exclude unnecessary files
- Use Docker layer caching effectively
- Consider using multi-stage builds for production

## 🎯 Next Steps

After building the APK:

1. **Test the app** on a real Android device
2. **Configure developer options** on the device
3. **Select this app** as mock location provider
4. **Test mock location** functionality
5. **Distribute** the APK to users

## 📞 Support

For build-related issues:
- Check the troubleshooting section above
- Review Docker and Flutter documentation
- Create an issue in the GitHub repository 