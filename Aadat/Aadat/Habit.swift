import Foundation
import SwiftData

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    var name: String
    var creationDate: Date
    var completionDates: [Date]
    var category: HabitCategory = HabitCategory.other
    var reminderTime: Date? 
    
    init(name: String, category: HabitCategory = .other, reminderTime: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.creationDate = Date()
        self.completionDates = []
        self.category = category
        self.reminderTime = reminderTime
    }
    
    // MARK: - Streak Calculation (Daily)
    var currentStreak: Int {
        guard !completionDates.isEmpty else { return 0 }

        let calendar = Calendar.current
        let uniqueSortedDays = Set(completionDates.map { calendar.startOfDay(for: $0) })
            .sorted()

        var streak = 0
        var checkingDate = calendar.startOfDay(for: Date())
        
        if !uniqueSortedDays.contains(where: { calendar.isDate($0, inSameDayAs: checkingDate) }) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkingDate),
                  uniqueSortedDays.contains(where: { calendar.isDate($0, inSameDayAs: yesterday) }) else {
                return 0
            }
            checkingDate = yesterday
        }
        
        while uniqueSortedDays.contains(where: { calendar.isDate($0, inSameDayAs: checkingDate) }) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkingDate) else { break }
            checkingDate = previousDay
        }

        return streak
    }
    
    // MARK: - Longest Streak (All-time)
    var longestStreak: Int {
        guard !completionDates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        // Unique days, sorted ascending
        let uniqueSortedDays = Array(Set(completionDates.map { calendar.startOfDay(for: $0) })).sorted()
        
        var longest = 1
        var current = 1
        
        for i in 1..<uniqueSortedDays.count {
            let prev = uniqueSortedDays[i - 1]
            let curr = uniqueSortedDays[i]
            if let nextOfPrev = calendar.date(byAdding: .day, value: 1, to: prev),
               calendar.isDate(nextOfPrev, inSameDayAs: curr) {
                current += 1
            } else {
                longest = max(longest, current)
                current = 1
            }
        }
        longest = max(longest, current)
        return longest
    }
}

