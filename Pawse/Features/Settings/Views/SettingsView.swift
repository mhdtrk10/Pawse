//
//  SettingsView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var languageManager: LanguageManager

    @State private var isSoundOn: Bool = true
    @State private var isHapticsOn: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.preferences) {
                    Toggle(L10n.sound, isOn: $isSoundOn)
                    Toggle(L10n.haptics, isOn: $isHapticsOn)
                }

                Section(L10n.language) {
                    Picker("", selection: $viewModel.selectedLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedLanguage) { _, newValue in
                        viewModel.updateLanguage(newValue)
                        languageManager.updateLanguage(newValue)
                    }
                }

                Section(L10n.demo) {
                    Button(L10n.loadDemoSettings) {
                        viewModel.applyDemoSettings()
                    }
                }

                Section(L10n.about) {
                    Text("Pawse v1.0")
                    Text(L10n.privacyPolicy)
                    Text(L10n.contact)
                }
            }
            .navigationTitle(L10n.settings)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageManager())
}
