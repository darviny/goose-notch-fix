This solution fixes Unity's `-popupwindow` issue where borderless windows refuse keyboard focus on macOS by injecting code at runtime using method swizzling.
The dylib swizzles (overrides) NSWindow's `canBecomeKeyWindow` and `canBecomeMainWindow` methods to always return `YES`, allowing popup windows to accept keyboard input.

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
