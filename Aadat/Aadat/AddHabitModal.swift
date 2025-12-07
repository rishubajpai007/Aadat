import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var viewModel: HabitsViewModel
    @Environment(\.dismiss) var dismiss
    
    var habitToEdit: Habit?
    
    @State private var habitName: String
    @State private var targetFrequency: Int
    @State private var targetUnit: HabitUnit
    
    private let availableFrequencies = Array(1...7)
    
    init(habitToEdit: Habit? = nil) {
        self.habitToEdit = habitToEdit
        
        // Initialize state variables based on the habit being edited, or defaults
        _habitName = State(initialValue: habitToEdit?.name ?? "")
        _targetFrequency = State(initialValue: habitToEdit?.targetFrequency ?? 1)
        _targetUnit = State(initialValue: habitToEdit?.targetUnit ?? .day)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Habit Details") {
                    TextField("Habit Name (e.g., Read for 30 min)", text: $habitName)
                }
                
                Section("Frequency") {
                    Picker("Frequency Unit", selection: $targetUnit) {
                        ForEach(HabitUnit.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    
                    Picker("Times Per \(targetUnit.displayName)", selection: $targetFrequency) {
                        ForEach(availableFrequencies, id: \.self) { freq in
                            Text("\(freq)").tag(freq)
                        }
                    }
                }
            }
            .navigationTitle(habitToEdit == nil ? "New Habit" : "Edit Habit")
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
                    .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveOrUpdateHabit() {
        let trimmedName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let habit = habitToEdit {
            // Update existing habit properties
            habit.name = trimmedName
            habit.targetFrequency = targetFrequency
            habit.targetUnit = targetUnit
            // SwiftData automatically saves changes to @Bindable objects
        } else {
            // Save new habit
            viewModel.addHabit(
                name: trimmedName,
                frequency: targetFrequency,
                unit: targetUnit
            )
        }
        dismiss()
    }
}
