#!/bin/bash
set -e

echo "🚀 Starting Flutter Web Build for Netlify"
echo "=========================================="

# Clone Flutter SDK
echo "📦 Installing Flutter SDK..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
  echo "✅ Flutter SDK cloned"
else
  echo "✅ Flutter SDK already exists"
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Configure Flutter
echo "⚙️  Configuring Flutter..."
flutter config --no-analytics
flutter config --enable-web

# Check Flutter installation
echo "🔍 Verifying Flutter installation..."
flutter doctor -v

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Build for web
echo "🏗️  Building Flutter web app..."
flutter build web --release

echo "✅ Build complete!"
echo "📁 Output directory: build/web"
