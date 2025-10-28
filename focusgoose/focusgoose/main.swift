// goose_ax_diag.swift
import Foundation
import Cocoa
import ApplicationServices

let appName = "Untitled Goose Game"

func findApp() -> NSRunningApplication? {
    if let app = NSWorkspace.shared.runningApplications.first(where: { $0.localizedName == appName }) {
        return app
    }
    return NSWorkspace.shared.runningApplications.first(where: { $0.localizedName?.lowercased().contains("goose") ?? false })
}

guard let app = findApp() else {
    print("Cannot find app '\(appName)'")
    exit(2)
}
let pid = app.processIdentifier
print("PID: \(pid) - \(app.localizedName ?? "")")

let axApp = AXUIElementCreateApplication(pid_t(pid))
var val: CFTypeRef?

func getAttr(_ element: AXUIElement, _ name: CFString) -> CFTypeRef? {
    var v: CFTypeRef?
    let r = AXUIElementCopyAttributeValue(element, name, &v)
    if r == .success { return v }
    return nil
}

// windows
if AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &val) == .success, let wins = val as? [AXUIElement] {
    print("Found \(wins.count) windows.")
    for (i,w) in wins.enumerated() {
        print("Window[\(i)] ----------------")
        if let title = getAttr(w, kAXTitleAttribute as CFString) as? String { print(" title: \(title)") }
        if let role = getAttr(w, kAXRoleAttribute as CFString) as? String { print(" role: \(role)") }
        if let subrole = getAttr(w, kAXSubroleAttribute as CFString) as? String { print(" subrole: \(subrole)") }
        if let main = getAttr(w, kAXMainAttribute as CFString) as? Bool { print(" main: \(main)") }
        if let focused = getAttr(w, kAXFocusedAttribute as CFString) as? Bool { print(" focused: \(focused)") }
        if let size = getAttr(w, kAXSizeAttribute as CFString) {
            print(" size: \(size)")
        }
    }
} else {
    print("No AX windows or AX failure (ensure Accessibility permission).")
}

// focused UI element in app
if AXUIElementCopyAttributeValue(axApp, kAXFocusedUIElementAttribute as CFString, &val) == .success {
    if let elem = val {
        print("kAXFocusedUIElement present: \(elem)")
        if let role = getAttr(elem as! AXUIElement, kAXRoleAttribute as CFString) as? String { print(" focused element role: \(role)") }
        if let desc = getAttr(elem as! AXUIElement, kAXDescriptionAttribute as CFString) as? String { print(" desc: \(desc)") }
    } else {
        print("kAXFocusedUIElement is nil.")
    }
} else {
    print("kAXFocusedUIElement not available / AX call failed.")
}
