import SwiftUI

struct HabitRowView: View {
    @Bindable var habit: Habit
    @EnvironmentObject var viewModel: HabitsViewModel
    
    @State private var successMessage: String?
    @State private var showMessage = false
    
    private let motivationalQuotes = [
        "Great job! Consistency is key. 🌟",
        "One step closer to your goal! 🚀",
        "You're doing amazing! 💪",
        "Success is the sum of small efforts. ✨",
        "Another day, another win! 🏆",
        "Keep crushing your goals! 🔥",
        "Small steps lead to big changes. 🌱",
        "You've got this! 🌈"
    ]
    
    private var lastSevenDays: [Date] {
        let calendar = Calendar.current
        return (0..<7).map { index in
            calendar.date(byAdding: .day, value: -index, to: Date()) ?? Date()
        }.reversed()
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Category Icon
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
                        DayToggleView(date: date, habit: habit, viewModel: viewModel) {
                            triggerSuccessMessage()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                ZStack {
                    Color(UIColor.secondarySystemGroupedBackground)
                    LinearGradient(
                        colors: [habit.category.color.opacity(0.12), habit.category.color.opacity(0.01)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(habit.category.color.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
            
            if showMessage, let message = successMessage {
                Text(message)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(habit.category.color)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.2), radius: 4)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity).combined(with: .move(edge: .bottom)),
                        removal: .opacity
                    ))
                    .zIndex(1)
                    .offset(y: -40)
            }
        }
    }
    
    private func triggerSuccessMessage() {
        successMessage = motivationalQuotes.randomElement()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showMessage = false
            }
        }
    }
}

// MARK: - Day Toggle Component

struct DayToggleView: View {
    let date: Date
    let habit: Habit
    var viewModel: HabitsViewModel
    var onComplete: (() -> Void)?
    
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
                    .fill(isCompleted ? habit.category.color : Color(UIColor.systemGray5))
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
                
                let wasCompleted = isCompleted
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.toggleCompletion(for: habit, date: date)
                }
                
                if !wasCompleted {
                    onComplete?()
                }
            }
        }
    }
}
