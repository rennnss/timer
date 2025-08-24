
import Foundation
import Combine

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: TimeInterval = 300
    @Published var selectedTime: TimeInterval = 300 // Default to 5 minutes (300 seconds)
    @Published var isRunning = false

    private var timer: AnyCancellable?

    func start() {
        // Set the timer to start from the selected value
        timeRemaining = selectedTime
        isRunning = true
        
        timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 0.01
            } else {
                self.pause()
                // Optionally add a sound or notification here
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
}
