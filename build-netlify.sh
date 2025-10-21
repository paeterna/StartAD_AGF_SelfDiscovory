#!/bin/bash
set -e

echo "Starting Netlify Flutter Web build..."

# Install Flutter if not already installed
if ! command -v flutter &> /dev/null; then
    echo "Installing Flutter..."

    # Download and extract Flutter
    FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.5}"
    cd /opt/buildhome

    if [ ! -d "flutter" ]; then
        echo "Downloading Flutter $FLUTTER_VERSION..."
        git clone https://github.com/flutter/flutter.git -b stable --depth 1
    fi

    # Add Flutter to PATH
    export PATH="$PATH:/opt/buildhome/flutter/bin"

    # Pre-download Flutter dependencies
    echo "Configuring Flutter..."
    flutter config --no-analytics
    flutter precache --web

    echo "Flutter installed successfully!"
fi

# Print versions
echo "Flutter version:"
flutter --version

echo "Node version:"
node --version

# Navigate to project directory
cd /opt/build/repo

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "Building Flutter web app..."
flutter build web --release

echo "Build completed successfully!"
echo "Build output is in: build/web"
