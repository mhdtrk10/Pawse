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

    // MARK: - Break Media

    func getBreakMediaType() -> BreakMediaType {
        getAppSettings().selectedBreakMediaType
    }

    func setBreakMediaType(_ type: BreakMediaType) {
        var settings = getAppSettings()
        settings.selectedBreakMediaType = type
        saveAppSettings(settings)
    }

    func switchToBuiltInCatMedia() {
        var settings = getAppSettings()
        settings.selectedBreakMediaType = .builtInCat
        saveAppSettings(settings)
    }

    // MARK: - Custom Photo

    func getCustomPhotoFileName() -> String? {
        getAppSettings().customPhotoFileName
    }

    func setCustomPhotoFileName(_ fileName: String?) {
        var settings = getAppSettings()
        settings.customPhotoFileName = fileName
        saveAppSettings(settings)
    }

    func getCustomPhotoTransform() -> (scale: Double, offsetX: Double, offsetY: Double) {
        let settings = getAppSettings()
        return (
            scale: settings.customPhotoScale,
            offsetX: settings.customPhotoOffsetX,
            offsetY: settings.customPhotoOffsetY
        )
    }

    func saveCustomPhotoTransform(scale: Double, offsetX: Double, offsetY: Double) {
        var settings = getAppSettings()
        settings.customPhotoScale = scale
        settings.customPhotoOffsetX = offsetX
        settings.customPhotoOffsetY = offsetY
        saveAppSettings(settings)
    }

    func clearCustomPhotoSettings() {
        var settings = getAppSettings()
        settings.selectedBreakMediaType = .builtInCat
        settings.customPhotoFileName = nil
        settings.customPhotoScale = 1.0
        settings.customPhotoOffsetX = 0.0
        settings.customPhotoOffsetY = 0.0
        saveAppSettings(settings)
    }

    // MARK: - Custom GIF

    func getCustomGIFFileName() -> String? {
        getAppSettings().customGIFFileName
    }

    func setCustomGIFFileName(_ fileName: String?) {
        var settings = getAppSettings()
        settings.customGIFFileName = fileName
        saveAppSettings(settings)
    }

    func clearCustomGIFSettings() {
        var settings = getAppSettings()
        settings.selectedBreakMediaType = .builtInCat
        settings.customGIFFileName = nil
        saveAppSettings(settings)
    }
    func getSoundEnabled() -> Bool {
        storage.soundEnabled
    }

    func saveSoundEnabled(_ isEnabled: Bool) {
        storage.soundEnabled = isEnabled
    }

    func getHapticsEnabled() -> Bool {
        storage.hapticsEnabled
    }

    func saveHapticsEnabled(_ isEnabled: Bool) {
        storage.hapticsEnabled = isEnabled
    }
}
