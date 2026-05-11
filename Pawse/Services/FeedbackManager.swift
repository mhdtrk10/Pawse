//
//  FeedbackManager.swift
//  Pawse
//
//  Created by Mehdi Oturak on 10.05.2026.
//

import UIKit

final class FeedbackManager {
    private let settingsService: SettingsService

    init(settingsService: SettingsService = SettingsService()) {
        self.settingsService = settingsService
    }

    func triggerLightImpactIfNeeded() {
        guard settingsService.getHapticsEnabled() else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    func triggerMediumImpactIfNeeded() {
        guard settingsService.getHapticsEnabled() else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    func triggerSuccessNotificationIfNeeded() {
        guard settingsService.getHapticsEnabled() else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    func triggerWarningNotificationIfNeeded() {
        guard settingsService.getHapticsEnabled() else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
}
