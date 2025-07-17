# 📍 Mock GPS Location App

A Flutter-based Android application that allows users to mock their GPS location for testing and development purposes.

## 🎯 Features

### Core Functionality
- **Interactive Google Maps**: Tap anywhere on the map to select a location
- **Real-time Location Mocking**: Start/stop GPS location spoofing with a single tap
- **Multiple Location Formats**: Support for Decimal Degrees (DD), Degrees Minutes (DM), and Degrees Minutes Seconds (DMS)
- **Saved Locations**: Bookmark frequently used locations for quick access
- **Background Mocking**: Continue location spoofing even when the app is in the background

### User Interface
- **Modern Material 3 Design**: Clean and intuitive user interface
- **Real-time Coordinates Display**: Shows both current and selected location coordinates
- **Visual Location Markers**: Blue marker for current location, red marker for selected location
- **Status Indicators**: Clear visual feedback for mocking status and errors
- **Developer Mode Guide**: Built-in setup wizard for enabling developer options

### Settings & Configuration
- **Update Interval Control**: Customizable location update frequency
- **Background Service Toggle**: Enable/disable background location mocking
- **Location Format Selection**: Choose your preferred coordinate display format
- **Developer Mode Integration**: Direct access to Android developer settings

## 🛠️ Technical Stack

| Component | Technology |
|-----------|------------|
| **UI Framework** | Flutter (Material 3) |
| **Maps** | Google Maps for Flutter |
| **Location Services** | Geolocator, Location |
| **State Management** | Provider |
| **Storage** | SharedPreferences, SQLite |
| **Background Services** | Flutter Background Service |
| **Platform Integration** | Android MethodChannel (Kotlin) |

## 📋 Prerequisites

### For Development
- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android SDK (API level 21 or higher)
- Google Maps API Key

### For Users
- Android device with API level 21 or higher
- Developer Options enabled
- Mock location app selection configured

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd mock_gps_location_app
```

### 2. Configure Google Maps API Key
1. Get a Google Maps API key from the [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the following APIs:
   - Maps SDK for Android
   - Places API (optional, for future features)
3. Replace `YOUR_GOOGLE_MAPS_API_KEY` in `android/app/src/main/AndroidManifest.xml`

### 3. Build Options

#### Option A: Using Docker (Recommended)
```bash
# Build release APK
./build.sh release

# Build debug APK
./build.sh debug

# Clean build artifacts
./build.sh clean
```

#### Option B: Using Makefile
```bash
# Show available commands
make help

# Build release APK
make build

# Build debug APK
make build-debug

# Clean everything
make clean
```

#### Option C: Using Flutter SDK directly
```bash
# Install dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Build debug APK
flutter build apk --debug
```

### 4. Run the App
```bash
flutter run
```

## 📱 User Setup Guide

### Step 1: Enable Developer Options
1. Go to **Settings** > **About Phone**
2. Tap **Build Number** 7 times
3. You'll see a message: "You are now a developer!"

### Step 2: Enable Mock Location
1. Go to **Settings** > **Developer Options**
2. Find **Select Mock Location App**
3. Choose **Mock GPS Location** from the list

### Step 3: Grant Permissions
1. Open the app
2. Grant location permissions when prompted
3. Grant background location permissions if needed

## 🎮 Usage Instructions

### Basic Usage
1. **Select Location**: Tap anywhere on the map to place a red marker
2. **Start Mocking**: Tap the green "Start Mocking" button
3. **Stop Mocking**: Tap the red "Stop Mocking" button when done

### Advanced Features
- **Save Locations**: Use the bookmark button to save frequently used locations
- **Load Saved Locations**: Access saved locations from the drawer menu
- **Change Settings**: Use the settings drawer to customize app behavior
- **Background Mocking**: Enable in settings to continue mocking when app is minimized

### Location Formats
- **Decimal Degrees (DD)**: 37.7749° N, 122.4194° W
- **Degrees Minutes (DM)**: 37° 46.494' N, 122° 25.164' W
- **Degrees Minutes Seconds (DMS)**: 37° 46' 29.64" N, 122° 25' 9.84" W

## 🔧 Configuration

### Update Interval
- **Default**: 1000ms (1 second)
- **Range**: 100ms - 10000ms
- **Usage**: Controls how frequently the mock location is updated

### Background Mocking
- **Default**: Enabled
- **Effect**: Continues location mocking when app is in background
- **Note**: Requires background location permission

### Location Format
- **Default**: Decimal Degrees
- **Options**: DD, DM, DMS
- **Effect**: Changes how coordinates are displayed throughout the app

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── saved_location.dart   # Data model for saved locations
├── providers/
│   ├── location_provider.dart    # Location state management
│   └── settings_provider.dart    # Settings state management
├── screens/
│   └── home_screen.dart      # Main app screen
├── services/
│   ├── background_service.dart   # Background service management
│   ├── mock_location_service.dart # Platform channel for mock GPS
│   └── storage_service.dart      # Data persistence
└── widgets/
    ├── control_buttons.dart      # Start/stop mocking controls
    ├── developer_mode_guide.dart # Setup wizard
    ├── location_info_card.dart   # Coordinate display
    ├── saved_locations_drawer.dart # Saved locations menu
    └── settings_drawer.dart      # Settings menu
```

