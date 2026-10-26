#!/bin/bash
set -e

echo "=== FirstHome Nigeria - Vercel Build Script ==="

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

echo "Building Flutter Web release..."
# Sanitize API_BASE_URL (strip any accidental newlines, returns, or spaces)
CLEAN_API_URL=$(echo "$API_BASE_URL" | tr -d '\r\n[:space:]')

if [ -n "$CLEAN_API_URL" ]; then
    echo "Using sanitized API_BASE_URL: $CLEAN_API_URL"
    flutter build web --release -t lib/main.dart --dart-define=API_BASE_URL="$CLEAN_API_URL"
else
    echo "No API_BASE_URL provided. Using default / environment fallback."
    flutter build web --release -t lib/main.dart
fi

echo "=== Build finished successfully. Output in build/web ==="
