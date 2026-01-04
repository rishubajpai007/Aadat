import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var viewModel: HabitsViewModel
    @Environment(\.dismiss) var dismiss
    
    var habitToEdit: Habit?
    @State private var habitName: String
    
    init(habitToEdit: Habit? = nil) {
        self.habitToEdit = habitToEdit
        _habitName = State(initialValue: habitToEdit?.name ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Habit Details") {
                    TextField("Habit Name (e.g., Read 10 pages)", text: $habitName)
                }
            }
            .navigationTitle(habitToEdit == nil ? "New Habit" : "Edit Habit")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(habitToEdit == nil ? "Save" : "Update") {
                        saveOrUpdateHabit()
                    }
                    .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveOrUpdateHabit() {
        let trimmedName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let habit = habitToEdit {
            habit.name = trimmedName
        } else {
            viewModel.addHabit(name: trimmedName)
        }
        dismiss()
    }
}
