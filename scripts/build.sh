#!/bin/bash
set -e

# Install Flutter
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter_sdk
export PATH="$PWD/flutter_sdk/bin:$PATH"

# Verify Flutter installation
flutter --version
flutter doctor

# Install dependencies and build
echo "Building Flutter web app..."
flutter pub get
flutter build web --release --web-renderer html

echo "Build completed successfully!"
