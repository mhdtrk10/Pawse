//
//  HomeViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//



import Combine
import SwiftUI
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
    @Published var shieldStatusMessage: String = "No shield applied."
    @Published var testSessionState: TestSessionState = .idle

    private let settingsService: SettingsService
    private let screenTimeAuthorizationManager: ScreenTimeAuthorizationManager
    private let shieldManager: ScreenTimeShieldManager

    private var countdownTask: Task<Void, Never>?

    init(
        settingsService: SettingsService = SettingsService(),
        screenTimeAuthorizationManager: ScreenTimeAuthorizationManager? = nil,
        shieldManager: ScreenTimeShieldManager? = nil
    ) {
        self.settingsService = settingsService
        self.screenTimeAuthorizationManager = screenTimeAuthorizationManager ?? ScreenTimeAuthorizationManager()
        self.shieldManager = shieldManager ?? ScreenTimeShieldManager()
        loadSettings()
    }

    deinit {
        countdownTask?.cancel()
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

    func applyShield(using selection: FamilyActivitySelection) {
        shieldManager.applyShield(using: selection)
        shieldStatusMessage = "Shield applied."
    }

    func clearShield() {
        shieldManager.clearShield()
        shieldStatusMessage = "Shield cleared."
    }

    func startTestSession(using selection: FamilyActivitySelection) {
        guard selectedAppsCount > 0 else {
            shieldStatusMessage = "Select at least one app or category first."
            return
        }

        countdownTask?.cancel()

        let sessionSeconds = dailyLimitMinutes * 60
        testSessionState = .running(remainingSeconds: sessionSeconds)
        shieldStatusMessage = "Session started."

        countdownTask = Task { [weak self] in
            guard let self else { return }

            var remainingSessionSeconds = sessionSeconds

            while remainingSessionSeconds > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                remainingSessionSeconds -= 1

                await MainActor.run {
                    self.testSessionState = .running(remainingSeconds: remainingSessionSeconds)
                }
            }

            guard !Task.isCancelled else { return }

            await MainActor.run {
                self.applyShield(using: selection)
                self.shieldStatusMessage = "Time is up. Break started."
            }

            let breakSeconds = breakDurationMinutes * 60
            var remainingBreakSeconds = breakSeconds

            await MainActor.run {
                self.testSessionState = .breakTime(remainingSeconds: remainingBreakSeconds)
            }

            while remainingBreakSeconds > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                remainingBreakSeconds -= 1

                await MainActor.run {
                    self.testSessionState = .breakTime(remainingSeconds: remainingBreakSeconds)
                }
            }

            guard !Task.isCancelled else { return }

            await MainActor.run {
                self.clearShield()
                self.testSessionState = .completed
                self.shieldStatusMessage = "Break ended. Access restored."
            }

            try? await Task.sleep(for: .seconds(1))

            guard !Task.isCancelled else { return }

            await MainActor.run {
                self.testSessionState = .idle
            }
        }
    }

    func cancelTestSession() {
        countdownTask?.cancel()
        countdownTask = nil
        clearShield()
        testSessionState = .idle
        shieldStatusMessage = "Session cancelled."
    }

    func formattedRemainingTime(language: AppLanguage) -> String {
        switch testSessionState {
        case .idle:
            return language == .english ? "Not running" : "Çalışmıyor"

        case .running(let remainingSeconds):
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60

            switch language {
            case .english:
                return String(format: "%02d:%02d remaining", minutes, seconds)
            case .turkish:
                return String(format: "%02d:%02d kaldı", minutes, seconds)
            }

        case .breakTime(let remainingSeconds):
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60

            switch language {
            case .english:
                return String(format: "Break: %02d:%02d", minutes, seconds)
            case .turkish:
                return String(format: "Mola: %02d:%02d", minutes, seconds)
            }

        case .completed:
            return language == .english ? "Completed" : "Tamamlandı"
        }
    }
    var isBreakActive: Bool {
        if case .breakTime = testSessionState {
            return true
        }
        return false
    }

    var currentBreakRemainingSeconds: Int {
        if case .breakTime(let remainingSeconds) = testSessionState {
            return remainingSeconds
        }
        return 0
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
    var isSessionRunning: Bool {
        switch testSessionState {
        case .running, .breakTime:
            return true
        default:
            return false
        }
    }

    func sessionTitle(language: AppLanguage) -> String {
        switch testSessionState {
        case .idle:
            return language == .english ? "Focus Session" : "Odak Oturumu"
        case .running:
            return language == .english ? "Session Running" : "Oturum Devam Ediyor"
        case .breakTime:
            return language == .english ? "Break Time" : "Mola Zamanı"
        case .completed:
            return language == .english ? "Session Completed" : "Oturum Tamamlandı"
        }
    }

    func sessionDescription(language: AppLanguage) -> String {
        switch testSessionState {
        case .idle:
            return language == .english
                ? "Start a session and let Pawse step in when your time is up."
                : "Bir oturum başlat ve süren dolduğunda Pawse'un devreye girmesine izin ver."
        case .running:
            return language == .english
                ? "Your session is active. Pawse will start your break when time is up."
                : "Oturumun aktif. Süre dolduğunda Pawse molanı başlatacak."
        case .breakTime:
            return language == .english
                ? "Your break is active. Selected apps stay restricted until the break ends."
                : "Molan aktif. Mola bitene kadar seçili uygulamalar kısıtlı kalacak."
        case .completed:
            return language == .english
                ? "Your session finished successfully."
                : "Oturumun başarıyla tamamlandı."
        }
    }

    func sessionAccentColor() -> Color {
        switch testSessionState {
        case .idle:
            return AppColors.primary
        case .running:
            return .orange
        case .breakTime:
            return AppColors.success
        case .completed:
            return AppColors.success
        }
    }

    func progressValue() -> Double {
        switch testSessionState {
        case .idle:
            return 0.0

        case .running(let remainingSeconds):
            let totalSeconds = max(dailyLimitMinutes * 60, 1)
            let elapsed = totalSeconds - remainingSeconds
            return min(max(Double(elapsed) / Double(totalSeconds), 0), 1)

        case .breakTime(let remainingSeconds):
            let totalSeconds = max(breakDurationMinutes * 60, 1)
            let elapsed = totalSeconds - remainingSeconds
            return min(max(Double(elapsed) / Double(totalSeconds), 0), 1)

        case .completed:
            return 1.0
        }
    }
}
