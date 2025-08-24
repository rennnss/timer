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
                    .cornerRadius(16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(16)
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
    @StateObject private var viewModel = TimerViewModel.shared
    @State private var selectedTab = 0

    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 5) {
                ZStack {
                    TimerView(viewModel: viewModel)
                        .opacity(selectedTab == 0 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    
                    StopwatchView(viewModel: viewModel)
                        .opacity(selectedTab == 1 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // This prevents the default tab bar from showing
                
                // Custom dots indicator that's integrated with the design
                HStack(spacing: 8) {
                    ForEach(0..<2) { index in
                        Circle()
                            .fill(selectedTab == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                            .scaleEffect(selectedTab == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = index
                                }
                            }
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .frame(width: 350, height: 400)
        .padding(1) // Add slight padding for the border
    }
}

struct TimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    @State private var hours: Double = 0
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
            hours = floor(totalSeconds / 3600)
            let remainingSeconds = totalSeconds.truncatingRemainder(dividingBy: 3600)
            minutes = floor(remainingSeconds / 60)
            seconds = remainingSeconds.truncatingRemainder(dividingBy: 60)
        }
    }

    private var runningView: some View {
        VStack(spacing: 20) {
            VStack {
                Text(timeString(from: viewModel.timeRemaining))
                    .font(.system(size: viewModel.timeRemaining.fontSizeForDisplay(), weight: .bold, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(minWidth: 200)
                    .contentTransition(.numericText())
                
                PulseEffectView(progress: viewModel.timeRemaining / viewModel.selectedTime)
                    .padding(.vertical, 10)
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
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Hours picker
                    VStack {
                        Button(action: {
                            hours += 1
                            updateSelectedTime()
                        }) {
                            Image(systemName: "chevron.up")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("\(Int(hours))")
                            .font(.system(size: 48, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 70)
                        
                        Button(action: {
                            if hours > 0 {
                                hours -= 1
                                updateSelectedTime()
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("HR")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Text(":")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .offset(y: -12)
                
                    // Minutes picker
                    VStack {
                        Button(action: {
                            if minutes < 59 {
                                minutes += 1
                                updateSelectedTime()
                            } else {
                                minutes = 0
                                hours += 1
                                updateSelectedTime()
                            }
                        }) {
                            Image(systemName: "chevron.up")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("\(Int(minutes))")
                            .font(.system(size: 48, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 70)
                        
                        Button(action: {
                            if minutes > 0 {
                                minutes -= 1
                                updateSelectedTime()
                            } else if hours > 0 {
                                minutes = 59
                                hours -= 1
                                updateSelectedTime()
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("MIN")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Text(":")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .offset(y: -12)
                    
                    // Seconds picker
                    VStack {
                        Button(action: {
                            if seconds < 59 {
                                seconds += 1
                                updateSelectedTime()
                            } else {
                                seconds = 0
                                if minutes < 59 {
                                    minutes += 1
                                } else {
                                    minutes = 0
                                    hours += 1
                                }
                                updateSelectedTime()
                            }
                        }) {
                            Image(systemName: "chevron.up")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("\(Int(seconds))")
                            .font(.system(size: 48, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 70)
                        
                        Button(action: {
                            if seconds > 0 {
                                seconds -= 1
                                updateSelectedTime()
                            } else if minutes > 0 {
                                seconds = 59
                                minutes -= 1
                                updateSelectedTime()
                            } else if hours > 0 {
                                seconds = 59
                                minutes = 59
                                hours -= 1
                                updateSelectedTime()
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("SEC")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 10)
            }

            Button(action: {
                withAnimation {
                    viewModel.start()
                }
            }) {
                Text("Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 140, height: 44)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 10)
        }
    }

    private func updateSelectedTime() {
        let totalSeconds = TimeInterval(Int(hours) * 3600 + Int(minutes) * 60 + Int(seconds))
        viewModel.setTime(seconds: totalSeconds)
    }
    
    private func fontSizeForTime(_ time: TimeInterval) -> CGFloat {
        let hours = Int(time) / 3600
        
        if hours > 0 {
            return 40  // Smaller font when hours are displayed
        } else {
            return 48  // Normal font size for minutes:seconds
        }
    }

    private func timeString(from time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
        }
    }
    

}

struct StopwatchView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(timeString(from: viewModel.stopwatchTime))
                .font(.system(size: viewModel.stopwatchTime.fontSizeForDisplay(), weight: .bold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(minWidth: 200)
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
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
        }
    }
    

}



// Helper extension for time formatting
extension TimeInterval {
    func fontSizeForDisplay() -> CGFloat {
        let hours = Int(self) / 3600
        if hours > 0 {
            return 36 // Smaller font for hours format
        } else {
            return 48 // Larger font for minutes:seconds format
        }
    }
    
    func menuBarString() -> String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct PulseEffectView: View {
    var progress: Double
    @State private var isPulsing = false
    
    // Calculate values based on progress
    private var intensity: Double {
        // Intensity increases as time runs out
        return 1.0 - progress
    }
    
    private var color: Color {
        // Color transitions from blue to green to yellow to orange to red
        if progress > 0.8 {
            return Color.blue
        } else if progress > 0.6 {
            return Color.green
        } else if progress > 0.4 {
            return Color.yellow
        } else if progress > 0.2 {
            return Color.orange
        } else {
            return Color.red
        }
    }
    
    private var scale: CGFloat {
        return isPulsing ? 1.05 : 1.0
    }
    
    private var pulseSpeed: Double {
        // Pulse gets faster as time runs out
        return max(0.3, 1.0 - intensity * 0.7)
    }
    
    var body: some View {
        ZStack {
            // Main progress circle
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .scaleEffect(scale)
                .animation(Animation.easeInOut(duration: pulseSpeed).repeatForever(autoreverses: true), value: isPulsing)
            
            // Glow effect
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .scaleEffect(scale + 0.05)
                .blur(radius: 8 * CGFloat(intensity))
                .animation(Animation.easeInOut(duration: pulseSpeed).repeatForever(autoreverses: true), value: isPulsing)
                
            // Progress text in the middle
            VStack {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 140, height: 140)
        .onAppear {
            isPulsing = true
        }
    }
}
