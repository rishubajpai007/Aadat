import SwiftUI

struct HabitRowView: View {
    @Bindable var habit: Habit
    @EnvironmentObject var viewModel: HabitsViewModel
    
    var isCompletedToday: Bool {
        viewModel.isCompletedOnDate(habit: habit, date: Date())
    }
    
    var currentProgress: Double {
        isCompletedToday ? 1.0 : 0.0
    }
    
    var body: some View {
        // MARK: Wrapped in NavigationLink for Phase 4
        NavigationLink(destination: HabitDetailView(habit: habit)) {
            HStack {
                // MARK: 1. Completion Toggle & Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 28, height: 28)

                    Circle()
                        .trim(from: 0, to: currentProgress)
                        .stroke(isCompletedToday ? .green : .blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.5), value: currentProgress)

                    Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isCompletedToday ? .green : .gray)
                }
                .onTapGesture {
                    viewModel.toggleCompletion(for: habit)
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
                .padding(.trailing, 8)
                
                VStack(alignment: .leading) {
                    Text(habit.name)
                        .font(.headline)
                    
                    Text("Target: \(habit.targetFrequency) per \(habit.targetUnit.displayName.lowercased())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // MARK: 3. Streak Display
                VStack(alignment: .trailing) {
                    Text("\(habit.currentStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(habit.currentStreak > 0 ? .orange : .secondary)
                    Text("Streak")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
