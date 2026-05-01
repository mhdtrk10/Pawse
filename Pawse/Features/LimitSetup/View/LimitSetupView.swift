//
//  LimitSetupView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 30.04.2026.
//

import SwiftUI

struct LimitSetupView: View {
    @StateObject private var viewModel = LimitSetupViewModel()
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CardContainer {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(L10n.dailyLimit)
                            .font(.headline)

                        Text(L10n.limitSetupDailyDescription)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)

                        flowLayout(
                            options: viewModel.dailyLimitOptions,
                            selectedValue: viewModel.selectedDailyLimit
                        ) { option in
                            viewModel.selectedDailyLimit = option.minutes
                        }
                    }
                }

                CardContainer {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(L10n.breakDuration)
                            .font(.headline)

                        Text(L10n.limitSetupBreakDescription)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)

                        flowLayout(
                            options: viewModel.breakDurationOptions,
                            selectedValue: viewModel.selectedBreakDuration
                        ) { option in
                            viewModel.selectedBreakDuration = option.minutes
                        }
                    }
                }

                Button {
                    viewModel.saveSettings()
                } label: {
                    Text(L10n.saveSettings)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle(L10n.limitSetupTitle)
        .alert(L10n.savedTitle, isPresented: $viewModel.didSaveSuccessfully) {
            Button(L10n.ok) {
                viewModel.resetSaveState()
            }
        } message: {
            Text(L10n.limitSavedMessage)
        }
    }

    @ViewBuilder
    private func flowLayout(
        options: [TimeLimitOption],
        selectedValue: Int,
        onTap: @escaping (TimeLimitOption) -> Void
    ) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 10)], spacing: 10) {
            ForEach(options) { option in
                Button {
                    onTap(option)
                } label: {
                    OptionChip(
                        title: LocalizationHelper.localizedMinutes(
                            option.minutes,
                            language: languageManager.selectedLanguage
                        ),
                        isSelected: selectedValue == option.minutes
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LimitSetupView()
            .environmentObject(LanguageManager())
    }
}
