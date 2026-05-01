//
//  LanguageManager.swift
//  Pawse
//
//  Created by Mehdi Oturak on 1.05.2026.
//

import Foundation
import Combine

@MainActor
final class LanguageManager: ObservableObject {
    @Published var selectedLanguage: AppLanguage

    private let settingsService: SettingsService

    init(settingsService: SettingsService = SettingsService()) {
        self.settingsService = settingsService
        self.selectedLanguage = settingsService.getSelectedLanguage()
    }

    func updateLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        settingsService.saveSelectedLanguage(language)
    }

    var locale: Locale {
        Locale(identifier: selectedLanguage.localeIdentifier)
    }
}
