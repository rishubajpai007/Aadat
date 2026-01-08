import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @EnvironmentObject var viewModel: HabitsViewModel
    
    private var isCompletedToday: Bool {
        viewModel.isCompletedOnDate(habit: habit, date: Date())
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. Category Icon with Soft Background
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(habit.category.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Text(habit.category.icon)
                    .font(.system(size: 24))
            }
            
            // 2. Habit Info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundColor(habit.currentStreak > 0 ? .orange : .secondary)
                    
                    Text("\(habit.currentStreak) day streak")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 3. Modern Completion Toggle
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.toggleCompletion(for: habit)
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(isCompletedToday ? habit.category.color : Color(.systemGray4), lineWidth: 2)
                        .frame(width: 32, height: 32)
                    
                    if isCompletedToday {
                        Circle()
                            .fill(habit.category.color)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        )
    }
}
