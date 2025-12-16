import SwiftUI
import SwiftData

struct AppRouterView: View {
    @StateObject private var habitsViewModel = HabitsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "checklist")
                }
                .tag(0)
                .environmentObject(habitsViewModel)
            
            GlobalHeatmapsView()
                .tabItem {
                    Label("Heatmap", systemImage: "square.grid.3x3.fill")
                }
                .tag(1)
                .environmentObject(habitsViewModel) // Needs access to habits list
            
            ConcentrationModeView()
                .tabItem {
                    Label("Focus", systemImage: "clock.fill")
                }
                .tag(2)
        }
    }
}

