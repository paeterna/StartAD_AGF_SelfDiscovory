#!/bin/bash
set -e

echo "=� Starting Netlify Flutter Web build..."

# Print versions
echo "Flutter version:"
flutter --version

echo "Node version:"
node --version

# Get dependencies
echo "=� Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "=( Building Flutter web app..."
flutter build web --release

echo " Build completed successfully!"
echo "=� Build output is in: build/web"
