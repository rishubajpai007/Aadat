import SwiftUI
import SwiftData

struct HabitsView: View {
    
    @EnvironmentObject var viewModel: HabitsViewModel
    
    @State private var showingAddHabitSheet = false

    var body: some View {
        NavigationView {
            List {
                if viewModel.habits.isEmpty {
                    ContentUnavailableView("No Habits Yet", systemImage: "checklist.unchecked", description: Text("Tap '+' to start tracking a new habit."))
                        .listRowSeparator(.hidden)
                } else {
                    // MARK: List Habits using the new HabitRowView
                    ForEach($viewModel.habits) { $habit in
                        HabitRowView(habit: habit)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .onDelete(perform: viewModel.deleteHabits)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Your Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabitSheet = true
                    } label: {
                        Label("Add Habit", systemImage: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            // MARK: Integrate Add Habit Modal
            .sheet(isPresented: $showingAddHabitSheet) {
                AddHabitView()
            }
        }
        .modelContainer(viewModel.modelContainer)
    }
}
