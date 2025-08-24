
import SwiftUI

@main
struct TimerApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            // You can use any SF Symbol here. "timer" is a good choice.
            Image(systemName: "timer")
        }
        .menuBarExtraStyle(.window)
    }
}
