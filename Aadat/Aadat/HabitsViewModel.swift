import Foundation
import SwiftData
import SwiftUI
import Combine

class HabitsViewModel: ObservableObject {
    
    let modelContainer: ModelContainer
    
    @Published var habits: [Habit] = []
    
    // MARK: Initialization
    
    init() {
        let schema = Schema([Habit.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        Task { await fetchHabits() }
    }
    
    // MARK: Data Fetch & Delete
    
    @MainActor
    private func fetchHabits() async {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\Habit.creationDate, order: .reverse)])
        
        do {
            let context = modelContainer.mainContext
            self.habits = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch habits: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func addHabit(name: String, frequency: Int, unit: HabitUnit) {
        let newHabit = Habit(name: name, targetFrequency: frequency, targetUnit: unit)
        modelContainer.mainContext.insert(newHabit)
        Task { await fetchHabits() }
    }
    
    @MainActor
    func deleteHabits(offsets: IndexSet) {
        offsets.forEach { index in
            let habit = habits[index]
            modelContainer.mainContext.delete(habit)
        }
        Task { await fetchHabits() }
    }
    
    // MARK: - Completion Status Helpers (FIX FOR COMPILER ERROR)
    
    func isCompletedOnDate(habit: Habit, date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        return habit.completionDates.contains {
            Calendar.current.isDate($0, inSameDayAs: startOfDay)
        }
    }
    
    // MARK: Tracking Operation
    
    @MainActor
    func toggleCompletion(for habit: Habit, date: Date = Date()) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        if isCompletedOnDate(habit: habit, date: startOfDay) {
            habit.completionDates.removeAll { Calendar.current.isDate($0, inSameDayAs: startOfDay) }
        } else {
            habit.completionDates.append(startOfDay)
        }
        
        try? modelContainer.mainContext.save()
        objectWillChange.send()
    }
}
