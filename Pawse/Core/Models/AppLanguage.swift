//
//  AppLanguage.swift
//  Pawse
//
//  Created by Mehdi Oturak on 1.05.2026.
//

import Foundation

enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case english = "en"
    case turkish = "tr"

    var id: String { rawValue }

    var localeIdentifier: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .turkish:
            return "Türkçe"
        }
    }
}
