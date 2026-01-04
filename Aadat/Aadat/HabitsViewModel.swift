import Foundation
import SwiftData
import SwiftUI
import Combine
import UserNotifications

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
    func addHabit(name: String, category: HabitCategory, reminderTime: Date?) {
        let newHabit = Habit(name: name, category: category, reminderTime: reminderTime)
        modelContainer.mainContext.insert(newHabit)
        
        if let _ = reminderTime {
            scheduleNotification(for: newHabit)
        }
        
        Task { await fetchHabits() }
    }
    
    @MainActor
    func deleteHabits(offsets: IndexSet) {
        offsets.forEach { index in
            let habit = habits[index]
            cancelNotification(for: habit)
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
    
    // MARK: - Notification Management
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for habit: Habit) {
        guard let reminderTime = habit.reminderTime else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for your habit!"
        content.body = "Don't forget to: \(habit.name) \(habit.category.icon)"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: habit.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelNotification(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }
}
