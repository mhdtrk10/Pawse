//
//  CatsView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

struct CatsView: View {
    @StateObject private var viewModel = CatsViewModel()
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    
                    customPhotoCard
                    customGIFCard
                    ForEach(viewModel.cats) { cat in
                        catCard(cat: cat)
                    }
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle(L10n.cats)
            .onAppear {
                viewModel.loadSelectedCat()
            }
            .sheet(item: $viewModel.lockedCat) { cat in
                PremiumCatSheetView(cat: cat)
                    .environmentObject(languageManager)
            }
        }
    }

    @ViewBuilder
    private func catCard(cat: CatItem) -> some View {
        let accent = CatThemeHelper.color(for: cat.accentColorKey)

        Button {
            viewModel.handleTap(on: cat)
        } label: {
            CardContainer {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(accent.opacity(0.10))
                            .frame(width: 100, height: 100)

                        catThumbnail(for: cat, accent: accent)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(cat.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(cat.isPremium ? L10n.premium : L10n.free)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(accent)
                        
                        if cat.animatedGIFName != nil {
                            Text(languageManager.selectedLanguage == .english ? "Animated" : "Animasyonlu")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(accent)
                        }

                        Text(CatThemeHelper.localizedMoodMessage(for: cat, language: languageManager.selectedLanguage))
                            .font(.caption)
                            .foregroundStyle(AppColors.secondaryText)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    if cat.isPremium {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(AppColors.secondaryText)
                    } else if viewModel.isSelected(cat) {
                        Text(L10n.selected)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.success.opacity(0.15))
                            .foregroundStyle(AppColors.success)
                            .clipShape(Capsule())
                    } else {
                        Text(L10n.use)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(accent.opacity(0.12))
                            .foregroundStyle(accent)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func catThumbnail(for cat: CatItem, accent: Color) -> some View {
        if let gifName = cat.animatedGIFName {
            AnimatedImageView(
                fileName: gifName,
                contentMode: .scaleAspectFit,
                cornerRadius: 16,
                internalScale: 1.0
            )
            .frame(width: 84, height: 84)
            .scaleEffect(0.42)
            .clipShape(RoundedRectangle(cornerRadius: 16))

        } else if UIImage(named: cat.imageName) != nil {
            Image(cat.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 76, height: 76)
                .scaleEffect(1.08)
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 16))

        } else {
            Image(systemName: cat.systemImageName)
                .font(.system(size: 34))
                .foregroundStyle(accent)
                .frame(width: 84, height: 84)
        }
    }
    @ViewBuilder
    private var customPhotoCard: some View {
        NavigationLink {
            CustomPhotoEditorView()
        } label: {
            CardContainer {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(AppColors.primary.opacity(0.10))
                            .frame(width: 88, height: 88)

                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 30))
                            .foregroundStyle(AppColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(languageManager.selectedLanguage == .english ? "Custom Photo" : "Özel Fotoğraf")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(L10n.premium)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.primary)

                        Text(
                            languageManager.selectedLanguage == .english
                            ? "Use your own image as your break companion."
                            : "Kendi görselini mola arkadaşın olarak kullan."
                        )
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
        .buttonStyle(.plain)
    }
    @ViewBuilder
    private var customGIFCard: some View {
        NavigationLink {
            CustomGIFEditorView()
        } label: {
            CardContainer {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(AppColors.catAccent.opacity(0.10))
                            .frame(width: 88, height: 88)

                        Image(systemName: "sparkles.tv")
                            .font(.system(size: 30))
                            .foregroundStyle(AppColors.catAccent)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(languageManager.selectedLanguage == .english ? "Custom GIF" : "Özel GIF")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(L10n.premium)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.catAccent)

                        Text(
                            languageManager.selectedLanguage == .english
                            ? "Use your own animated GIF during breaks."
                            : "Molalarda kendi animasyonlu GIF'ini kullan."
                        )
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CatsView()
        .environmentObject(LanguageManager())
}
