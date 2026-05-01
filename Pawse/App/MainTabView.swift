//
//  MainTabView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(L10n.home, systemImage: "house.fill")
                }

            CatsView()
                .tabItem {
                    Label(L10n.cats, systemImage: "pawprint.fill")
                }

            StatsView()
                .tabItem {
                    Label(L10n.stats, systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label(L10n.settings, systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
