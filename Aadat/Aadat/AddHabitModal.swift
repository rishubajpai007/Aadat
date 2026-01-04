import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var viewModel: HabitsViewModel
    @Environment(\.dismiss) var dismiss
    
    var habitToEdit: Habit?
    
    @State private var habitName: String
    @State private var selectedCategory: HabitCategory
    
    // Reminder States
    @State private var isReminderEnabled: Bool
    @State private var reminderTime: Date
    
    init(habitToEdit: Habit? = nil) {
        self.habitToEdit = habitToEdit
        _habitName = State(initialValue: habitToEdit?.name ?? "")
        _selectedCategory = State(initialValue: habitToEdit?.category ?? .other)
        
        if let existingReminder = habitToEdit?.reminderTime {
            _isReminderEnabled = State(initialValue: true)
            _reminderTime = State(initialValue: existingReminder)
        } else {
            _isReminderEnabled = State(initialValue: false)
            var components = DateComponents()
            components.hour = 8
            components.minute = 0
            _reminderTime = State(initialValue: Calendar.current.date(from: components) ?? Date())
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit Name (e.g., Daily Walk)", text: $habitName)
                        .textInputAutocapitalization(.words)
                }
                
                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            Text("\(category.icon) \(category.rawValue)")
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Daily Reminder", isOn: $isReminderEnabled.animation())
                        .onChange(of: isReminderEnabled) { newValue in
                            if newValue {
                                viewModel.requestNotificationPermissions()
                            }
                        }
                    
                    if isReminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .navigationTitle(habitToEdit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(habitToEdit == nil ? "Save" : "Update") {
                        saveOrUpdateHabit()
                    }
                    .fontWeight(.bold)
                    .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveOrUpdateHabit() {
        let trimmedName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalReminderTime = isReminderEnabled ? reminderTime : nil
        
        if let habit = habitToEdit {
            habit.name = trimmedName
            habit.category = selectedCategory
            habit.reminderTime = finalReminderTime
            
            if isReminderEnabled {
                viewModel.scheduleNotification(for: habit)
            } else {
                viewModel.cancelNotification(for: habit)
            }
            
        } else {
            viewModel.addHabit(
                name: trimmedName,
                category: selectedCategory,
                reminderTime: finalReminderTime
            )
        }
        
        dismiss()
    }
}
