import SwiftUI

struct ConcentrationModeView: View {
    
    @StateObject private var viewModel = ConcentrationModeViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationView {
            ZStack {
                // 1. Consistent Background Layer
                BackgroundLayer()
                
                VStack(spacing: 0) {
                    // 2. Custom Navigation Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DEEP WORK")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.5)
                        
                        Text("Concentration")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    Spacer()

                    // 3. Interactive Focus Ring
                    ZStack {
                        Circle()
                            .fill(viewModel.isRunning ? Color.blue.opacity(0.1) : Color.clear)
                            .blur(radius: 40)
                            .frame(width: 260, height: 260)

                        Circle()
                            .stroke(Color.primary.opacity(0.05), lineWidth: 20)
                            .frame(width: 280, height: 280)

                        Circle()
                            .trim(from: 0, to: 1.0 - viewModel.progress)
                            .stroke(
                                LinearGradient(
                                    colors: viewModel.isRunning ? [.blue, .cyan] : [.gray.opacity(0.3), .gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 280, height: 280)
                            .animation(.linear(duration: 0.1), value: viewModel.timeRemaining)
                        
                        VStack(spacing: 8) {
                            Text(viewModel.timeString)
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(.primary)
                            
                            if viewModel.duration > 0 && !viewModel.isRunning && !viewModel.isFaceDown {
                                VStack(spacing: 6) {
                                    Image(systemName: "iphone.smartrectangle.rotate.right")
                                        .font(.title3)
                                        .symbolEffect(.bounce,options: .repeat(.continuous))
                                    Text("Flip to Focus")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.orange)
                                .transition(.opacity.combined(with: .scale))
                            } else {
                                Text(viewModel.isRunning ? "Focused" : (viewModel.duration > 0 ? "Paused" : "Set Timer"))
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.isRunning ? .blue : .secondary)
                                    .textCase(.uppercase)
                                    .tracking(1.2)
                            }
                        }
                    }
                    .padding(.vertical, 40)
                    
                    Spacer()
                    
                    // 4. Control Panel (Glassmorphic)
                    VStack(spacing: 24) {
                        Text("Session Duration")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.0)
                        
                        HStack(spacing: 12) {
                            ForEach(FocusDuration.allCases, id: \.self) { durationCase in
                                FocusDurationButton(
                                    minutes: durationCase.minutes,
                                    isSelected: TimeInterval(durationCase.minutes * 60) == viewModel.duration,
                                    isRunning: viewModel.isRunning,
                                    action: { viewModel.setDurationAndToggle(minutes: durationCase.minutes) }
                                )
                            }
                        }
                        
                        Button(action: {
                            viewModel.playSelectionHaptic()
                            withAnimation(.spring()) {
                                viewModel.stopTimer()
                            }
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("End Session")
                            }
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(viewModel.duration > 0 ? Color.red.opacity(0.8) : Color.gray.opacity(0.2))
                            )
                            .shadow(color: viewModel.duration > 0 ? Color.red.opacity(0.2) : Color.clear, radius: 10, y: 5)
                        }
                        .disabled(viewModel.duration == 0)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    viewModel.appDidBecomeActive()
                }
            }
        }
    }
}

// MARK: - Components

struct FocusDurationButton: View {
    let minutes: Int
    let isSelected: Bool
    let isRunning: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(minutes)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isSelected ? (isRunning ? Color.blue : Color.orange) : Color.primary.opacity(0.03))
                )
                .foregroundColor(isSelected ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isSelected ? Color.clear : Color.primary.opacity(0.05), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
