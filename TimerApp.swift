
import SwiftUI
import AppKit

// Custom NSWindow subclass to ensure it can become key
class AlwaysKeyWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
    override var canBecomeMain: Bool {
        return true
    }
}

// AppDelegate to manage the custom window and menu bar extra
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer App")
            button.action = #selector(toggleWindow(_:))
        }

        // Create a borderless window
        let contentView = ContentView()
        window = AlwaysKeyWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 400),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.isReleasedWhenClosed = false
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.contentView = NSHostingView(rootView: contentView)
    }

    @objc func toggleWindow(_ sender: Any?) {
        if window.isVisible {
            window.orderOut(sender)
        } else {
            window.makeKeyAndOrderFront(sender)
        }
    }
}

@main
struct TimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // The settings scene is required for the app to launch when using an AppDelegate
        Settings {
            EmptyView()
        }
    }
}
