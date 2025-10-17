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
echo "🔑 Using Supabase URL: ${SUPABASE_URL:0:30}..."
flutter build web --release \
  --no-tree-shake-icons \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

# Add cache busting timestamp to index.html
echo "🔄 Adding cache busting timestamp..."
TIMESTAMP=$(date +%s)
sed -i.bak "s/{{TIMESTAMP}}/$TIMESTAMP/g" build/web/index.html
rm -f build/web/index.html.bak

# Create a version file for reference
echo "$TIMESTAMP" > build/web/version.txt
echo "📝 Build version: $TIMESTAMP"

echo "✅ Build complete!"
echo "📁 Output directory: build/web"
