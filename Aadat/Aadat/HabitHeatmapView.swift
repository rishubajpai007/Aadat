import SwiftUI

struct HabitHeatmapView: View {
    let habit: Habit
    @Environment(\.colorScheme) private var colorScheme

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
                                            .fill(colorForCell(
                                                isCompleted: isCompleted,
                                                isFuture: isFuture,
                                                isToday: isToday
                                            ))
                                            .frame(width: blockSize, height: blockSize)
                                    } else {
                                        Color.clear
                                            .frame(width: blockSize, height: blockSize)
                                    }
                                }
                            }
                            .id(weekIndex)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(weeksToDisplay - 1, anchor: .trailing)
                    }
                }
            }

            HStack(spacing: 12) {
                Label("Less", systemImage: "circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Label("More", systemImage: "circle.fill")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.05),
            radius: 5,
            x: 0,
            y: 2
        )
    }

    private func getDateForGrid(weekIndex: Int, dayIndex: Int) -> Date? {
        let calendar = Calendar.current
        let today = Date()

        guard let startOfCurrentWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        ) else { return nil }

        let weeksAgo = (weeksToDisplay - 1) - weekIndex
        guard let startOfTargetWeek = calendar.date(
            byAdding: .weekOfYear,
            value: -weeksAgo,
            to: startOfCurrentWeek
        ) else { return nil }

        return calendar.date(byAdding: .day, value: dayIndex, to: startOfTargetWeek)
    }

    private func isCompletedOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return habit.completionDates.contains {
            calendar.isDate($0, inSameDayAs: date)
        }
    }

    private func colorForCell(isCompleted: Bool, isFuture: Bool, isToday: Bool) -> Color {
        if isFuture {
            return .clear
        }
        if isCompleted {
            return .green
        }
        if isToday {
            return Color.secondary.opacity(0.4)
        }
        return Color.secondary.opacity(0.2)
    }
}

