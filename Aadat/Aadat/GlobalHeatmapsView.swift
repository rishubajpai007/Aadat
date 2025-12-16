//
//  GlobalHeatmapsView.swift
//  Aadat
//
//  Created by Rishu Bajpai on 16/12/25.
//


import SwiftUI
import SwiftData

struct GlobalHeatmapsView: View {
    @EnvironmentObject var viewModel: HabitsViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.habits.isEmpty {
                    ContentUnavailableView("No Data", systemImage: "chart.bar.xaxis", description: Text("Add habits to see your yearly consistency."))
                } else {
                    VStack(spacing: 24) {
                        ForEach(viewModel.habits) { habit in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(habit.name)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("\(habit.currentStreak) day streak")
                                        .font(.caption)
                                        .padding(6)
                                        .background(Color.orange.opacity(0.1))
                                        .foregroundColor(.orange)
                                        .cornerRadius(6)
                                }
                                .padding(.horizontal)
                                
                                HabitHeatmapView(habit: habit)
                                    .frame(height: 150) 
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Heatmap Overview")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}
