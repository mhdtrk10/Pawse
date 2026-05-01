//
//  HomeView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI
import FamilyControls

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var selectionStore = ScreenTimeSelectionStore()
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HomeStatusCard(summary: viewModel.homeSummary)

                    screenTimeAccessCard

                    summaryCard(
                        title: L10n.selectedApps,
                        value: LocalizationHelper.localizedAppsCount(
                            viewModel.selectedAppsCount,
                            language: languageManager.selectedLanguage
                        ),
                        icon: "app.badge.fill"
                    )

                    summaryCard(
                        title: L10n.dailyLimit,
                        value: LocalizationHelper.localizedMinutes(
                            viewModel.dailyLimitMinutes,
                            language: languageManager.selectedLanguage
                        ),
                        icon: "timer"
                    )

                    summaryCard(
                        title: L10n.breakDuration,
                        value: LocalizationHelper.localizedMinutes(
                            viewModel.breakDurationMinutes,
                            language: languageManager.selectedLanguage
                        ),
                        icon: "moon.fill"
                    )

                    summaryCard(
                        title: L10n.activeCat,
                        value: viewModel.activeCatName,
                        icon: "pawprint.fill"
                    )

                    VStack(spacing: 12) {
                        Button {
                            selectionStore.isPickerPresented = true
                        } label: {
                            QuickActionCard(
                                title: L10n.chooseApps,
                                subtitle: L10n.chooseAppsSubtitle,
                                systemImageName: "app.badge.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            LimitSetupView()
                        } label: {
                            QuickActionCard(
                                title: L10n.setLimits,
                                subtitle: L10n.setLimitsSubtitle,
                                systemImageName: "timer"
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        viewModel.resetToDefault()
                    } label: {
                        Text(L10n.resetDemo)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .padding(.top, 4)
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle(L10n.pawseTitle)
            .onAppear {
                viewModel.loadSettings()
                viewModel.updateSelectedAppsCount(from: selectionStore.familyActivitySelection)
            }
            .onChange(of: languageManager.selectedLanguage) { _, _ in
                viewModel.refreshLocalization()
            }
            .onChange(of: selectionStore.familyActivitySelection) { _, newValue in
                selectionStore.saveSelection()
                viewModel.updateSelectedAppsCount(from: newValue)
            }
            .familyActivityPicker(
                isPresented: $selectionStore.isPickerPresented,
                selection: $selectionStore.familyActivitySelection
            )
        }
    }

    @ViewBuilder
    private var screenTimeAccessCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Screen Time Access")
                    .font(.headline)

                Text(screenTimeStatusText)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)

                Button {
                    Task {
                        await viewModel.requestScreenTimeAccess()
                    }
                } label: {
                    Text("Enable Access")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var screenTimeStatusText: String {
        switch viewModel.screenTimeStatus {
        case .notDetermined:
            return "Not granted yet."
        case .approved:
            return "Access granted."
        case .denied:
            return "Access denied."
        case .error(let message):
            return "Error: \(message)"
        }
    }

    @ViewBuilder
    private func summaryCard(title: LocalizedStringKey, value: String, icon: String) -> some View {
        CardContainer {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)

                    Text(value)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(LanguageManager())
}
