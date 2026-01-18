import Foundation
import SwiftData

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    var name: String
    var creationDate: Date
    private var completionDatesData: Data
    var category: HabitCategory = HabitCategory.other
    var reminderTime: Date?
    
    var completionDates: [Date] {
        get {
            guard !completionDatesData.isEmpty else { return [] }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                return try decoder.decode([Date].self, from: completionDatesData)
            } catch {
                return []
            }
        }
        set {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .secondsSince1970
                completionDatesData = try encoder.encode(newValue)
            } catch {
            }
        }
    }
    
    init(name: String, category: HabitCategory = .other, reminderTime: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.creationDate = Date()
        self.category = category
        self.reminderTime = reminderTime
        self.completionDatesData = Data("[]".utf8)
    }
    
    // MARK: - Streak Calculation (Daily)
    var currentStreak: Int {
        let dates = completionDates
        guard !dates.isEmpty else { return 0 }

        let calendar = Calendar.current
        let uniqueSortedDays = Set(dates.map { calendar.startOfDay(for: $0) })
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
        let dates = completionDates
        guard !dates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let uniqueSortedDays = Array(Set(dates.map { calendar.startOfDay(for: $0) })).sorted()
        
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

