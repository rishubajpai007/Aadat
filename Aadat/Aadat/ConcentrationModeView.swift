import SwiftUI

struct ConcentrationModeView: View {
    
    @StateObject private var viewModel = ConcentrationModeViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationView {
            VStack {
                // MARK: Animated Clock Display
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 24)
                        .frame(width: 280, height: 280)

                    Circle()
                        .trim(from: 0, to: 1.0 - viewModel.progress)
                        .stroke(
                            viewModel.isRunning ? Color.blue.opacity(0.8) : Color.gray.opacity(0.5),
                            style: StrokeStyle(lineWidth: 24, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 280, height: 280)
                        .animation(.linear(duration: 0.1), value: viewModel.timeRemaining)
                    
                    VStack(spacing: 8) {
                        Text(viewModel.timeString)
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        if viewModel.duration > 0 && !viewModel.isRunning && !viewModel.isFaceDown {
                            VStack {
                                Image(systemName: "iphone.smartrectangle.rotate.right")
                                    .font(.title)
                                    .foregroundColor(.orange)
                                    .padding(.top, 5)
                                Text("Flip phone to start")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                            .transition(.opacity)
                        } else {
                            Text(viewModel.isRunning ? "Focus Session" : (viewModel.duration > 0 ? "Paused" : "Set Duration"))
                                .font(.headline)
                                .foregroundColor(viewModel.isRunning ? .blue : .gray)
                        }
                    }
                }
                .padding(.top, 50)
                
                Spacer()
                
                // MARK: Duration Options
                VStack(spacing: 20) {
                    Text("Select Focus Time")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        ForEach(FocusDuration.allCases, id: \.self) { durationCase in
                            DurationButton(
                                minutes: durationCase.minutes,
                                viewModel: viewModel
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.playSelectionHaptic()
                        withAnimation {
                            viewModel.stopTimer()
                        }
                    }) {
                        Text("Stop & Reset")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.duration > 0 ? Color.red.opacity(0.7) : Color(.systemGray4))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.duration == 0)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Focus Mode")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    viewModel.appDidBecomeActive()
                }
            }
        }
    }
}

struct DurationButton: View {
    let minutes: Int
    @ObservedObject var viewModel: ConcentrationModeViewModel
    
    var body: some View {
        let isSelected = TimeInterval(minutes * 60) == viewModel.duration && viewModel.duration > 0
        
        Button(action: {
            viewModel.setDurationAndToggle(minutes: minutes)
        }) {
            Text("\(minutes) min")
                .font(.headline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(isSelected ? (viewModel.isRunning ? Color.blue : Color.orange) : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
        }
    }
}
