//
//  SoundManager.swift
//  Pawse
//
//  Created by Mehdi Oturak on 10.05.2026.
//

import AudioToolbox

final class SoundManager {
    private let settingsService: SettingsService

    init(settingsService: SettingsService = SettingsService()) {
        self.settingsService = settingsService
    }

    func playSessionStartedSoundIfNeeded() {
        guard settingsService.getSoundEnabled() else { return }
        AudioServicesPlaySystemSound(1104)
    }

    func playBreakStartedSoundIfNeeded() {
        guard settingsService.getSoundEnabled() else { return }
        AudioServicesPlaySystemSound(1005)
    }

    func playBreakEndedSoundIfNeeded() {
        guard settingsService.getSoundEnabled() else { return }
        AudioServicesPlaySystemSound(1113)
    }

    func playCancellationSoundIfNeeded() {
        guard settingsService.getSoundEnabled() else { return }
        AudioServicesPlaySystemSound(1103)
    }
}
