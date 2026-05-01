//
//  AppSettings.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import Foundation

struct AppSettings: Codable {
    var selectedAppsCount: Int
    var dailyLimitMinutes: Int
    var breakDurationMinutes: Int
    var activeCatName: String
    var selectedApps: [SelectedAppItem]

    static let `default` = AppSettings(
        selectedAppsCount: 0,
        dailyLimitMinutes: 15,
        breakDurationMinutes: 2,
        activeCatName: "Default Cat",
        selectedApps: []
    )

    enum CodingKeys: String, CodingKey {
        case selectedAppsCount
        case dailyLimitMinutes
        case breakDurationMinutes
        case activeCatName
        case selectedApps
    }

    init(
        selectedAppsCount: Int,
        dailyLimitMinutes: Int,
        breakDurationMinutes: Int,
        activeCatName: String,
        selectedApps: [SelectedAppItem]
    ) {
        self.selectedAppsCount = selectedAppsCount
        self.dailyLimitMinutes = dailyLimitMinutes
        self.breakDurationMinutes = breakDurationMinutes
        self.activeCatName = activeCatName
        self.selectedApps = selectedApps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        selectedAppsCount = try container.decodeIfPresent(Int.self, forKey: .selectedAppsCount) ?? 0
        dailyLimitMinutes = try container.decodeIfPresent(Int.self, forKey: .dailyLimitMinutes) ?? 15
        breakDurationMinutes = try container.decodeIfPresent(Int.self, forKey: .breakDurationMinutes) ?? 2
        activeCatName = try container.decodeIfPresent(String.self, forKey: .activeCatName) ?? "Default Cat"
        selectedApps = try container.decodeIfPresent([SelectedAppItem].self, forKey: .selectedApps) ?? []
    }
}
