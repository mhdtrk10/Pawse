//
//  CatThemeHelper.swift
//  Pawse
//
//  Created by Mehdi Oturak on 5.05.2026.
//

import SwiftUI

enum CatThemeHelper {
    static func color(for key: String) -> Color {
        switch key {
        case "orange":
            return .orange
        case "pink":
            return .pink
        case "blue":
            return .blue
        case "red":
            return .red
        case "gray":
            return .gray
        case "purple":
            return .purple
        default:
            return AppColors.catAccent
        }
    }

    static func localizedMoodMessage(for cat: CatItem, language: AppLanguage) -> String {
        switch language {
        case .english:
            return cat.moodMessageEN
        case .turkish:
            return cat.moodMessageTR
        }
    }
}
