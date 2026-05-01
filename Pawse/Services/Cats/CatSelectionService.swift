//
//  CatSelectionService.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import Foundation

final class CatSelectionService {
    private let settingsService = SettingsService()

    func getSelectedCatName() -> String {
        settingsService.getAppSettings().activeCatName
    }

    func selectCat(named catName: String) {
        var settings = settingsService.getAppSettings()
        settings.activeCatName = catName
        settingsService.saveAppSettings(settings)
    }
}
