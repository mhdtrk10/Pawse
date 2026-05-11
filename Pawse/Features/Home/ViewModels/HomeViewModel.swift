//
//  HomeViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

// ADDED FOR LOCAL NOTIFICATIONS - START
import UserNotifications
// ADDED FOR LOCAL NOTIFICATIONS - END

import Combine
import SwiftUI
import FamilyControls

// ADDED FOR LOCAL NOTIFICATIONS - START
/// Local notification manager for break reminders
final class PawseNotificationManager {
    static let shared = PawseNotificationManager()
    private init() {}
    
    private let breakTimeIdentifier = "com.pawse.notification.breakTime"
    
    func scheduleBreakNotification(at breakStartDate: Date, language: AppLanguage) async {
        await removePendingBreakNotification()
        
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            print("⚠️ [PawseNotificationManager] Not authorized")
            return
        }
        
        guard breakStartDate > Date() else {
            print("⚠️ [PawseNotificationManager] Date is in the past")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = language == .english ? "Break Time 🐾" : "Mola Zamanı 🐾"
        content.body = language == .english ? "Your session is over. Time to take a short break." : "Oturumun sona erdi. Kısa bir mola zamanı."
        content.sound = .default
        content.badge = 1
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: breakStartDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: breakTimeIdentifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ [PawseNotificationManager] Notification scheduled for \(breakStartDate)")
        } catch {
            print("❌ [PawseNotificationManager] Error: \(error)")
        }
    }
    
    func removePendingBreakNotification() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [breakTimeIdentifier])
        print("🗑️ [PawseNotificationManager] Pending notification removed")
    }
    
    func clearAllBreakNotifications() async {
        await removePendingBreakNotification()
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [breakTimeIdentifier])
        // Also clear badge when clearing notifications
        await clearBadge()
        print("🗑️ [PawseNotificationManager] All notifications cleared")
    }
    
    /// Clears the app badge number
    func clearBadge() async {
        do {
            try await UNUserNotificationCenter.current().setBadgeCount(0)
            print("🔴 [PawseNotificationManager] Badge cleared")
        } catch {
            print("❌ [PawseNotificationManager] Error clearing badge: \(error)")
        }
    }
}
// ADDED FOR LOCAL NOTIFICATIONS - END

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
    private let statsService: StatsService
    private let sessionPersistenceService: SessionPersistenceService

    private var countdownTask: Task<Void, Never>?
    
    private let feedbackManager: FeedbackManager
    private let soundManager: SoundManager
    // ADDED FOR LOCAL NOTIFICATIONS - START
    private let notificationManager: PawseNotificationManager
    // ADDED FOR LOCAL NOTIFICATIONS - END

    init(
        settingsService: SettingsService = SettingsService(),
        screenTimeAuthorizationManager: ScreenTimeAuthorizationManager? = nil,
        shieldManager: ScreenTimeShieldManager? = nil,
        statsService: StatsService = StatsService(),
        sessionPersistenceService: SessionPersistenceService = SessionPersistenceService(),
        feedbackManager: FeedbackManager = FeedbackManager(),
        soundManager: SoundManager = SoundManager(),
        // ADDED FOR LOCAL NOTIFICATIONS - START
        notificationManager: PawseNotificationManager = PawseNotificationManager.shared
        // ADDED FOR LOCAL NOTIFICATIONS - END
    ) {
        self.settingsService = settingsService
        self.screenTimeAuthorizationManager = screenTimeAuthorizationManager ?? ScreenTimeAuthorizationManager()
        self.shieldManager = shieldManager ?? ScreenTimeShieldManager()
        self.statsService = statsService
        self.sessionPersistenceService = sessionPersistenceService
        self.feedbackManager = feedbackManager
        self.soundManager = soundManager
        // ADDED FOR LOCAL NOTIFICATIONS - START
        self.notificationManager = notificationManager
        // ADDED FOR LOCAL NOTIFICATIONS - END

        loadSettings()
        restoreSessionIfNeeded()
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
        sessionPersistenceService.clearSnapshot()
        countdownTask?.cancel()
        testSessionState = .idle
        shieldManager.clearShield()
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
        statsService.recordShieldApplied()
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

        let now = Date()
        let sessionEndDate = now.addingTimeInterval(TimeInterval(dailyLimitMinutes * 60))
        let breakEndDate = sessionEndDate.addingTimeInterval(TimeInterval(breakDurationMinutes * 60))

        let snapshot = ActiveSessionSnapshot(
            sessionStartDate: now,
            sessionEndDate: sessionEndDate,
            breakEndDate: breakEndDate,
            selectedAtLeastOneTarget: true
        )

        sessionPersistenceService.saveSnapshot(snapshot)
        shieldStatusMessage = "Session started."
        feedbackManager.triggerLightImpactIfNeeded()
        soundManager.playSessionStartedSoundIfNeeded()

        // ADDED FOR LOCAL NOTIFICATIONS - START
        // Schedule notification for when break starts
        Task {
            let language = UserDefaultsManager.shared.selectedLanguage
            await notificationManager.scheduleBreakNotification(
                at: sessionEndDate,
                language: language
            )
        }
        // ADDED FOR LOCAL NOTIFICATIONS - END

        recalculateSessionState(using: selection)
        startRealtimeTicker(using: selection)
    }

    func cancelTestSession() {
        countdownTask?.cancel()
        countdownTask = nil
        clearShield()
        sessionPersistenceService.clearSnapshot()
        testSessionState = .idle
        shieldStatusMessage = "Session cancelled."
        feedbackManager.triggerLightImpactIfNeeded()
        soundManager.playCancellationSoundIfNeeded()
        
        // ADDED FOR LOCAL NOTIFICATIONS - START
        // Remove scheduled notification when session is cancelled
        Task {
            await notificationManager.removePendingBreakNotification()
        }
        // ADDED FOR LOCAL NOTIFICATIONS - END
    }

    func restoreSessionIfNeeded(using selection: FamilyActivitySelection? = nil) {
        recalculateSessionState(using: selection)
        if sessionPersistenceService.loadSnapshot() != nil {
            startRealtimeTicker(using: selection)
        }
    }

    func handleAppDidBecomeActive(using selection: FamilyActivitySelection? = nil) {
        recalculateSessionState(using: selection)
        if sessionPersistenceService.loadSnapshot() != nil {
            startRealtimeTicker(using: selection)
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
        guard let snapshot = sessionPersistenceService.loadSnapshot() else {
            return testSessionState == .completed ? 1.0 : 0.0
        }

        let now = Date()

        switch testSessionState {
        case .idle:
            return 0.0

        case .running:
            let total = snapshot.sessionEndDate.timeIntervalSince(snapshot.sessionStartDate)
            let elapsed = now.timeIntervalSince(snapshot.sessionStartDate)
            guard total > 0 else { return 0.0 }
            return min(max(elapsed / total, 0), 1)

        case .breakTime:
            let breakStartDate = snapshot.sessionEndDate
            let total = snapshot.breakEndDate.timeIntervalSince(breakStartDate)
            let elapsed = now.timeIntervalSince(breakStartDate)
            guard total > 0 else { return 0.0 }
            return min(max(elapsed / total, 0), 1)

        case .completed:
            return 1.0
        }
    }

    func formattedRemainingTime(language: AppLanguage) -> String {
        switch testSessionState {
        case .idle:
            return language == .english ? "Not running" : "Çalışmıyor"

        case .running(let remainingSeconds):
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60
            return language == .english
                ? String(format: "%02d:%02d remaining", minutes, seconds)
                : String(format: "%02d:%02d kaldı", minutes, seconds)

        case .breakTime(let remainingSeconds):
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60
            return language == .english
                ? String(format: "Break: %02d:%02d", minutes, seconds)
                : String(format: "Mola: %02d:%02d", minutes, seconds)

        case .completed:
            return language == .english ? "Completed" : "Tamamlandı"
        }
    }

    private func startRealtimeTicker(using selection: FamilyActivitySelection?) {
        countdownTask?.cancel()

        countdownTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                await MainActor.run {
                    self.recalculateSessionState(using: selection)
                }

                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func recalculateSessionState(using selection: FamilyActivitySelection?) {
        guard let snapshot = sessionPersistenceService.loadSnapshot() else {
            if testSessionState != .completed {
                testSessionState = .idle
            }
            return
        }

        let now = Date()

        if now < snapshot.sessionEndDate {
            let remaining = max(Int(snapshot.sessionEndDate.timeIntervalSince(now)), 0)
            testSessionState = .running(remainingSeconds: remaining)
            shieldStatusMessage = "Session started."
            return
        }

        if now >= snapshot.sessionEndDate && now < snapshot.breakEndDate {
            let remainingBreak = max(Int(snapshot.breakEndDate.timeIntervalSince(now)), 0)

            if case .breakTime = testSessionState {
                // already in break, just update remaining
            } else {
                if let selection {
                    applyShieldWithoutDoubleCounting(using: selection)
                }
                shieldStatusMessage = "Time is up. Break started."
                feedbackManager.triggerWarningNotificationIfNeeded()
                soundManager.playBreakStartedSoundIfNeeded()
            }

            testSessionState = .breakTime(remainingSeconds: remainingBreak)
            return
        }

        if now >= snapshot.breakEndDate {
            completeSessionIfNeeded()
        }
    }

    private func applyShieldWithoutDoubleCounting(using selection: FamilyActivitySelection) {
        shieldManager.applyShield(using: selection)
    }

    private func completeSessionIfNeeded() {
        if testSessionState != .completed {
            shieldManager.clearShield()
            statsService.recordCompletedSession(breakDurationMinutes: breakDurationMinutes)
            testSessionState = .completed
            shieldStatusMessage = "Break ended. Access restored."
            sessionPersistenceService.clearSnapshot()
            feedbackManager.triggerSuccessNotificationIfNeeded()
            soundManager.playBreakEndedSoundIfNeeded()

            // ADDED FOR LOCAL NOTIFICATIONS - START
            // Clear any delivered notifications when session completes
            Task {
                await notificationManager.clearAllBreakNotifications()
            }
            // ADDED FOR LOCAL NOTIFICATIONS - END

            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(1))
                guard let self else { return }
                if self.testSessionState == .completed {
                    self.testSessionState = .idle
                }
            }
        }
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
