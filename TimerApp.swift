
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance = NSAppearance(named: .vibrantDark)
    }
}

// Function to create a custom 4-sided star image
func createFourPointedStarImage(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    if let context = NSGraphicsContext.current?.cgContext {
        // Clear the canvas
        context.setFillColor(NSColor.clear.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))
        
        // Create a 4-pointed star path
        let path = NSBezierPath()
        let center = CGPoint(x: size/2, y: size/2)
        let outerRadius = size/2
        let innerRadius = outerRadius * 0.4
        
        // Draw the star with 4 points
        for i in 0..<4 {
            let outerAngle = CGFloat(i) * .pi/2  // 4 points, so divide by 2
            let innerAngle = outerAngle + .pi/4
            
            let outerPoint = CGPoint(
                x: center.x + outerRadius * cos(outerAngle),
                y: center.y + outerRadius * sin(outerAngle)
            )
            
            let innerPoint = CGPoint(
                x: center.x + innerRadius * cos(innerAngle),
                y: center.y + innerRadius * sin(innerAngle)
            )
            
            if i == 0 {
                path.move(to: outerPoint)
            } else {
                path.line(to: outerPoint)
            }
            
            path.line(to: innerPoint)
        }
        
        path.close()
        
        // Set fill color to white (template mode will convert it to proper menu bar color)
        NSColor.white.set()
        path.fill()
    }
    
    image.unlockFocus()
    image.isTemplate = true // Makes it work with dark/light mode
    
    return image
}

// AppDelegate to manage the custom window and menu bar extra
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem!
    let viewModel = TimerViewModel.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status item - use variable width for text
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            // Use custom 4-pointed star for the menu bar icon
            button.image = createFourPointedStarImage(size: 18)
            button.imagePosition = .imageLeft
            // Make sure we set the action and target properly
            button.action = #selector(toggleWindow(_:))
            button.target = self
            
            // Set up the callback for menu bar updates
            viewModel.menuBarUpdateCallback = { [weak self] timeString in
                guard let self = self else { return }
                
                // Update on the main thread to be safe
                DispatchQueue.main.async {
                    if let button = self.statusItem.button {
                        if timeString.isEmpty {
                            button.title = ""
                        } else {
                            button.title = " \(timeString)"
                        }
                    }
                }
            }
        }

        // Create a borderless window
        let contentView = ContentView()
        window = AlwaysKeyWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 400),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.hasShadow = true
        window.center()
        window.isReleasedWhenClosed = false
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.contentView = NSHostingView(rootView: contentView)
        
        // Add rounded corners to the window
        window.setFrame(window.frame, display: true)
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 16
        window.contentView?.layer?.masksToBounds = true
        
        // Position the window below the status item when opened
        positionWindowUnderStatusItem()
    }

    @objc func toggleWindow(_ sender: Any?) {
        if window.isVisible {
            window.orderOut(sender)
        } else {
            positionWindowUnderStatusItem()
            window.makeKeyAndOrderFront(sender)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func positionWindowUnderStatusItem() {
        guard let statusBarButton = statusItem.button else { return }
        
        // Get the position of the status item in screen coordinates
        let buttonRect = statusBarButton.window?.convertToScreen(statusBarButton.convert(statusBarButton.bounds, to: nil)) ?? .zero
        
        // Calculate the top-center position below the status item
        let windowWidth = window.frame.width
        let windowX = buttonRect.midX - (windowWidth / 2)
        let windowY = buttonRect.minY - 5  // 5px gap between status bar and window
        
        // Make sure the window stays on screen
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let screenFrame = screen.visibleFrame
        
        var adjustedX = windowX
        if adjustedX < screenFrame.minX {
            adjustedX = screenFrame.minX + 5 // 5px margin from left edge
        } else if adjustedX + windowWidth > screenFrame.maxX {
            adjustedX = screenFrame.maxX - windowWidth - 5 // 5px margin from right edge
        }
        
        // Set the window position
        window.setFrameTopLeftPoint(NSPoint(x: adjustedX, y: windowY))
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
