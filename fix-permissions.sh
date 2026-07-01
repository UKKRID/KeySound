#!/bin/bash
echo "============================="
echo "  KeySound Installer"
echo "============================="
echo ""
echo "Removing quarantine from KeySound.app..."
xattr -cr "/Applications/KeySound.app" 2>/dev/null
xattr -cr "$HOME/Downloads/KeySound.app" 2>/dev/null

APP_PATH=""
if [ -d "/Applications/KeySound.app" ]; then
    APP_PATH="/Applications/KeySound.app"
elif [ -d "$HOME/Applications/KeySound.app" ]; then
    APP_PATH="$HOME/Applications/KeySound.app"
fi

if [ -n "$APP_PATH" ]; then
    echo "Found: $APP_PATH"
    echo "Opening KeySound..."
    open "$APP_PATH"
    echo ""
    echo "Done! KeySound is now running."
else
    echo ""
    echo "Please drag KeySound.app to Applications first, then run this script again."
fi
echo ""
echo "Press any key to close..."
read -n 1
