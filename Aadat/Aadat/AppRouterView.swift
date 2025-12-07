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
                .environmentObject(habitsViewModel) // <-- INJECTION

            ConcentrationModeView()
                .tabItem {
                    Label("Focus", systemImage: "clock.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
    }
}


