//
//  AppRouterView.swift
//  Aadat
//
//  Created by Rishu Bajpai on 04/12/25.
//

import SwiftUI


struct AppRouterView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "checklist")
                }
                .tag(0)
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
