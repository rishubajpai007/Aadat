import SwiftUI
import SwiftData

struct GlobalHeatmapsView: View {
    @EnvironmentObject var viewModel: HabitsViewModel
    @State private var selectedCategory: HabitCategory? = nil
    
    // MARK: - Aggregate Stats
    
    private var totalAnnualCompletions: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return viewModel.habits.reduce(0) { count, habit in
            count + habit.completionDates.filter { Calendar.current.component(.year, from: $0) == currentYear }.count
        }
    }
    
    private var masterStreak: Int {
        viewModel.habits.map { $0.currentStreak }.max() ?? 0
    }
    
    private var averageSuccessRate: Int {
        guard !viewModel.habits.isEmpty else { return 0 }
        let totalRate = viewModel.habits.reduce(0) { sum, habit in
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: habit.creationDate, to: Date()).day ?? 0
            let rate = Double(habit.completionDates.count) / Double(max(1, days + 1))
            return sum + rate
        }
        return Int((totalRate / Double(viewModel.habits.count)) * 100)
    }
    
    private var filteredHabits: [Habit] {
        if let category = selectedCategory {
            return viewModel.habits.filter { $0.category == category }
        }
        return viewModel.habits
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Global Mastery")
                                    .font(.headline)
                                Text("Consolidated insights across all habits")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            GlobalStatCard(title: "Completions", value: "\(totalAnnualCompletions)", icon: "checkmark.circle.fill", color: .blue)
                            GlobalStatCard(title: "Master Streak", value: "\(masterStreak)", icon: "flame.fill", color: .orange)
                            GlobalStatCard(title: "Avg. Success", value: "\(averageSuccessRate)%", icon: "chart.bar.fill", color: .purple)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(HabitCategory.allCases, id: \.self) { category in
                                FilterChip(title: "\(category.icon) \(category.rawValue)", isSelected: selectedCategory == category) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if filteredHabits.isEmpty {
                        ContentUnavailableView("No Data", systemImage: "chart.bar.xaxis", description: Text("No habits found in this category."))
                            .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 24) {
                            ForEach(filteredHabits) { habit in
                                NavigationLink(destination: HabitDetailView(habit: habit)) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(habit.name)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Text("\(habit.category.icon) \(habit.category.rawValue)")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(habit.category.color.opacity(0.1))
                                                    .foregroundColor(habit.category.color)
                                                    .cornerRadius(4)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 2) {
                                                Text("\(habit.currentStreak) day streak")
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.orange)
                                                
                                                let days = Calendar.current.dateComponents([.day], from: habit.creationDate, to: Date()).day ?? 0
                                                let rate = Int((Double(habit.completionDates.count) / Double(max(1, days + 1))) * 100)
                                                Text("\(rate)% success")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.horizontal)
                                        
                                        HabitHeatmapView(habit: habit)
                                            .frame(height: 140)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Heatmap Overview")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

// MARK: - Supporting Components

struct GlobalStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.subheadline)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
            
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(UIColor.secondarySystemGroupedBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}
