//
//  HomeViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//


import SwiftUI
import Combine
import FamilyControls

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedAppsCount: Int = 0
    @Published var dailyLimitMinutes: Int = 15
    @Published var breakDurationMinutes: Int = 2
    @Published var activeCatName: String = "Default Cat"
    @Published var homeSummary: HomeSummary = HomeSummary(
        title: L10n.setupNeeded,
        message: L10n.setupNeededMessage,
        isFullyConfigured: false
    )
    @Published var screenTimeStatus: ScreenTimeAuthorizationStatus = .notDetermined

    private let settingsService: SettingsService
    private let screenTimeAuthorizationManager: ScreenTimeAuthorizationManager

    init(
        settingsService: SettingsService = SettingsService(),
        screenTimeAuthorizationManager: ScreenTimeAuthorizationManager? = nil
    ) {
        self.settingsService = settingsService
        self.screenTimeAuthorizationManager = screenTimeAuthorizationManager ?? ScreenTimeAuthorizationManager()
        loadSettings()
    }

    func loadSettings() {
        let settings = settingsService.getAppSettings()
        selectedAppsCount = settings.selectedAppsCount
        dailyLimitMinutes = settings.dailyLimitMinutes
        breakDurationMinutes = settings.breakDurationMinutes
        activeCatName = settings.activeCatName
        screenTimeStatus = screenTimeAuthorizationManager.authorizationStatus
        updateSummary()
    }

    func resetToDefault() {
        settingsService.resetAppSettings()
        loadSettings()
    }

    func refreshLocalization() {
        updateSummary()
    }

    func requestScreenTimeAccess() async {
        await screenTimeAuthorizationManager.requestAuthorization()
        screenTimeStatus = screenTimeAuthorizationManager.authorizationStatus
    }

    func updateSelectedAppsCount(from selection: FamilyActivitySelection) {
        print("Applications:", selection.applicationTokens.count)
        print("Categories:", selection.categoryTokens.count)
        print("Web domains:", selection.webDomainTokens.count)

        let totalSelectedCount =
            selection.applicationTokens.count +
            selection.categoryTokens.count +
            selection.webDomainTokens.count

        selectedAppsCount = totalSelectedCount

        var settings = settingsService.getAppSettings()
        settings.selectedAppsCount = totalSelectedCount
        settingsService.saveAppSettings(settings)

        updateSummary()
    }

    private func updateSummary() {
        let hasApps = selectedAppsCount > 0
        let hasLimit = dailyLimitMinutes > 0
        let hasBreak = breakDurationMinutes > 0
        let hasCat = !activeCatName.isEmpty

        let isReady = hasApps && hasLimit && hasBreak && hasCat

        if isReady {
            homeSummary = HomeSummary(
                title: L10n.pawseReady,
                message: L10n.pawseReadyMessage,
                isFullyConfigured: true
            )
        } else {
            homeSummary = HomeSummary(
                title: L10n.setupNeeded,
                message: L10n.setupNeededMessage,
                isFullyConfigured: false
            )
        }
    }
}
