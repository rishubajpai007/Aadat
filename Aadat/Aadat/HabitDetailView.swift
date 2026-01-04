import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Bindable var habit: Habit
    @EnvironmentObject var viewModel: HabitsViewModel
    @State private var showingEditSheet = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            Section {
                HStack {
                    StatisticView(value: "\(habit.currentStreak)", label: "Current Streak", color: .orange)
                    Divider()
                    StatisticView(value: "\(habit.completionDates.count)", label: "Total Days", color: .blue)
                }
            }
            .listRowSeparator(.hidden)
            .padding(.vertical, 8)

            Section(header: Text("Yearly Consistency")) {
                HabitHeatmapView(habit: habit)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            Section("Details") {
                HStack {
                    Text("Category")
                    Spacer()
                    Text("\(habit.category.icon) \(habit.category.rawValue)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Created")
                    Spacer()
                    Text(habit.creationDate, style: .date)
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button("Edit Habit") { showingEditSheet = true }
                Button("Delete Habit", role: .destructive) { deleteHabit() }
            }
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            AddHabitView(habitToEdit: habit)
        }
    }
    
    private func deleteHabit() {
        if let index = viewModel.habits.firstIndex(where: { $0.id == habit.id }) {
            viewModel.deleteHabits(offsets: IndexSet(integer: index))
            dismiss()
        }
    }
}

// MARK: - Helper Views

struct StatisticView: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
