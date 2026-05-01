//
//  SettingServices.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import Foundation

final class SettingsService {
    private let storage = UserDefaultsManager.shared

    func getAppSettings() -> AppSettings {
        storage.loadAppSettings()
    }

    func saveAppSettings(_ settings: AppSettings) {
        storage.saveAppSettings(settings)
    }

    func resetAppSettings() {
        storage.saveAppSettings(.default)
    }

    func getSelectedLanguage() -> AppLanguage {
        storage.selectedLanguage
    }

    func saveSelectedLanguage(_ language: AppLanguage) {
        storage.selectedLanguage = language
    }
}
