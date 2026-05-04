//
//  ScreenTimeShieldManager.swift
//  Pawse
//
//  Created by Mehdi Oturak on 4.05.2026.
//

import Foundation
import FamilyControls
import ManagedSettings
import Combine

@MainActor
final class ScreenTimeShieldManager: ObservableObject {
    private let store = ManagedSettingsStore()

    func applyShield(using selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    func clearShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
}
