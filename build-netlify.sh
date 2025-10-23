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

# Create .env file from Netlify environment variables
echo "Creating .env file..."
cat > .env << EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
AI_RECO_ENABLED=true
TEACHER_MODE_ENABLED=true
ENVIRONMENT=production
EOF
echo ".env file created successfully!"

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build for web with Supabase credentials
echo "Building Flutter web app..."
flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"

echo "Build completed successfully!"
echo "Build output is in: build/web"
