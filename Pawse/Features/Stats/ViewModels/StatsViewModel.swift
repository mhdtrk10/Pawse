//
//  StatsViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 5.05.2026.
//
import Combine
import Foundation

@MainActor
final class StatsViewModel: ObservableObject {
    @Published var completedSessionsCount: Int = 0
    @Published var totalBreakMinutes: Int = 0
    @Published var appliedShieldCount: Int = 0
    @Published var mostInterruptedAppName: String = "-"

    private let statsService: StatsService

    init(statsService: StatsService = StatsService()) {
        self.statsService = statsService
        loadStats()
    }

    func loadStats() {
        let summary = statsService.getStatsSummary()
        completedSessionsCount = summary.completedSessionsCount
        totalBreakMinutes = summary.totalBreakMinutes
        appliedShieldCount = summary.appliedShieldCount
        mostInterruptedAppName = summary.mostInterruptedAppName
    }
}
