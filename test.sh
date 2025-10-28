#!/bin/bash

# Test script to verify the window fix dylib works correctly

set -e

DYLIB="libwindowfix.dylib"

echo "=== Unity Window Fix - Verification Script ==="
echo ""

# Check if dylib exists
if [ ! -f "$DYLIB" ]; then
    echo "❌ Error: $DYLIB not found"
    echo "   Run ./build.sh first"
    exit 1
fi
echo "✓ Found $DYLIB"

# Check dylib architecture
echo ""
echo "Architecture check:"
file "$DYLIB"

# Verify it's a dynamic library
if file "$DYLIB" | grep -q "dynamically linked shared library"; then
    echo "✓ Valid dynamic library"
else
    echo "❌ Warning: File may not be a valid dylib"
fi

# Check dependencies
echo ""
echo "Dependencies:"
otool -L "$DYLIB"

# Verify Cocoa framework is linked
if otool -L "$DYLIB" | grep -q "Cocoa.framework"; then
    echo "✓ Cocoa framework linked"
else
    echo "❌ Error: Cocoa framework not linked"
    exit 1
fi

# Check for exported symbols
echo ""
echo "Checking for key symbols:"
if nm "$DYLIB" | grep -q "NSWindow"; then
    echo "✓ NSWindow symbols found"
else
    echo "❌ Warning: NSWindow symbols not found"
fi

# Verify code signature (if signed)
echo ""
echo "Code signature:"
codesign -dv "$DYLIB" 2>&1 || echo "(unsigned - OK for development)"

echo ""
echo "=== Verification Complete ==="
echo ""
echo "To test with your Unity app:"
echo "  ./launch.sh /path/to/YourApp.app -popupwindow"
echo ""
echo "After launching, check Console.app for these messages:"
echo "  [WindowFix] Injecting canBecomeKeyWindow/canBecomeMainWindow fix"
echo "  [WindowFix] Swizzled canBecomeKeyWindow"
echo "  [WindowFix] Swizzled canBecomeMainWindow"
