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

    // MARK: - Break Media
    var selectedBreakMediaTypeRawValue: String
    var customPhotoFileName: String?
    var customPhotoScale: Double
    var customPhotoOffsetX: Double
    var customPhotoOffsetY: Double
    var customGIFFileName: String?

    static let `default` = AppSettings(
        selectedAppsCount: 0,
        dailyLimitMinutes: 15,
        breakDurationMinutes: 2,
        activeCatName: "Default Cat",
        selectedApps: [],
        selectedBreakMediaTypeRawValue: BreakMediaType.builtInCat.rawValue,
        customPhotoFileName: nil,
        customPhotoScale: 1.0,
        customPhotoOffsetX: 0.0,
        customPhotoOffsetY: 0.0,
        customGIFFileName: nil
    )

    enum CodingKeys: String, CodingKey {
        case selectedAppsCount
        case dailyLimitMinutes
        case breakDurationMinutes
        case activeCatName
        case selectedApps
        case selectedBreakMediaTypeRawValue
        case customPhotoFileName
        case customPhotoScale
        case customPhotoOffsetX
        case customPhotoOffsetY
        case customGIFFileName
    }

    init(
        selectedAppsCount: Int,
        dailyLimitMinutes: Int,
        breakDurationMinutes: Int,
        activeCatName: String,
        selectedApps: [SelectedAppItem],
        selectedBreakMediaTypeRawValue: String,
        customPhotoFileName: String?,
        customPhotoScale: Double,
        customPhotoOffsetX: Double,
        customPhotoOffsetY: Double,
        customGIFFileName: String?
    ) {
        self.selectedAppsCount = selectedAppsCount
        self.dailyLimitMinutes = dailyLimitMinutes
        self.breakDurationMinutes = breakDurationMinutes
        self.activeCatName = activeCatName
        self.selectedApps = selectedApps
        self.selectedBreakMediaTypeRawValue = selectedBreakMediaTypeRawValue
        self.customPhotoFileName = customPhotoFileName
        self.customPhotoScale = customPhotoScale
        self.customPhotoOffsetX = customPhotoOffsetX
        self.customPhotoOffsetY = customPhotoOffsetY
        self.customGIFFileName = customGIFFileName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        selectedAppsCount = try container.decodeIfPresent(Int.self, forKey: .selectedAppsCount) ?? 0
        dailyLimitMinutes = try container.decodeIfPresent(Int.self, forKey: .dailyLimitMinutes) ?? 15
        breakDurationMinutes = try container.decodeIfPresent(Int.self, forKey: .breakDurationMinutes) ?? 2
        activeCatName = try container.decodeIfPresent(String.self, forKey: .activeCatName) ?? "Default Cat"
        selectedApps = try container.decodeIfPresent([SelectedAppItem].self, forKey: .selectedApps) ?? []

        selectedBreakMediaTypeRawValue = try container.decodeIfPresent(String.self, forKey: .selectedBreakMediaTypeRawValue)
            ?? BreakMediaType.builtInCat.rawValue
        customPhotoFileName = try container.decodeIfPresent(String.self, forKey: .customPhotoFileName)
        customPhotoScale = try container.decodeIfPresent(Double.self, forKey: .customPhotoScale) ?? 1.0
        customPhotoOffsetX = try container.decodeIfPresent(Double.self, forKey: .customPhotoOffsetX) ?? 0.0
        customPhotoOffsetY = try container.decodeIfPresent(Double.self, forKey: .customPhotoOffsetY) ?? 0.0
        customGIFFileName = try container.decodeIfPresent(String.self, forKey: .customGIFFileName)
    }

    var selectedBreakMediaType: BreakMediaType {
        get { BreakMediaType(rawValue: selectedBreakMediaTypeRawValue) ?? .builtInCat }
        set { selectedBreakMediaTypeRawValue = newValue.rawValue }
    }
}
