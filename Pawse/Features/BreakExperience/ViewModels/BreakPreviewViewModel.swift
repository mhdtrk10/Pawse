//
//  BreakPreviewViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 4.05.2026.
//

import SwiftUI
import Combine
@MainActor
final class BreakPreviewViewModel: ObservableObject {
    @Published var catName: String = "Default Cat"
    @Published var remainingSeconds: Int = 120

    func formattedTime(language: AppLanguage) -> String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60

        switch language {
        case .english:
            return String(format: "%02d:%02d left", minutes, seconds)
        case .turkish:
            return String(format: "%02d:%02d kaldı", minutes, seconds)
        }
    }

    func title(language: AppLanguage) -> String {
        switch language {
        case .english:
            return "Break Time"
        case .turkish:
            return "Mola Zamanı"
        }
    }

    func subtitle(language: AppLanguage) -> String {
        switch language {
        case .english:
            return "Pawse stepped in. Take a short break and come back refreshed."
        case .turkish:
            return "Pawse devreye girdi. Kısa bir mola ver ve daha dinç geri dön."
        }
    }

    func catMessage(language: AppLanguage) -> String {
        switch language {
        case .english:
            return "\(catName) is watching your break."
        case .turkish:
            return "\(catName) molanı takip ediyor."
        }
    }
}
