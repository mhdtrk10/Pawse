//
//  StatsView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    statCard(title: L10n.todaysBreaks, value: "0")
                    statCard(
                        title: L10n.totalBreakMinutes,
                        value: LocalizationHelper.localizedMinutes(
                            0,
                            language: languageManager.selectedLanguage
                        )
                    )
                    statCard(title: L10n.blockedSessions, value: "0")
                    statCard(title: L10n.mostInterruptedApp, value: "-")
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle(L10n.stats)
        }
    }

    @ViewBuilder
    private func statCard(title: LocalizedStringKey, value: String) -> some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)

                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    StatsView()
        .environmentObject(LanguageManager())
}
