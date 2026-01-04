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
    
    var body: some View {
        List {
            Section {
                HabitCalendarView(habit: habit, selectedMonth: $selectedMonth)
                    .padding(.vertical, 8)
            }
            .listRowInsets(EdgeInsets())
            
            Section {
                let isTopStreak = habit.currentStreak > 0 && habit.currentStreak == habit.longestStreak
                
                HStack {
                    StatisticView(
                        value: "\(habit.currentStreak)\(isTopStreak ? " 🔥" : "")",
                        label: "Current Streak",
                        color: .orange
                    )
                    
                    Divider()
                    
                    StatisticView(
                        value: "\(habit.longestStreak)\(isTopStreak ? " 🔥" : "")",
                        label: "Longest Streak",
                        color: habit.category.color
                    )
                }
            }
            .listRowSeparator(.hidden)
            .padding(.vertical, 8)

            Section(header: Text("Yearly Consistency")) {
                HabitHeatmapView(habit: habit)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            Section(header: Text("Yearly Insights")) {
                HStack(spacing: 0) {
                    InsightItem(value: "\(completionsThisYear)", label: "This Year", color: .indigo)
                    
                    Divider().frame(height: 35)
                    
                    InsightItem(value: "\(completionsThisMonth)", label: "This Month", color: .blue)
                    
                    Divider().frame(height: 35)
                    
                    InsightItem(value: "\(completionsThisWeek)", label: "This Week", color: .teal)
                }
                .padding(.vertical, 16)
            }
            .listRowBackground(Color(UIColor.secondarySystemGroupedBackground))
            
            Section("Details") {
                HStack {
                    Text("Category")
                    Spacer()
                    Text("\(habit.category.icon) \(habit.category.rawValue)")
                        .foregroundColor(.secondary)
                }
                
                if let reminder = habit.reminderTime {
                    HStack {
                        Text("Reminder")
                        Spacer()
                        Text(reminder, style: .time)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Created")
                    Spacer()
                    Text(habit.creationDate, style: .date)
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button("Edit Habit") { showingEditSheet = true }
                Button("Delete Habit", role: .destructive) { deleteHabit() }
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

// MARK: - Insights Component

struct InsightItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Habit Calendar View

struct HabitCalendarView: View {
    let habit: Habit
    @Binding var selectedMonth: Date
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(selectedMonth, format: .dateTime.month(.wide).year())
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal)
            
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            let days = generateDaysInMonth(for: selectedMonth)
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        CalendarDayCell(date: date, habit: habit)
                    } else {
                        Color.clear
                            .frame(height: 32)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            withAnimation {
                selectedMonth = newMonth
            }
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
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var isCompleted: Bool {
        habit.completionDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isCompleted ? habit.category.color : Color.clear)
                    .frame(width: 32, height: 32)
                
                if isToday && !isCompleted {
                    Circle()
                        .stroke(habit.category.color, lineWidth: 2)
                        .frame(width: 32, height: 32)
                }
                
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .bold : .medium))
                    .foregroundColor(isCompleted ? .white : (isToday ? habit.category.color : .primary))
            }
        }
        .frame(height: 32)
    }
}

// MARK: - Statistic View

struct StatisticView: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
