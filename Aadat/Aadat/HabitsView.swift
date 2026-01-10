import SwiftUI
import SwiftData

struct HabitsView: View {
    @EnvironmentObject var viewModel: HabitsViewModel
    @State private var showingAddHabitSheet = false
    
    // MARK: - Computed Properties
    private var completionRate: Double {
        guard !viewModel.habits.isEmpty else { return 0 }
        let completed = viewModel.habits.filter { viewModel.isCompletedOnDate(habit: $0, date: Date()) }.count
        return Double(completed) / Double(viewModel.habits.count)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 1. Dynamic Background Layer
                BackgroundLayer()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        // 2. Welcome Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dateString.uppercased())
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .tracking(1.2)
                            
                            Text("\(greeting),")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                            
                            Text("Let's crush your goals today.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // 3. Premium Dashboard Card
                        if !viewModel.habits.isEmpty {
                            DashboardCard(completionRate: completionRate)
                        }

                        // 4. Habits List Section
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Your Habits")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(viewModel.habits.count) Total")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal)

                            if viewModel.habits.isEmpty {
                                EmptyStateView(showingAddHabitSheet: $showingAddHabitSheet)
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.habits) { habit in
                                        NavigationLink(destination: HabitDetailView(habit: habit)) {
                                            HabitRowView(habit: habit)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabitSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.blue))
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabitSheet) {
                AddHabitView()
            }
        }
    }
}

// MARK: - Supporting UI Components

struct BackgroundLayer: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            Circle()
                .fill(Color.blue.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -150, y: -250)
            
            Circle()
                .fill(Color.purple.opacity(0.05))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: 180, y: 200)
        }
    }
}

struct DashboardCard: View {
    let completionRate: Double
    
    // Dynamic message logic to provide context-aware feedback
    private var dashboardMessage: String {
        if completionRate == 0 {
            return "Ready to start your first habit? Let's go! 🚀"
        } else if completionRate < 0.5 {
            return "Great start! Keep that momentum building. 🔥"
        } else if completionRate < 1.0 {
            return "You're more than halfway there! Almost done. 💪"
        } else {
            return "Perfect day! You've crushed every goal. 🎉"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.05), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: completionRate)
                        .stroke(
                            LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: completionRate)
                    
                    Text("\(Int(completionRate * 100))%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .frame(width: 70, height: 70)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Mastery")
                        .font(.headline)
                    Text(dashboardMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Consistency Score")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Spacer()
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.05))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * completionRate, height: 8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: completionRate)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
        .padding(.horizontal)
    }
}

struct EmptyStateView: View {
    @Binding var showingAddHabitSheet: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                )
                .padding(.top, 40)
            
            Text("No Habits Found")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("The journey of a thousand miles begins with a single habit.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddHabitSheet = true
            } label: {
                Text("Start Your Journey")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.blue))
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
    }
}
