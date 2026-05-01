//
//  PawseApp.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

@main
struct PawseApp: App {
    @StateObject private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(languageManager)
                .environment(\.locale, languageManager.locale)
        }
    }
}
