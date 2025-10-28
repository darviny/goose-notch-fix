#!/bin/bash

# Unity Window Fix Launcher
# Usage: ./launch.sh /path/to/YourApp.app [additional args]

if [ $# -lt 1 ]; then
    echo "Usage: $0 /path/to/YourApp.app [additional args]"
    echo "Example: $0 ~/Desktop/MyGame.app -popupwindow"
    exit 1
fi

APP_PATH="$1"
shift  # Remove first argument, keep the rest

# Find the executable inside the app bundle
if [ -d "$APP_PATH/Contents/MacOS" ]; then
    # Get the executable name from Info.plist or use the app name
    EXECUTABLE=$(defaults read "$APP_PATH/Contents/Info.plist" CFBundleExecutable 2>/dev/null)
    
    if [ -z "$EXECUTABLE" ]; then
        # Fallback: use the app name without .app extension
        EXECUTABLE=$(basename "$APP_PATH" .app)
    fi
    
    EXEC_PATH="$APP_PATH/Contents/MacOS/$EXECUTABLE"
else
    echo "Error: Invalid app bundle structure"
    exit 1
fi

if [ ! -f "$EXEC_PATH" ]; then
    echo "Error: Executable not found at $EXEC_PATH"
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DYLIB_PATH="$SCRIPT_DIR/libwindowfix.dylib"

if [ ! -f "$DYLIB_PATH" ]; then
    echo "Error: $DYLIB_PATH not found. Run build.sh first."
    exit 1
fi

echo "Launching with window fix injection..."
echo "App: $EXEC_PATH"
echo "Dylib: $DYLIB_PATH"
echo "Args: $@"
echo ""

# Launch with dylib injection
DYLD_INSERT_LIBRARIES="$DYLIB_PATH" "$EXEC_PATH" "$@"
