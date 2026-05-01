//
//  LocalizationHelper.swift
//  Pawse
//
//  Created by Mehdi Oturak on 1.05.2026.
//

import Foundation

enum LocalizationHelper {
    static func localizedAppsCount(_ count: Int, language: AppLanguage) -> String {
        switch language {
        case .english:
            return "\(count) Apps"
        case .turkish:
            return "\(count) Uygulama"
        }
    }

    static func localizedMinutes(_ minutes: Int, language: AppLanguage) -> String {
        switch language {
        case .english:
            return "\(minutes) min"
        case .turkish:
            return "\(minutes) dk"
        }
    }

    static func localizedSelectedCount(_ count: Int, language: AppLanguage) -> String {
        switch language {
        case .english:
            return "\(count) selected"
        case .turkish:
            return "\(count) seçildi"
        }
    }
}
