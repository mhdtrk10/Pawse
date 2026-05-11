//
//  SessionPersistenceService.swift
//  Pawse
//
//  Created by Mehdi Oturak on 8.05.2026.
//

import Foundation

final class SessionPersistenceService {
    private let storage = UserDefaultsManager.shared

    func saveSnapshot(_ snapshot: ActiveSessionSnapshot) {
        storage.saveActiveSessionSnapshot(snapshot)
    }

    func loadSnapshot() -> ActiveSessionSnapshot? {
        storage.loadActiveSessionSnapshot()
    }

    func clearSnapshot() {
        storage.clearActiveSessionSnapshot()
    }
}
