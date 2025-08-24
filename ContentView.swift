import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

struct GlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                VisualEffectView(material: .popover, blendingMode: .behindWindow)
            )
    }
}

struct GlassEffectContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .modifier(GlassEffect())
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var selectedTab = 0

    var body: some View {
        GlassEffectContainer {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Timer").tag(0)
                    Text("Stopwatch").tag(1)
                    Text("Settings").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                TabView(selection: $selectedTab) {
                    TimerView(viewModel: viewModel)
                        .tag(0)
                    StopwatchView(viewModel: viewModel)
                        .tag(1)
                    SettingsView()
                        .tag(2)
                }
            }
        }
        .frame(width: 350, height: 400)
    }
}

struct TimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    @State private var minutes: Double = 5
    @State private var seconds: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isRunning || viewModel.timeRemaining < viewModel.selectedTime {
                runningView
            } else {
                setupView
            }
        }
        .padding()
        .onAppear {
            let totalSeconds = viewModel.selectedTime
            minutes = floor(totalSeconds / 60)
            seconds = totalSeconds.truncatingRemainder(dividingBy: 60)
        }
    }

    private var runningView: some View {
        VStack(spacing: 20) {
            VStack {
                Text(timeString(from: viewModel.timeRemaining))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText())
                
                ProgressView(value: viewModel.timeRemaining, total: viewModel.selectedTime)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
            }

            HStack(spacing: 20) {
                Button(action: {
                    if viewModel.isRunning {
                        viewModel.pause()
                    } else {
                        viewModel.resume()
                    }
                }) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    viewModel.reset()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var setupView: some View {
        VStack(spacing: 30) {
            Text("Set Timer")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 10) {
                HStack {
                    Text("Minutes: \(Int(minutes))")
                    Slider(value: $minutes, in: 0...59, step: 1)
                }
                HStack {
                    Text("Seconds: \(Int(seconds))")
                    Slider(value: $seconds, in: 0...59, step: 1)
                }
            }
            .onChange(of: minutes) { updateSelectedTime() }
            .onChange(of: seconds) { updateSelectedTime() }

            Button(action: {
                withAnimation {
                    viewModel.start()
                }
            }) {
                Text("Start Timer")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func updateSelectedTime() {
        let totalSeconds = TimeInterval(Int(minutes) * 60 + Int(seconds))
        viewModel.setTime(seconds: totalSeconds)
    }

    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

struct StopwatchView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(timeString(from: viewModel.stopwatchTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .contentTransition(.numericText())
                .padding(20)

            HStack(spacing: 20) {
                Button(action: {
                    if viewModel.isStopwatchRunning {
                        viewModel.stopStopwatch()
                    } else {
                        viewModel.startStopwatch()
                    }
                }) {
                    Image(systemName: viewModel.isStopwatchRunning ? "pause.fill" : "play.fill")
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    viewModel.resetStopwatch()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }

    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

struct SettingsView: View {
    @State private var showMilliseconds = true
    @State private var enableNotifications = true

    var body: some View {
        Form {
            Toggle("Show Milliseconds", isOn: $showMilliseconds)
            Toggle("Enable Notifications", isOn: $enableNotifications)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
