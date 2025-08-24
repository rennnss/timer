
import Foundation
import Combine
import UserNotifications

class TimerViewModel: ObservableObject {
    // Timer properties
    @Published var timeRemaining: TimeInterval = 300
    @Published var selectedTime: TimeInterval = 300
    @Published var isRunning = false
    private var timer: AnyCancellable?

    // Stopwatch properties
    @Published var stopwatchTime: TimeInterval = 0
    @Published var isStopwatchRunning = false
    private var stopwatchTimer: AnyCancellable?

    init() {
        requestNotificationPermission()
    }

    // Timer methods
    func start() {
        timeRemaining = selectedTime
        isRunning = true
        timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 0.01
            } else {
                self.pause()
                self.sendNotification()
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.cancel()
    }

    func resume() {
        isRunning = true
        timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 0.01
            } else {
                self.pause()
            }
        }
    }

    func reset() {
        isRunning = false
        timer?.cancel()
        timeRemaining = selectedTime
    }

    func setTime(seconds: TimeInterval) {
        selectedTime = seconds
        timeRemaining = seconds
    }

    // Stopwatch methods
    func startStopwatch() {
        isStopwatchRunning = true
        stopwatchTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            self.stopwatchTime += 0.01
        }
    }

    func stopStopwatch() {
        isStopwatchRunning = false
        stopwatchTimer?.cancel()
    }

    func resetStopwatch() {
        isStopwatchRunning = false
        stopwatchTimer?.cancel()
        stopwatchTime = 0
    }

    // Notification methods
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }

    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Timer Finished!"
        content.body = "Your timer has ended."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
