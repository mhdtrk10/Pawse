//
//  StatsView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    statCard(
                        title: L10n.todaysBreaks,
                        value: "\(viewModel.completedSessionsCount)"
                    )

                    statCard(
                        title: L10n.totalBreakMinutes,
                        value: LocalizationHelper.localizedMinutes(
                            viewModel.totalBreakMinutes,
                            language: languageManager.selectedLanguage
                        )
                    )

                    statCard(
                        title: L10n.blockedSessions,
                        value: "\(viewModel.appliedShieldCount)"
                    )

                    statCard(
                        title: L10n.mostInterruptedApp,
                        value: viewModel.mostInterruptedAppName
                    )
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle(L10n.stats)
            .onAppear {
                viewModel.loadStats()
            }
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
