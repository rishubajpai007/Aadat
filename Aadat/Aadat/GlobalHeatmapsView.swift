import SwiftUI
import SwiftData

struct GlobalHeatmapsView: View {
    @EnvironmentObject var viewModel: HabitsViewModel
    @State private var selectedCategory: HabitCategory? = nil
    
    // MARK: - Filtered Aggregate Stats
    
    private var earliestHabitDate: Date {
        filteredHabits.map { $0.creationDate }.min() ?? Date()
    }

    private var totalDaysActive: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: earliestHabitDate)
        let end = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: start, to: end)
        return (components.day ?? 0) + 1
    }

    private var totalAnnualCompletions: Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        return filteredHabits.reduce(0) { count, habit in
            count + habit.completionDates.filter { calendar.component(.year, from: $0) == currentYear }.count
        }
    }
    
    private var perfectDaysCount: Int {
        guard !filteredHabits.isEmpty else { return 0 }
        let calendar = Calendar.current
        var count = 0
        
        for dayOffset in 0..<totalDaysActive {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: calendar.startOfDay(for: Date())) else { continue }
            
            let activeOnDate = filteredHabits.filter { calendar.startOfDay(for: $0.creationDate) <= date }
            if activeOnDate.isEmpty { continue }
            
            let allDone = activeOnDate.allSatisfy { habit in
                habit.completionDates.contains { calendar.isDate($0, inSameDayAs: date) }
            }
            
            if allDone { count += 1 }
        }
        return count
    }
    
    private var averageSuccessRate: Int {
        guard !filteredHabits.isEmpty else { return 0 }
        let totalRate = filteredHabits.reduce(0) { sum, habit in
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: habit.creationDate, to: Date()).day ?? 0
            let rate = Double(habit.completionDates.count) / Double(max(1, days + 1))
            return sum + rate
        }
        return Int((totalRate / Double(filteredHabits.count)) * 100)
    }
    
    private var filteredHabits: [Habit] {
        if let category = selectedCategory {
            return viewModel.habits.filter { $0.category == category }
        }
        return viewModel.habits
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundLayer()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        // 1. Dashboard Header (Glassmorphic)
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedCategory == nil ? "GLOBAL MASTERY" : "\(selectedCategory!.rawValue.uppercased()) MASTERY")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .tracking(1.5)
                                    .animation(.easeInOut, value: selectedCategory)
                                
                                Text("Performance Insights")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            
                            HStack(spacing: 12) {
                                GlobalStatCard(title: "Completions", value: "\(totalAnnualCompletions)", icon: "checkmark.circle.fill", color: .blue)
                                GlobalStatCard(title: "Perfect Days", value: "\(perfectDaysCount)", icon: "star.fill", color: .orange)
                                GlobalStatCard(title: "Avg. Success", value: "\(averageSuccessRate)%", icon: "chart.bar.fill", color: .purple)
                            }
                            .animation(.spring(), value: selectedCategory)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // 2. Category Filter Bar
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                FilterChip(title: "All", isSelected: selectedCategory == nil) {
                                    withAnimation(.spring()) { selectedCategory = nil }
                                }
                                
                                ForEach(HabitCategory.allCases, id: \.self) { category in
                                    FilterChip(title: "\(category.icon) \(category.rawValue)", isSelected: selectedCategory == category) {
                                        withAnimation(.spring()) { selectedCategory = category }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 3. Heatmap List
                        if filteredHabits.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary.opacity(0.4))
                                    .padding(.top, 40)
                                Text("No habits found")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            LazyVStack(spacing: 32) {
                                ForEach(filteredHabits) { habit in
                                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                                        VStack(alignment: .leading, spacing: 16) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(habit.name)
                                                        .font(.system(.headline, design: .rounded))
                                                        .foregroundColor(.primary)
                                                    
                                                    Text("\(habit.category.icon) \(habit.category.rawValue)")
                                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(habit.category.color.opacity(0.1))
                                                        .foregroundColor(habit.category.color)
                                                        .clipShape(Capsule())
                                                }
                                                
                                                Spacer()
                                                
                                                VStack(alignment: .trailing, spacing: 2) {
                                                    Text("\(habit.currentStreak)d streak")
                                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                                        .foregroundColor(.orange)
                                                    
                                                    let days = Calendar.current.dateComponents([.day], from: habit.creationDate, to: Date()).day ?? 0
                                                    let rate = Int((Double(habit.completionDates.count) / Double(max(1, days + 1))) * 100)
                                                    Text("\(rate)% consistency")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .padding(.horizontal, 24)
                                            
                                            HabitHeatmapView(habit: habit)
                                                .padding(.horizontal, 10)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
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
                .font(.system(size: 14))
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .contentTransition(.numericText())
            
            Text(title.uppercased())
                .font(.system(size: 8, weight: .black))
                .foregroundColor(.secondary)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(18)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    isSelected ?
                    Color.blue :
                    Color.primary.opacity(0.05)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.white.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
