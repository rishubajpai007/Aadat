import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Bindable var habit: Habit
    @EnvironmentObject var viewModel: HabitsViewModel
    @State private var showingEditSheet = false
    @Environment(\.dismiss) var dismiss
    @State private var selectedMonth = Date()
    
    // MARK: - Insights Calculations
    
    private var completionsThisYear: Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        return habit.completionDates.filter { calendar.component(.year, from: $0) == currentYear }.count
    }
    
    private var completionsThisMonth: Int {
        let calendar = Calendar.current
        return habit.completionDates.filter { calendar.isDate($0, equalTo: Date(), toGranularity: .month) }.count
    }
    
    private var completionsThisWeek: Int {
        let calendar = Calendar.current
        return habit.completionDates.filter { calendar.isDate($0, equalTo: Date(), toGranularity: .weekOfYear) }.count
    }
    
    private var successPercentage: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: habit.creationDate)
        let end = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: start, to: end)
        let totalDays = (components.day ?? 0) + 1
        let completions = habit.completionDates.count
        
        let percentage = Double(completions) / Double(max(1, totalDays)) * 100
        return Int(min(100, max(0, percentage)))
    }
    
    var body: some View {
        ZStack {
            // 1. Consistent Background Layer
            BackgroundLayer()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // 2. Interactive Calendar Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("COMPLETION HISTORY")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.5)
                            .padding(.leading, 8)
                        
                        HabitCalendarView(habit: habit, selectedMonth: $selectedMonth)
                    }
                    .padding(.top, 10)
                    
                    // 3. Quick Stats Card
                    HStack(spacing: 16) {
                        let isTopStreak = habit.currentStreak > 0 && habit.currentStreak == habit.longestStreak
                        
                        StatisticCard(
                            value: "\(habit.currentStreak)",
                            label: "Current",
                            icon: "flame.fill",
                            color: .orange,
                            showBadge: isTopStreak
                        )
                        
                        StatisticCard(
                            value: "\(habit.longestStreak)",
                            label: "Best",
                            icon: "trophy.fill",
                            color: habit.category.color,
                            showBadge: false
                        )
                    }
                    
                    // 4. Yearly Consistency (Heatmap)
                    HabitHeatmapView(habit: habit)
                    
                    // 5. Yearly Insights Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PERFORMANCE INSIGHTS")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.5)
                            .padding(.leading, 8)
                        
                        HStack(spacing: 0) {
                            // Updated InsightItems to use success emoji for non-zero values
                            InsightItem(
                                value: completionsThisYear > 0 ? "\(completionsThisYear) ✨" : "0",
                                label: "This Year",
                                color: .indigo
                            )
                            Divider().frame(height: 30).padding(.horizontal, 4)
                            
                            InsightItem(
                                value: completionsThisMonth > 0 ? "\(completionsThisMonth) ✨" : "0",
                                label: "This Month",
                                color: .blue
                            )
                            Divider().frame(height: 30).padding(.horizontal, 4)
                            
                            InsightItem(
                                value: completionsThisWeek > 0 ? "\(completionsThisWeek) ✨" : "0",
                                label: "This Week",
                                color: .teal
                            )
                            Divider().frame(height: 30).padding(.horizontal, 4)
                            
                            InsightItem(value: "\(successPercentage)%", label: "Success", color: .purple)
                        }
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                )
                        )
                    }
                    
                    // 6. Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            showingEditSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Habit Settings")
                            }
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Capsule().fill(.ultraThinMaterial))
                        }
                        
                        Button(role: .destructive) {
                            deleteHabit()
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Delete Habit")
                            }
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Capsule().fill(Color.red.opacity(0.1)))
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            AddHabitView(habitToEdit: habit)
        }
    }
    
    private func deleteHabit() {
        if let index = viewModel.habits.firstIndex(where: { $0.id == habit.id }) {
            viewModel.deleteHabits(offsets: IndexSet(integer: index))
            dismiss()
        }
    }
}

// MARK: - Supporting Components

struct StatisticCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    let showBadge: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Spacer()
                if showBadge {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text("DAYS")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.secondary)
            }
            
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
                .tracking(1.0)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
        )
    }
}

struct InsightItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label.uppercased())
                .font(.system(size: 8, weight: .black))
                .foregroundColor(.secondary)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

struct HabitCalendarView: View {
    let habit: Habit
    @Binding var selectedMonth: Date
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(selectedMonth, format: .dateTime.month(.wide).year())
                    .font(.system(.headline, design: .rounded))
                Spacer()
                HStack(spacing: 12) {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .bold))
                            .padding(8)
                            .background(Circle().fill(Color.primary.opacity(0.05)))
                    }
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .padding(8)
                            .background(Circle().fill(Color.primary.opacity(0.05)))
                    }
                }
            }
            .padding(.horizontal, 4)
            
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            let days = generateDaysInMonth(for: selectedMonth)
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        CalendarDayCell(date: date, habit: habit)
                    } else {
                        Color.clear.frame(height: 32)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
        )
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            withAnimation(.spring()) { selectedMonth = newMonth }
        }
    }
    
    private func generateDaysInMonth(for month: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthInterval.start)) else {
            return []
        }
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = (firstWeekday + 5) % 7
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in 0..<range.count {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        return days
    }
}

struct CalendarDayCell: View {
    let date: Date
    let habit: Habit
    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var isCompleted: Bool { habit.completionDates.contains { Calendar.current.isDate($0, inSameDayAs: date) } }
    
    var body: some View {
        ZStack {
            if isCompleted {
                Circle()
                    .fill(habit.category.color)
                    .frame(width: 30, height: 30)
                    .transition(.scale.combined(with: .opacity))
            } else if isToday {
                Circle()
                    .stroke(habit.category.color, lineWidth: 2)
                    .frame(width: 30, height: 30)
            }
            
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 13, weight: isToday || isCompleted ? .bold : .medium, design: .rounded))
                .foregroundColor(isCompleted ? .white : (isToday ? habit.category.color : .primary))
        }
        .frame(height: 32)
    }
}
