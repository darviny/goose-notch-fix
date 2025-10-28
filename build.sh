#!/bin/bash

# Build script for Unity Window Fix dylib
# This creates a universal binary that works on both Intel and Apple Silicon Macs

set -e  # Exit on error

echo "Building Unity Window Fix dylib..."

# Output file
OUTPUT="libwindowfix.dylib"

# Compile for both architectures
clang -arch x86_64 -arch arm64 \
    -dynamiclib \
    -framework Cocoa \
    -framework Foundation \
    -fobjc-arc \
    -o "$OUTPUT" \
    window_fix.m

echo "✓ Built: $OUTPUT"

# Show file info
file "$OUTPUT"
otool -L "$OUTPUT"

echo ""
echo "To use this dylib:"
echo "  DYLD_INSERT_LIBRARIES=\$(pwd)/$OUTPUT /path/to/YourApp.app/Contents/MacOS/YourApp -popupwindow"
