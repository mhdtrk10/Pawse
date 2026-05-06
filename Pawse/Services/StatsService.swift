//
//  StatsService.swift
//  Pawse
//
//  Created by Mehdi Oturak on 5.05.2026.
//
import Foundation

final class StatsService {
    private let storage = UserDefaultsManager.shared

    func getStatsSummary() -> StatsSummary {
        storage.loadStatsSummary()
    }

    func saveStatsSummary(_ summary: StatsSummary) {
        storage.saveStatsSummary(summary)
    }

    func resetStats() {
        storage.saveStatsSummary(.default)
    }

    func recordShieldApplied() {
        var summary = getStatsSummary()
        summary.appliedShieldCount += 1
        saveStatsSummary(summary)
    }

    func recordCompletedSession(breakDurationMinutes: Int) {
        var summary = getStatsSummary()
        summary.completedSessionsCount += 1
        summary.totalBreakMinutes += breakDurationMinutes
        saveStatsSummary(summary)
    }
}
