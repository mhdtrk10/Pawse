//
//  RootView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

struct RootView: View {
    @State private var hasSeenOnboarding: Bool = UserDefaultsManager.shared.hasSeenOnboarding

    var body: some View {
        Group {
            if hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
    }
}

#Preview {
    RootView()
}
