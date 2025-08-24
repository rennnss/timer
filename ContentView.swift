
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var timeInput: String = "300"

    var body: some View {
        VStack(spacing: 0) {
            // The main content view that switches with an animation
            if viewModel.isRunning || viewModel.timeRemaining < viewModel.selectedTime {
                runningView
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
            } else {
                setupView
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
            }
        }
        .frame(width: 280)
        // Enhanced liquid glass effect
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .onAppear {
            timeInput = String(format: "%.0f", viewModel.selectedTime)
        }
    }

    // The view for when the timer is running or paused
    private var runningView: some View {
        VStack(spacing: 12) {
            Text(timeString(from: viewModel.timeRemaining))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .contentTransition(.numericText())
                .padding(.top, 20)

            HStack(spacing: 12) {
                Button(action: {
                    withAnimation {
                        if viewModel.isRunning {
                            viewModel.pause()
                        } else {
                            viewModel.resume()
                        }
                    }
                }) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background {
                            Circle()
                                .fill(.thinMaterial)
                                .overlay {
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.8))
                                        .overlay {
                                            Circle()
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        }
                                }
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    withAnimation {
                        viewModel.reset()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background {
                            Circle()
                                .fill(.regularMaterial)
                                .overlay {
                                    Circle()
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                }
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                        }
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 20)
        }
    }

    // The view for setting up the timer
    private var setupView: some View {
        VStack(spacing: 20) {
            Text("Set Timer (seconds)")
                .font(.headline)

            TextField("Seconds", text: $timeInput)
                .multilineTextAlignment(.center)
                .font(.title2)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    Capsule()
                        .fill(.regularMaterial)
                        .overlay {
                            Capsule()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .onChange(of: timeInput) {
                    if let value = TimeInterval(timeInput) {
                        viewModel.setTime(seconds: value)
                    }
                }

            HStack {
                presetButton(minutes: 5)
                presetButton(minutes: 15)
                presetButton(minutes: 30)
            }

            Button(action: {
                withAnimation {
                    viewModel.start()
                }
            }) {
                Text("Start Timer")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        Capsule()
                            .fill(.thinMaterial)
                            .overlay {
                                Capsule()
                                    .fill(Color.accentColor.opacity(0.9))
                                    .overlay {
                                        Capsule()
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    }
                            }
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
    }

    private func presetButton(minutes: Int) -> some View {
        Button("\(minutes) min") {
            let seconds = TimeInterval(minutes * 60)
            withAnimation {
                viewModel.setTime(seconds: seconds)
                timeInput = String(format: "%.0f", seconds)
            }
        }
        .buttonStyle(.borderedProminent)
        .clipShape(Capsule())
    }

    // Formats TimeInterval to a MM:SS.ss string
    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
