import SwiftUI
import SwiftData

struct HabitsView: View {
    
    @EnvironmentObject var viewModel: HabitsViewModel
    @State private var showingAddHabitSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.habits.isEmpty {
                    ContentUnavailableView("No Habits Yet", systemImage: "checklist.unchecked", description: Text("Tap '+' to start tracking a new habit."))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach($viewModel.habits) { $habit in
                                NavigationLink(destination: HabitDetailView(habit: habit)) {
                                    HabitRowView(habit: habit)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Your Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EmptyView()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabitSheet = true
                    } label: {
                        Label("Add Habit", systemImage: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabitSheet) {
                AddHabitView()
            }
        }
        .modelContainer(viewModel.modelContainer)
    }
}
