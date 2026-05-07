//
//  SettingsViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//


import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var soundEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    @Published var selectedLanguage: AppLanguage = .english

    private let settingsService: SettingsService

    init(settingsService: SettingsService = SettingsService()) {
        self.settingsService = settingsService
        self.selectedLanguage = settingsService.getSelectedLanguage()
    }

    func applyDemoSettings() {
        let demoSelectedApps: [SelectedAppItem] = [
            SelectedAppItem(id: "instagram", name: "Instagram", systemImageName: "camera.fill", isSelected: true),
            SelectedAppItem(id: "x", name: "X", systemImageName: "bubble.left.and.bubble.right.fill", isSelected: true),
            SelectedAppItem(id: "youtube", name: "YouTube", systemImageName: "play.rectangle.fill", isSelected: true),
            SelectedAppItem(id: "tiktok", name: "TikTok", systemImageName: "music.note", isSelected: false),
            SelectedAppItem(id: "reddit", name: "Reddit", systemImageName: "text.bubble.fill", isSelected: false),
            SelectedAppItem(id: "safari", name: "Safari", systemImageName: "safari.fill", isSelected: false)
        ]

        let demoSettings = AppSettings(
            selectedAppsCount: demoSelectedApps.filter(\.isSelected).count,
            dailyLimitMinutes: 20,
            breakDurationMinutes: 5,
            activeCatName: "Sleepy Cat",
            selectedApps: demoSelectedApps,
            selectedBreakMediaTypeRawValue: BreakMediaType.builtInCat.rawValue,
            customPhotoFileName: nil,
            customPhotoScale: 1.0,
            customPhotoOffsetX: 0.0,
            customPhotoOffsetY: 0.0,
            customGIFFileName: nil
        )

        settingsService.saveAppSettings(demoSettings)
    }

    func updateLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        settingsService.saveSelectedLanguage(language)
    }
}