## 🔒 Permissions

### Required Permissions
- `ACCESS_FINE_LOCATION`: For precise location access
- `ACCESS_COARSE_LOCATION`: For approximate location access
- `ACCESS_BACKGROUND_LOCATION`: For background location mocking
- `ACCESS_MOCK_LOCATION`: For mock location functionality
- `FOREGROUND_SERVICE`: For background service operation
- `INTERNET`: For Google Maps integration

### Optional Permissions
- `WAKE_LOCK`: For keeping the device awake during background mocking
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`: For reliable background operation

## 🐛 Troubleshooting

### Common Issues

#### "Developer mode is not enabled"
- **Solution**: Follow the setup guide to enable developer options
- **Note**: This is required for mock location functionality

#### "This app is not selected as mock location app"
- **Solution**: Go to Developer Options > Select Mock Location App > Choose this app
- **Note**: Only one app can be selected as mock location provider

#### "Location services are disabled"
- **Solution**: Enable GPS and location services in device settings
- **Note**: Required for both real and mock location functionality

#### "Permission denied"
- **Solution**: Grant location permissions in app settings
- **Note**: Both foreground and background location permissions may be required

### Debug Mode
For development and debugging:
```bash
flutter run --debug
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This app is intended for development, testing, and educational purposes only. Users are responsible for complying with all applicable laws and regulations when using this application. The developers are not responsible for any misuse of this application.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the troubleshooting section above
- Review the setup guide for common issues

## 🏗️ Build System

### Docker Build
The app includes a complete Docker-based build system that doesn't require Flutter SDK installation on your local machine.

#### Prerequisites
- Docker installed and running
- Google Maps API key configured

#### Build Commands
```bash
# Build release APK
./build.sh release

# Build debug APK
./build.sh debug

# Clean build artifacts
./build.sh clean
```

#### Output
- Release APK: `build/outputs/mock-gps-location-app.apk`
- Debug APK: `build/outputs/mock-gps-location-app-debug.apk`

### GitHub Actions
The project includes automated builds via GitHub Actions that trigger on:
- Push to main/master branch
- Pull requests
- Release creation

### Makefile Support
For easier development workflow:
```bash
make help          # Show all available commands
make build         # Build release APK
make build-debug   # Build debug APK
make clean         # Clean all artifacts
```

## 🔄 Version History

- **v1.0.0**: Initial release with core mock GPS functionality
  - Interactive Google Maps integration
  - Real-time location mocking
  - Saved locations feature
  - Settings and configuration options
  - Background service support
  - Developer mode integration
  - Docker-based build system
  - GitHub Actions CI/CD 