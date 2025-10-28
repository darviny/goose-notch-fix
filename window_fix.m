#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

// This dylib fixes Unity's -popupwindow by making all windows accept key/main status

@interface NSWindow (KeyWindowFix)
@end

@implementation NSWindow (KeyWindowFix)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[WindowFix] Injecting canBecomeKeyWindow/canBecomeMainWindow fix");
        
        Class windowClass = [NSWindow class];
        
        // Swizzle canBecomeKeyWindow
        SEL canBecomeKeySelector = @selector(canBecomeKeyWindow);
        Method originalKeyMethod = class_getInstanceMethod(windowClass, canBecomeKeySelector);
        Method swizzledKeyMethod = class_getInstanceMethod(windowClass, @selector(swizzled_canBecomeKeyWindow));
        
        if (originalKeyMethod && swizzledKeyMethod) {
            method_exchangeImplementations(originalKeyMethod, swizzledKeyMethod);
            NSLog(@"[WindowFix] Swizzled canBecomeKeyWindow");
        }
        
        // Swizzle canBecomeMainWindow
        SEL canBecomeMainSelector = @selector(canBecomeMainWindow);
        Method originalMainMethod = class_getInstanceMethod(windowClass, canBecomeMainSelector);
        Method swizzledMainMethod = class_getInstanceMethod(windowClass, @selector(swizzled_canBecomeMainWindow));
        
        if (originalMainMethod && swizzledMainMethod) {
            method_exchangeImplementations(originalMainMethod, swizzledMainMethod);
            NSLog(@"[WindowFix] Swizzled canBecomeMainWindow");
        }
    });
}

- (BOOL)swizzled_canBecomeKeyWindow {
    // This will call the original implementation due to swizzling
    BOOL originalResult = [self swizzled_canBecomeKeyWindow];
    
    // Log for debugging (optional - remove in production)
    if (!originalResult) {
        NSLog(@"[WindowFix] Forcing canBecomeKeyWindow=YES for window: %@", self);
    }
    
    // Always return YES to fix popup windows
    return YES;
}

- (BOOL)swizzled_canBecomeMainWindow {
    // This will call the original implementation due to swizzling
    BOOL originalResult = [self swizzled_canBecomeMainWindow];
    
    // Log for debugging (optional - remove in production)
    if (!originalResult) {
        NSLog(@"[WindowFix] Forcing canBecomeMainWindow=YES for window: %@", self);
    }
    
    // Always return YES to fix popup windows
    return YES;
}

@end
