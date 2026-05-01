//
//  AppSelectionView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 30.04.2026.
//
import SwiftUI

struct AppSelectionView: View {
    @StateObject private var viewModel = AppSelectionViewModel()
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CardContainer {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.appSelectionTitle)
                            .font(.headline)

                        Text(L10n.appSelectionDescription)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)

                        Text(
                            LocalizationHelper.localizedSelectedCount(
                                viewModel.selectedCount,
                                language: languageManager.selectedLanguage
                            )
                        )
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.primary)
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                LazyVStack(spacing: 12) {
                    ForEach(viewModel.apps) { app in
                        appRow(app)
                    }
                }

                Button {
                    viewModel.saveSelections()
                } label: {
                    Text(L10n.appSelectionSave)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle(L10n.appSelectionTitle)
        .alert(L10n.savedTitle, isPresented: $viewModel.didSaveSuccessfully) {
            Button(L10n.ok) {
                viewModel.resetSaveState()
            }
        } message: {
            Text(L10n.appSelectionSavedMessage)
        }
    }

    @ViewBuilder
    private func appRow(_ app: SelectedAppItem) -> some View {
        Button {
            viewModel.toggleSelection(for: app)
        } label: {
            CardContainer {
                HStack(spacing: 14) {
                    Image(systemName: app.systemImageName)
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 32)

                    Text(app.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: app.isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(app.isSelected ? AppColors.success : AppColors.secondaryText)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AppSelectionView()
            .environmentObject(LanguageManager())
    }
}
