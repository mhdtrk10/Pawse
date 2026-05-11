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
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HomeStatusCard(summary: viewModel.homeSummary)

                    screenTimeAccessCard
                    sessionCard

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

                        NavigationLink {
                            BreakPreviewView(
                                catName: viewModel.activeCatName,
                                remainingSeconds: max(viewModel.breakDurationMinutes * 60, 1)
                            )
                        } label: {
                            QuickActionCard(
                                title: languageManager.selectedLanguage == .english ? "Preview Break Screen" : "Mola Ekranını Önizle",
                                subtitle: languageManager.selectedLanguage == .english ? "See how Pawse looks during a break" : "Pawse'un mola sırasında nasıl göründüğünü gör",
                                systemImageName: "moon.stars.fill"
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
                viewModel.restoreSessionIfNeeded(using: selectionStore.familyActivitySelection)
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
            .fullScreenCover(isPresented: isBreakPresented) {
                BreakPreviewView(
                    catName: viewModel.activeCatName,
                    remainingSeconds: viewModel.currentBreakRemainingSeconds
                )
                .environmentObject(languageManager)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    viewModel.loadSettings()
                    viewModel.handleAppDidBecomeActive(using: selectionStore.familyActivitySelection)
                }
            }
        }
    }

    @ViewBuilder
    private var screenTimeAccessCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(viewModel.screenTimeStatus == .approved ? AppColors.success : .orange)
                        .frame(width: 10, height: 10)

                    Text(languageManager.selectedLanguage == .english ? "Screen Time Access" : "Ekran Süresi Erişimi")
                        .font(.headline)

                    Spacer()
                }

                Text(screenTimeStatusText)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)

                if viewModel.screenTimeStatus != .approved {
                    Button {
                        Task {
                            await viewModel.requestScreenTimeAccess()
                        }
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Enable Access" : "Erişimi Aç")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var sessionCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Circle()
                        .fill(viewModel.sessionAccentColor())
                        .frame(width: 10, height: 10)

                    Text(viewModel.sessionTitle(language: languageManager.selectedLanguage))
                        .font(.headline)

                    Spacer()
                }

                Text(viewModel.sessionDescription(language: languageManager.selectedLanguage))
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.formattedRemainingTime(language: languageManager.selectedLanguage))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(viewModel.sessionAccentColor())

                    ProgressView(value: viewModel.progressValue())
                        .tint(viewModel.sessionAccentColor())
                }

                Text(viewModel.shieldStatusMessage)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)

                if !viewModel.isSessionRunning {
                    Button {
                        viewModel.startTestSession(using: selectionStore.familyActivitySelection)
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Start Session" : "Oturumu Başlat")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    Button {
                        viewModel.cancelTestSession()
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Cancel Session" : "Oturumu İptal Et")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var screenTimeStatusText: String {
        switch viewModel.screenTimeStatus {
        case .notDetermined:
            return languageManager.selectedLanguage == .english
                ? "Access has not been granted yet."
                : "Henüz erişim izni verilmedi."
        case .approved:
            return languageManager.selectedLanguage == .english
                ? "Screen Time access is active."
                : "Ekran Süresi erişimi aktif."
        case .denied:
            return languageManager.selectedLanguage == .english
                ? "Access was denied."
                : "Erişim reddedildi."
        case .error(let message):
            return languageManager.selectedLanguage == .english
                ? "Error: \(message)"
                : "Hata: \(message)"
        }
    }

    private var isBreakPresented: Binding<Bool> {
        Binding(
            get: { viewModel.isBreakActive },
            set: { _ in }
        )
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
