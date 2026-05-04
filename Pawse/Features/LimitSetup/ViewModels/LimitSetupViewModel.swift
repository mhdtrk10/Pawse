//
//  LimitSetupViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 30.04.2026.
//

import Foundation
import Combine

@MainActor
final class LimitSetupViewModel: ObservableObject {
    @Published var selectedDailyLimit: Int = 15
    @Published var selectedBreakDuration: Int = 2
    @Published var didSaveSuccessfully: Bool = false

    let dailyLimitOptions: [TimeLimitOption] = [
        TimeLimitOption(minutes: 1),
        TimeLimitOption(minutes: 10),
        TimeLimitOption(minutes: 15),
        TimeLimitOption(minutes: 20),
        TimeLimitOption(minutes: 30),
        TimeLimitOption(minutes: 45),
        TimeLimitOption(minutes: 60)
    ]

    let breakDurationOptions: [TimeLimitOption] = [
        TimeLimitOption(minutes: 1),
        TimeLimitOption(minutes: 2),
        TimeLimitOption(minutes: 5),
        TimeLimitOption(minutes: 10),
        TimeLimitOption(minutes: 15)
    ]

    private let settingsService: SettingsService

    init(settingsService: SettingsService = SettingsService()) {
        self.settingsService = settingsService
        loadCurrentSettings()
    }

    func loadCurrentSettings() {
        let settings = settingsService.getAppSettings()
        selectedDailyLimit = settings.dailyLimitMinutes
        selectedBreakDuration = settings.breakDurationMinutes
    }

    func saveSettings() {
        var settings = settingsService.getAppSettings()
        settings.dailyLimitMinutes = selectedDailyLimit
        settings.breakDurationMinutes = selectedBreakDuration
        settingsService.saveAppSettings(settings)

        didSaveSuccessfully = true
    }

    func resetSaveState() {
        didSaveSuccessfully = false
    }
}
