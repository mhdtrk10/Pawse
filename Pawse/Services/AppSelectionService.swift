//
//  AppSelectionService.swift
//  Pawse
//
//  Created by Mehdi Oturak on 30.04.2026.
//

import Foundation

final class AppSelectionService {
    private let settingsService = SettingsService()
    private let catalogService = AppSelectionCatalogService()

    func getApps() -> [SelectedAppItem] {
        let saved = settingsService.getAppSettings().selectedApps
        if saved.isEmpty {
            return catalogService.fetchDemoApps()
        }
        return saved
    }

    func saveApps(_ apps: [SelectedAppItem]) {
        var settings = settingsService.getAppSettings()
        settings.selectedApps = apps
        settings.selectedAppsCount = apps.filter(\.isSelected).count
        settingsService.saveAppSettings(settings)
    }
}
