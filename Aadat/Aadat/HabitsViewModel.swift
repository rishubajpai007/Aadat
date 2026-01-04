import Foundation
import SwiftData
import SwiftUI
import Combine

class HabitsViewModel: ObservableObject {
    let modelContainer: ModelContainer
    @Published var habits: [Habit] = []
    
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
    
    @MainActor
    private func fetchHabits() async {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\Habit.creationDate, order: .reverse)])
        do {
            let context = modelContainer.mainContext
            self.habits = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch: \(error)")
        }
    }
    
    @MainActor
    func addHabit(name: String) {
        let newHabit = Habit(name: name)
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
    
    func isCompletedOnDate(habit: Habit, date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return habit.completionDates.contains { Calendar.current.isDate($0, inSameDayAs: startOfDay) }
    }
    
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
