#!/bin/bash

APP_NAME="KeyboardSound"
DMG_NAME="KeySound-v1.2"
BUILD_DIR="build"
STAGING_DIR="dmg-staging"
TEMP_DMG="build/temp.dmg"
FINAL_DMG="build/${DMG_NAME}.dmg"

echo "Creating DMG for ${APP_NAME} v1.2..."

# Clean
rm -rf "${STAGING_DIR}"
rm -f "${TEMP_DMG}" "${FINAL_DMG}"
mkdir -p "${STAGING_DIR}"

# Copy app
cp -R "${BUILD_DIR}/${APP_NAME}.app" "${STAGING_DIR}/"

# Copy fix script
chmod +x fix-permissions.sh
cp fix-permissions.sh "${STAGING_DIR}/"

# Create Applications symlink
ln -s /Applications "${STAGING_DIR}/Applications"

# Create README
cat > "${STAGING_DIR}/How to Install.txt" << 'EOF'
KeySound - Keyboard Sound App
==============================

1. Drag "KeyboardSound.app" to "Applications" folder
2. If you see a security warning:
   - Right-click the app → Select "Open"
   - Click "Open" in the dialog
3. Or run "fix-permissions.sh" to auto-fix

That's it! The app will appear in your Menu Bar.
EOF

# Unmount any existing
hdiutil detach /Volumes/KeyboardSound* -quiet 2>/dev/null || true

# Create temp DMG (read/write)
hdiutil create -srcfolder "${STAGING_DIR}" -volname "${APP_NAME}" -fs HFS+ -format UDRW "${TEMP_DMG}" -quiet

# Mount
MOUNT_OUTPUT=$(hdiutil attach "${TEMP_DMG}" -readwrite -noverify -noautoopen 2>&1)
MOUNT_POINT=$(echo "${MOUNT_OUTPUT}" | grep "/Volumes/" | head -1 | awk '{print $NF}')

if [ -z "${MOUNT_POINT}" ]; then
    MOUNT_POINT="/Volumes/${APP_NAME}"
fi

echo "Mounted at: ${MOUNT_POINT}"

# Set window properties via AppleScript
osascript <<EOF
tell application "Finder"
    tell disk "${APP_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 640, 400}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 96
        set position of item "${APP_NAME}.app" of container window to {100, 150}
        set position of item "Applications" of container window to {400, 150}
        set position of item "fix-permissions.sh" of container window to {100, 300}
        set position of item "How to Install.txt" of container window to {300, 300}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF

# Sync
sync

# Unmount
hdiutil detach "${MOUNT_POINT}" -quiet

# Convert to compressed read-only
hdiutil convert "${TEMP_DMG}" -format UDZO -imagekey zlib-level=9 -o "${FINAL_DMG}" -quiet

# Remove quarantine
xattr -cr "${FINAL_DMG}" 2>/dev/null || true

# Clean up
rm -f "${TEMP_DMG}"
rm -rf "${STAGING_DIR}"

echo ""
echo "DMG created: ${FINAL_DMG}"
ls -lh "${FINAL_DMG}"
