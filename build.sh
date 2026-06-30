#!/bin/bash

APP_NAME="KeyboardSound"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"

rm -rf "${BUILD_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

# Copy icon
if [ -f "KeyboardSound/AppIcon.icns" ]; then
    cp "KeyboardSound/AppIcon.icns" "${APP_DIR}/Contents/Resources/"
fi

swiftc \
    -target arm64-apple-macos13.0 \
    -framework Cocoa \
    -o "${APP_DIR}/Contents/MacOS/${APP_NAME}" \
    KeyboardSound/main.swift \
    KeyboardSound/AppDelegate.swift \
    KeyboardSound/KeyboardMonitor.swift \
    KeyboardSound/SettingsViewController.swift

cp KeyboardSound/Info.plist "${APP_DIR}/Contents/Info.plist"
echo -n "APPL????" > "${APP_DIR}/Contents/PkgInfo"

echo "Build complete: ${APP_DIR}"
