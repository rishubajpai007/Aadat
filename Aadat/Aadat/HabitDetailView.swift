//
//  HabitDetailView.swift
//  Aadat
//
//  Created by Rishu Bajpai on 07/12/25.
//

import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Bindable var habit: Habit
    @EnvironmentObject var viewModel: HabitsViewModel
    
    @State private var showingEditSheet = false
    
    // MARK: Calendar Helper
    private let calendar = Calendar.current
    
    var body: some View {
        List {
            // MARK: Section 1: Summary Stats
            Section {
                HStack {
                    StatisticView(value: "\(habit.currentStreak)", label: "Current Streak", color: .orange)
                    Divider()
                    StatisticView(value: "\(habit.completionDates.count)", label: "Total Completed", color: .blue)
                }
            }
            .listRowSeparator(.hidden)

            // MARK: Section 2: Completion Calendar
            Section("Completion History") {
                CalendarView(
                    daysToShow: 30,
                    completionDates: habit.completionDates
                )
                .frame(height: 250)
                .listRowInsets(EdgeInsets())
            }
            
            // MARK: Section 3: Habit Details & Settings
            Section("Details & Settings") {
                HStack {
                    Text("Target")
                    Spacer()
                    Text("\(habit.targetFrequency) per \(habit.targetUnit.displayName.lowercased())")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Created")
                    Spacer()
                    Text(habit.creationDate, style: .date)
                        .foregroundColor(.secondary)
                }
                
                Button("Delete Habit", role: .destructive) {
                    // For safety, this would usually trigger a confirmation dialog
                    viewModel.deleteHabits(offsets: IndexSet(integer: 0)) // Needs refinement for single deletion
                }
            }
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddHabitView(habitToEdit: habit)
        }
    }
}

// MARK: - Helper Views

struct StatisticView: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CalendarView: View {
    let daysToShow: Int
    let completionDates: [Date]
    
    var body: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -(daysToShow - 1), to: today) ?? today
        
        VStack {
            HStack {
                Text("Last \(daysToShow) Days")
                    .font(.headline)
                    .padding([.leading, .top])
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 5) {
                ForEach(0..<daysToShow, id: \.self) { index in
                    if let date = calendar.date(byAdding: .day, value: index, to: startDate) {
                        let isCompleted = completionDates.contains { calendar.isDate($0, inSameDayAs: date) }
                        
                        VStack {
                            Text("\(calendar.component(.day, from: date))")
                                .font(.caption)
                                .frame(width: 30, height: 30)
                                .background(isCompleted ? Color.green.opacity(0.8) : Color.clear)
                                .foregroundColor(isCompleted ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
            }
            .padding()
        }
    }
}
