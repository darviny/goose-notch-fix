# Unity Popup Window Keyboard Fix (Runtime Injection)

This solution fixes Unity's `-popupwindow` issue where borderless windows refuse keyboard focus on macOS by injecting code at runtime using method swizzling.

## How It Works

The dylib swizzles (overrides) NSWindow's `canBecomeKeyWindow` and `canBecomeMainWindow` methods to always return `YES`, allowing popup windows to accept keyboard input.

## Prerequisites

- macOS with Xcode Command Line Tools installed
- A Unity app with the `-popupwindow` keyboard focus issue
- Basic terminal knowledge

## Quick Start

### 1. Build the dylib

```bash
chmod +x build.sh
./build.sh
```

This creates `libwindowfix.dylib` - a universal binary that works on both Intel and Apple Silicon Macs.

### 2. Launch your Unity app with injection

**Option A: Using the launcher script (recommended)**

```bash
chmod +x launch.sh
./launch.sh /path/to/YourApp.app -popupwindow
```

**Option B: Manual launch**

```bash
DYLD_INSERT_LIBRARIES=$(pwd)/libwindowfix.dylib \
    /path/to/YourApp.app/Contents/MacOS/YourApp -popupwindow
```

## Verification

After launching, check the Console.app for log messages:

```
[WindowFix] Injecting canBecomeKeyWindow/canBecomeMainWindow fix
[WindowFix] Swizzled canBecomeKeyWindow
[WindowFix] Swizzled canBecomeMainWindow
```

If you see these messages, the injection worked. Try typing in your popup window - it should now accept keyboard input!

## Advanced Usage

### Permanent Integration

To make this permanent, you can:

1. **Code Sign and bundle the dylib with your app:**
   ```bash
   codesign -s "Your Developer ID" libwindowfix.dylib
   cp libwindowfix.dylib YourApp.app/Contents/MacOS/
   ```

2. **Modify the app's executable to load the dylib:**
   ```bash
   install_name_tool -add_rpath @executable_path libwindowfix.dylib \
       YourApp.app/Contents/MacOS/YourApp
   ```

3. **Create a launcher app/script** that always launches with the dylib

### Debugging

Enable verbose logging by checking Console.app filtered to your app name. The dylib logs:
- When it's loaded
- Each time it forces a window to accept key/main status

To remove the debug logs, comment out the `NSLog` lines in `window_fix.m` and rebuild.

### System Integrity Protection (SIP)

If injection doesn't work:

1. **Check if SIP is blocking it:**
   ```bash
   csrutil status
   ```

2. **For development**, you can disable library validation:
   ```bash
   # Remove signature
   codesign --remove-signature YourApp.app
   
   # Re-sign with proper entitlements
   codesign -s - --deep --force \
       --options=runtime \
       --entitlements entitlements.plist \
       YourApp.app
   ```

3. **Create entitlements.plist:**
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>com.apple.security.cs.allow-dyld-environment-variables</key>
       <true/>
       <key>com.apple.security.cs.disable-library-validation</key>
       <true/>
   </dict>
   </plist>
   ```

## Troubleshooting

**Problem:** "dyld: could not load inserted library"
- **Solution:** Check the dylib path is correct and the file exists
- Use absolute paths: `DYLD_INSERT_LIBRARIES=/full/path/to/libwindowfix.dylib`

**Problem:** No log messages in Console
- **Solution:** The dylib isn't being loaded. Check SIP/signing issues above

**Problem:** Logs appear but keyboard still doesn't work
- **Solution:** The issue might be elsewhere. Try:
  ```bash
  # Check if window is actually receiving focus
  # In Console.app, filter for "NSWindow" logs
  ```

**Problem:** App crashes on launch
- **Solution:** Rebuild the dylib, ensure architecture matches (x86_64 vs arm64)
- Check crash logs in Console.app

## Distribution

For distributing your fixed app:

### Method 1: Bundle the dylib
1. Include `libwindowfix.dylib` in your app bundle
2. Create a shell script launcher that sets `DYLD_INSERT_LIBRARIES`
3. Code sign everything together

### Method 2: Patch the binary directly
If runtime injection is too fragile, consider binary patching instead (see the binary patching guide).

## Files Included

- `window_fix.m` - Source code for the injection dylib
- `build.sh` - Compiles the dylib
- `launch.sh` - Convenience launcher script
- `README.md` - This file

## Technical Details

The injection works by:
1. Loading our dylib into the Unity process via `DYLD_INSERT_LIBRARIES`
2. The `+load` method executes automatically when the dylib loads
3. We swizzle NSWindow methods to intercept the return value
4. All windows now return YES for `canBecomeKeyWindow` and `canBecomeMainWindow`

This is a runtime modification - the original app binary is unchanged.

## License

This is a technical solution for a Unity bug. Use freely for your own projects.
