import Foundation
import SwiftData

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    var name: String
    var creationDate: Date
    
    var targetFrequency: Int
    var targetUnit: HabitUnit
    var completionDates: [Date]
    
    init(name: String, targetFrequency: Int, targetUnit: HabitUnit) {
        self.id = UUID()
        self.name = name
        self.creationDate = Date()
        self.targetFrequency = targetFrequency
        self.targetUnit = targetUnit
        self.completionDates = []
    }
    
    // MARK: - Phase 3: Streak Calculation
    var currentStreak: Int {
        guard !completionDates.isEmpty else { return 0 }

        let calendar = Calendar.current
        let uniqueSortedDays = Set(completionDates.map { calendar.startOfDay(for: $0) })
            .sorted()

        var streak = 0
        var checkingDate = calendar.startOfDay(for: Date())
        
        if !uniqueSortedDays.contains(where: { calendar.isDate($0, inSameDayAs: checkingDate) }) {
            guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: checkingDate),
                  uniqueSortedDays.contains(where: { calendar.isDate($0, inSameDayAs: yesterday) }) else {
                return 0
            }
            checkingDate = yesterday
        }
        while uniqueSortedDays.contains(where: { calendar.isDate($0, inSameDayAs: checkingDate) }) {
            streak += 1
            // Move back one day
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkingDate) else { break }
            checkingDate = previousDay
        }

        return streak
    }
}
