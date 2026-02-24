#!/bin/bash
set -e

APP_NAME="CleanText"
BUILD_DIR="build"

mkdir -p "$BUILD_DIR"

echo "Compiling..."
swiftc -o "$BUILD_DIR/$APP_NAME" main.swift \
    -framework Cocoa \
    -framework Carbon \
    -O

echo "Creating app bundle..."
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"
cp Info.plist "$APP_BUNDLE/Contents/"

echo "Signing..."
codesign --force --sign - "$APP_BUNDLE"

echo ""
echo "Done: $APP_BUNDLE"
echo ""
echo "To install:  cp -r $APP_BUNDLE /Applications/"
echo "To run now:  open $APP_BUNDLE"
