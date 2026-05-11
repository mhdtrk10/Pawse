//
//  UserDefaultsManager.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private init() {}

    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    // ADDED FOR LOCAL NOTIFICATIONS - START
    private let hasRequestedNotificationPermissionKey = "hasRequestedNotificationPermission"
    // ADDED FOR LOCAL NOTIFICATIONS - END

    var hasSeenOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingKey)
        }
    }
    
    // ADDED FOR LOCAL NOTIFICATIONS - START
    var hasRequestedNotificationPermission: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasRequestedNotificationPermissionKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasRequestedNotificationPermissionKey)
        }
    }
    // ADDED FOR LOCAL NOTIFICATIONS - END

    var selectedLanguage: AppLanguage {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: LocalStorageKeys.selectedLanguage),
                  let language = AppLanguage(rawValue: rawValue) else {
                return .english
            }
            return language
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: LocalStorageKeys.selectedLanguage)
        }
    }
    var isMonthlyPremiumActive: Bool {
        get {
            UserDefaults.standard.bool(forKey: LocalStorageKeys.monthlyPremiumActive)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: LocalStorageKeys.monthlyPremiumActive)
        }
    }
    var soundEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: LocalStorageKeys.soundEnabled) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: LocalStorageKeys.soundEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: LocalStorageKeys.soundEnabled)
        }
    }

    var hapticsEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: LocalStorageKeys.hapticsEnabled) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: LocalStorageKeys.hapticsEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: LocalStorageKeys.hapticsEnabled)
        }
    }

    func saveAppSettings(_ settings: AppSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: LocalStorageKeys.appSettings)
        } catch {
            print("Failed to save app settings: \(error)")
        }
    }

    func loadAppSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: LocalStorageKeys.appSettings) else {
            return .default
        }

        do {
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            print("Failed to load app settings: \(error)")
            return .default
        }
    }
    
    func saveStatsSummary(_ summary: StatsSummary) {
        do {
            let data = try JSONEncoder().encode(summary)
            UserDefaults.standard.set(data, forKey: LocalStorageKeys.statsSummary)
        } catch {
            print("Failed to save stats summary: \(error)")
        }
    }

    func loadStatsSummary() -> StatsSummary {
        guard let data = UserDefaults.standard.data(forKey: LocalStorageKeys.statsSummary) else {
            return .default
        }

        do {
            return try JSONDecoder().decode(StatsSummary.self, from: data)
        } catch {
            print("Failed to load stats summary: \(error)")
            return .default
        }
    }
    func saveActiveSessionSnapshot(_ snapshot: ActiveSessionSnapshot) {
        do {
            let data = try JSONEncoder().encode(snapshot)
            UserDefaults.standard.set(data, forKey: LocalStorageKeys.activeSessionSnapshot)
        } catch {
            print("Failed to save active session snapshot: \(error)")
        }
    }

    func loadActiveSessionSnapshot() -> ActiveSessionSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: LocalStorageKeys.activeSessionSnapshot) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(ActiveSessionSnapshot.self, from: data)
        } catch {
            print("Failed to load active session snapshot: \(error)")
            return nil
        }
    }

    func clearActiveSessionSnapshot() {
        UserDefaults.standard.removeObject(forKey: LocalStorageKeys.activeSessionSnapshot)
    }
    

    func saveUnlockedCatIDs(_ ids: Set<String>) {
        UserDefaults.standard.set(Array(ids), forKey: LocalStorageKeys.unlockedCatIDs)
    }

    func loadUnlockedCatIDs() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: LocalStorageKeys.unlockedCatIDs) ?? []
        return Set(array)
    }
}
