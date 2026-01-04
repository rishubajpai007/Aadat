import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var viewModel: HabitsViewModel
    @Environment(\.dismiss) var dismiss
    
    var habitToEdit: Habit?
    
    @State private var habitName: String
    @State private var selectedCategory: HabitCategory
    
    init(habitToEdit: Habit? = nil) {
        self.habitToEdit = habitToEdit
        _habitName = State(initialValue: habitToEdit?.name ?? "")
        _selectedCategory = State(initialValue: habitToEdit?.category ?? .other)
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
        
        if let habit = habitToEdit {
            habit.name = trimmedName
            habit.category = selectedCategory
        } else {
            viewModel.addHabit(name: trimmedName, category: selectedCategory)
        }
        
        dismiss()
    }
}
