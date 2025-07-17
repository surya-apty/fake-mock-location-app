# Mock GPS Location App - Makefile
# Provides easy commands for building and managing the app

.PHONY: help build build-release build-debug clean docker-build docker-clean install-deps test

# Default target
help:
	@echo "Mock GPS Location App - Available Commands:"
	@echo ""
	@echo "Build Commands:"
	@echo "  build          Build release APK using Docker"
	@echo "  build-release  Build release APK using Docker"
	@echo "  build-debug    Build debug APK using Docker"
	@echo "  docker-build   Build Docker image only"
	@echo ""
	@echo "Utility Commands:"
	@echo "  clean          Clean build artifacts and Docker images"
	@echo "  docker-clean   Clean Docker images only"
	@echo "  install-deps   Install Flutter dependencies"
	@echo "  test           Run Flutter tests"
	@echo "  help           Show this help message"
	@echo ""

# Build commands
build: build-release

build-release:
	@echo "Building release APK..."
	@./build.sh release

build-debug:
	@echo "Building debug APK..."
	@./build.sh debug

# Docker commands
docker-build:
	@echo "Building Docker image..."
	@docker build -t mock-gps-location-app .

docker-clean:
	@echo "Cleaning Docker images..."
	@docker rmi mock-gps-location-app mock-gps-location-app-debug 2>/dev/null || true
	@docker rm -f mock-gps-build mock-gps-build-debug 2>/dev/null || true

# Utility commands
clean: docker-clean
	@echo "Cleaning build artifacts..."
	@rm -rf build/
	@rm -rf .dart_tool/
	@rm -rf .flutter-plugins
	@rm -rf .flutter-plugins-dependencies
	@echo "Clean completed!"

install-deps:
	@echo "Installing Flutter dependencies..."
	@flutter pub get

test:
	@echo "Running Flutter tests..."
	@flutter test

# Development commands
dev-setup: install-deps
	@echo "Development setup completed!"
	@echo "Next steps:"
	@echo "1. Configure Google Maps API key in android/app/src/main/AndroidManifest.xml"
	@echo "2. Run 'make build' to build the APK"

# Quick build without Docker (requires Flutter SDK)
quick-build:
	@echo "Building APK using local Flutter SDK..."
	@flutter build apk --release
	@echo "APK built at: build/app/outputs/flutter-apk/app-release.apk"

quick-build-debug:
	@echo "Building debug APK using local Flutter SDK..."
	@flutter build apk --debug
	@echo "Debug APK built at: build/app/outputs/flutter-apk/app-debug.apk" 