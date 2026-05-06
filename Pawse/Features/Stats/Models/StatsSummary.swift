//
//  StatsSummary.swift
//  Pawse
//
//  Created by Mehdi Oturak on 5.05.2026.
//

import Foundation

struct StatsSummary: Codable {
    var completedSessionsCount: Int
    var totalBreakMinutes: Int
    var appliedShieldCount: Int
    var mostInterruptedAppName: String

    static let `default` = StatsSummary(
        completedSessionsCount: 0,
        totalBreakMinutes: 0,
        appliedShieldCount: 0,
        mostInterruptedAppName: "-"
    )
}
