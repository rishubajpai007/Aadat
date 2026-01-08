import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var viewModel: HabitsViewModel
    @Environment(\.dismiss) var dismiss
    
    var habitToEdit: Habit?
    
    @State private var habitName: String
    @State private var selectedCategory: HabitCategory
    
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
        ZStack {
            BackgroundLayer()
            
            VStack(spacing: 0) {
            
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(habitToEdit == nil ? "New Habit" : "Edit Habit")
                        .font(.system(.headline, design: .rounded))
                    
                    Spacer()
                    
                    Button(habitToEdit == nil ? "Save" : "Update") {
                        saveOrUpdateHabit()
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(habitName.isEmpty ? .secondary : .blue)
                    .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(.ultraThinMaterial)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        
                        // Section 1: Habit Name
                        VStack(alignment: .leading, spacing: 12) {
                            Text("WHAT'S THE GOAL?")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .tracking(1.5)
                                .padding(.leading, 8)
                            
                            TextField("Enter habit name...", text: $habitName)
                                .font(.system(.title3, design: .rounded))
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
                        }
                        
                        // Section 2: Category Grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SELECT CATEGORY")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .tracking(1.5)
                                .padding(.leading, 8)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 75))], spacing: 12) {
                                ForEach(HabitCategory.allCases, id: \.self) { category in
                                    CategoryTile(category: category, isSelected: selectedCategory == category) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Section 3: Reminders
                        VStack(alignment: .leading, spacing: 12) {
                            Text("REDUCE FRICTION")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .tracking(1.5)
                                .padding(.leading, 8)
                            
                            VStack(spacing: 0) {
                                Toggle(isOn: $isReminderEnabled.animation()) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.orange.opacity(0.1))
                                                .frame(width: 32, height: 32)
                                            Image(systemName: "bell.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.orange)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Daily Reminder")
                                                .font(.system(.headline, design: .rounded))
                                            Text("Get a nudge to stay on track")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(20)
                                .onChange(of: isReminderEnabled) { newValue in
                                    if newValue {
                                        viewModel.requestNotificationPermissions()
                                    }
                                }
                                
                                if isReminderEnabled {
                                    Divider().padding(.horizontal, 20)
                                    
                                    DatePicker(
                                        "Reminder Time",
                                        selection: $reminderTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .padding(.vertical, 10)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                        
                        Button {
                            saveOrUpdateHabit()
                        } label: {
                            Text(habitToEdit == nil ? "Start Journey" : "Update Habit")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    Capsule()
                                        .fill(habitName.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                                )
                                .shadow(color: .blue.opacity(0.2), radius: 10, y: 5)
                        }
                        .disabled(habitName.isEmpty)
                        .padding(.top, 8)
                    }
                    .padding(20)
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

// MARK: - Helper Views

struct CategoryTile: View {
    let category: HabitCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(category.icon)
                    .font(.system(size: 24))
                
                Text(category.rawValue)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? category.color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? category.color.opacity(0.12) : Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? category.color.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
