#!/bin/bash

# Mock GPS Location App - Build Script
# This script builds the Android APK using Docker

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "Docker is available and running"
}

# Function to check if Google Maps API key is configured
check_api_key() {
    if grep -q "YOUR_GOOGLE_MAPS_API_KEY" android/app/src/main/AndroidManifest.xml; then
        print_warning "Google Maps API key not configured!"
        print_warning "Please replace 'YOUR_GOOGLE_MAPS_API_KEY' in android/app/src/main/AndroidManifest.xml"
        print_warning "You can get a free API key from: https://console.cloud.google.com/"
        read -p "Do you want to continue without Google Maps? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Build cancelled. Please configure the API key first."
            exit 1
        fi
    else
        print_success "Google Maps API key is configured"
    fi
}

# Function to build the app
build_app() {
    local build_type=${1:-release}
    local image_name="mock-gps-location-app"
    local container_name="mock-gps-build"
    
    print_status "Starting build process for $build_type APK..."
    
    # Remove existing container if it exists
    docker rm -f $container_name 2>/dev/null || true
    
    # Build Docker image
    print_status "Building Docker image..."
    docker build -f Dockerfile.simple -t $image_name . || {
        print_error "Failed to build Docker image"
        exit 1
    }
    
    # Create container and copy APK
    print_status "Building APK in container..."
    docker create --name $container_name $image_name
    
    # Create output directory
    mkdir -p build/outputs
    
    # Copy APK from container
    print_status "Extracting APK from container..."
    docker cp $container_name:/app/build/app/outputs/flutter-apk/app-release.apk build/outputs/mock-gps-location-app.apk || {
        print_error "Failed to extract APK from container"
        docker rm -f $container_name
        exit 1
    }
    
    # Clean up container
    docker rm -f $container_name
    
    print_success "APK built successfully!"
    print_success "APK location: build/outputs/mock-gps-location-app.apk"
}

# Function to build debug APK
build_debug() {
    print_status "Building debug APK..."
    
    # Create a temporary Dockerfile for debug build
    cat > Dockerfile.debug << EOF
# Use a more recent Flutter image with Dart SDK 3.0+
FROM ghcr.io/cirruslabs/flutter:3.16.5

# Set working directory
WORKDIR /app

# Copy pubspec files and get dependencies early
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the app source
COPY . .

# Build debug APK
RUN flutter build apk --debug
EOF
    
    local image_name="mock-gps-location-app-debug"
    local container_name="mock-gps-build-debug"
    
    # Remove existing container if it exists
    docker rm -f $container_name 2>/dev/null || true
    
    # Build Docker image
    print_status "Building Docker image for debug APK..."
    docker build -f Dockerfile.debug -t $image_name . || {
        print_error "Failed to build Docker image for debug APK"
        rm -f Dockerfile.debug
        exit 1
    }
    
    # Create container and copy APK
    print_status "Building debug APK in container..."
    docker create --name $container_name $image_name
    
    # Create output directory
    mkdir -p build/outputs
    
    # Copy APK from container
    print_status "Extracting debug APK from container..."
    docker cp $container_name:/app/build/app/outputs/flutter-apk/app-debug.apk build/outputs/mock-gps-location-app-debug.apk || {
        print_error "Failed to extract debug APK from container"
        docker rm -f $container_name
        rm -f Dockerfile.debug
        exit 1
    }
    
    # Clean up container and temporary Dockerfile
    docker rm -f $container_name
    rm -f Dockerfile.debug
    
    print_success "Debug APK built successfully!"
    print_success "Debug APK location: build/outputs/mock-gps-location-app-debug.apk"
}

# Function to show usage
show_usage() {
    echo "Mock GPS Location App - Build Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  release    Build release APK (default)"
    echo "  debug      Build debug APK"
    echo "  clean      Clean build artifacts"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Build release APK"
    echo "  $0 release      # Build release APK"
    echo "  $0 debug        # Build debug APK"
    echo "  $0 clean        # Clean build artifacts"
}

# Function to clean build artifacts
clean_build() {
    print_status "Cleaning build artifacts..."
    
    # Remove build directories
    rm -rf build/
    rm -rf .dart_tool/
    rm -rf .flutter-plugins
    rm -rf .flutter-plugins-dependencies
    
    # Remove Docker containers and images
    docker rm -f mock-gps-build mock-gps-build-debug 2>/dev/null || true
    docker rmi mock-gps-location-app mock-gps-location-app-debug 2>/dev/null || true
    
    print_success "Build artifacts cleaned successfully!"
}

# Main script logic
main() {
    local command=${1:-release}
    
    case $command in
        release)
            check_docker
            check_api_key
            build_app release
            ;;
        debug)
            check_docker
            check_api_key
            build_debug
            ;;
        clean)
            clean_build
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 