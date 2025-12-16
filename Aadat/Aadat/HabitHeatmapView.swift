import SwiftUI

struct HabitHeatmapView: View {
    let habit: Habit
    
    private let weeksToDisplay = 52
    private let daysPerWeek = 7
    private let spacing: CGFloat = 3
    private let blockSize: CGFloat = 10
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
                ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(0..<weeksToDisplay, id: \.self) { weekIndex in
                            VStack(spacing: spacing) {
                                ForEach(0..<daysPerWeek, id: \.self) { dayIndex in
                                    if let date = getDateForGrid(weekIndex: weekIndex, dayIndex: dayIndex) {
                                        let isCompleted = isCompletedOnDate(date)
                                        let isToday = Calendar.current.isDateInToday(date)
                                        let isFuture = date > Date()
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(colorForCell(isCompleted: isCompleted, isFuture: isFuture, isToday: isToday))
                                            .frame(width: blockSize, height: blockSize)
                                    } else {
                                        // Fallback for calculation errors
                                        Color.clear
                                            .frame(width: blockSize, height: blockSize)
                                    }
                                }
                            }
                            .id(weekIndex)                             .overlay(alignment: .topLeading) {
                                if let month = getMonthLabel(weekIndex: weekIndex) {
                                    Text(month)
                                        .font(.system(size: 8))
                                        .foregroundColor(.secondary)
                                        .fixedSize()
                                        .offset(y: -12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 20)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(weeksToDisplay - 1, anchor: .trailing)
                    }
                }
            }
            
            HStack(spacing: 12) {
                Spacer()
                Label("Less", systemImage: "circle.fill")
                    .font(.caption2)
                    .foregroundColor(Color(UIColor.secondarySystemFill))
                Label("More", systemImage: "circle.fill")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Date Logic
    
    private func getDateForGrid(weekIndex: Int, dayIndex: Int) -> Date? {
        let calendar = Calendar.current
        let today = Date()
        
        guard let startOfCurrentWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return nil
        }
        
        let weeksAgo = (weeksToDisplay - 1) - weekIndex
        
        guard let startOfTargetWeek = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: startOfCurrentWeek) else {
            return nil
        }
        
        return calendar.date(byAdding: .day, value: dayIndex, to: startOfTargetWeek)
    }
    
    private func isCompletedOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return habit.completionDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    private func colorForCell(isCompleted: Bool, isFuture: Bool, isToday: Bool) -> Color {
        if isFuture {
            return Color.clear
        }
        if isCompleted {
            return .green        }
        if isToday {
            return Color(UIColor.systemFill)
        }
        return Color(UIColor.secondarySystemFill)
    }
    
    // MARK: - Label Helpers
    
    private func getMonthLabel(weekIndex: Int) -> String? {
        guard let date = getDateForGrid(weekIndex: weekIndex, dayIndex: 0) else { return nil }
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        if day >= 1 && day <= 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        }
        return nil
    }
}
