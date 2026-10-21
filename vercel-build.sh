#!/bin/bash
set -e

echo "=== FirstHome Nigeria - Root Vercel Build Script ==="

# Check if flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "Flutter SDK not found in path. Installing Flutter SDK (stable channel)..."
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable /tmp/flutter
    export PATH="$PATH:/tmp/flutter/bin"
else
    echo "Flutter SDK found in environment."
fi

flutter --version
flutter config --no-analytics

echo "Navigating to frontend directory..."
cd frontend

echo "Building Flutter Web release..."
if [ -n "$API_BASE_URL" ]; then
    echo "Using custom API_BASE_URL: $API_BASE_URL"
    flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"
else
    echo "No API_BASE_URL provided. Using default / environment fallback."
    flutter build web --release
fi

echo "=== Build finished successfully. Output in frontend/build/web ==="
