import SwiftUI

struct HabitRowView: View {
    @Bindable var habit: Habit
    @EnvironmentObject var viewModel: HabitsViewModel
    
    private var lastSevenDays: [Date] {
        let calendar = Calendar.current
        return (0..<7).map { index in
            calendar.date(byAdding: .day, value: -index, to: Date()) ?? Date()
        }.reversed()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(habit.category.icon)
                    .font(.title3)
                
                Text(habit.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(habit.currentStreak > 0 ? .orange : .gray.opacity(0.3))
                        .font(.caption)
                    Text("\(habit.currentStreak)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(habit.currentStreak > 0 ? .orange : .secondary)
                }
            }
            
            HStack(spacing: 0) {
                ForEach(lastSevenDays, id: \.self) { date in
                    DayToggleView(date: date, habit: habit, viewModel: viewModel)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct DayToggleView: View {
    let date: Date
    let habit: Habit
    var viewModel: HabitsViewModel
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var isCompleted: Bool {
        viewModel.isCompletedOnDate(habit: habit, date: date)
    }
    
    private var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(dayLetter)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(isToday ? .primary : .secondary)
            
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.blue : Color(UIColor.systemGray5))
                    .frame(width: 32, height: 32)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.toggleCompletion(for: habit, date: date)
                }
            }
        }
    }
}
