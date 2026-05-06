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

    var hasSeenOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingKey)
        }
    }

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
}
