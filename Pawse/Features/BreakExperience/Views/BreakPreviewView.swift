//
//  BreakPreviewView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 4.05.2026.
//

import SwiftUI

struct BreakPreviewView: View {
    let catName: String
    let remainingSeconds: Int

    @EnvironmentObject private var languageManager: LanguageManager

    private let catalogService = CatCatalogService()
    private let settingsService = SettingsService()
    private let customPhotoService = CustomPhotoService()
    private let customGIFService = CustomGIFService()
    var body: some View {
        let activeCat = catalogService.fetchCats().first { $0.name == catName }
        let accent = CatThemeHelper.color(for: activeCat?.accentColorKey ?? "orange")

        ZStack {
            LinearGradient(
                colors: [
                    accent.opacity(0.18),
                    accent.opacity(0.08),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(accent.opacity(0.12))
                        .frame(width: 280, height: 300)

                    breakHeroImage(activeCat: activeCat, accent: accent)
                }

                VStack(spacing: 10) {
                    Text(title)
                        .font(.system(size: 30, weight: .bold))

                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                CardContainer {
                    VStack(spacing: 12) {
                        Text(formattedTime)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(accent)

                        Text(catMessage)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)

                        if let activeCat, selectedBreakMediaType == .builtInCat {
                            Text(CatThemeHelper.localizedMoodMessage(for: activeCat, language: languageManager.selectedLanguage))
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)
                        } else if selectedBreakMediaType == .customPhoto {
                            Text(languageManager.selectedLanguage == .english ? "Your custom break photo is active." : "Özel mola fotoğrafın aktif.")
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)
                        } else if selectedBreakMediaType == .customGIF {
                            Text(languageManager.selectedLanguage == .english ? "Your custom break GIF is active." : "Özel mola GIF'in aktif.")
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                Spacer()

                VStack(spacing: 8) {
                    Text(languageManager.selectedLanguage == .english ? "Take a short pause" : "Kısa bir mola ver")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.secondaryText)

                    Text(languageManager.selectedLanguage == .english ? "Pawse will let you back in when the break ends." : "Mola bittiğinde Pawse seni tekrar içeri alacak.")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 24)
            }
            .padding()
        }
    }

    private var selectedBreakMediaType: BreakMediaType {
        settingsService.getBreakMediaType()
    }

    private var title: String {
        switch languageManager.selectedLanguage {
        case .english:
            return "Break Time"
        case .turkish:
            return "Mola Zamanı"
        }
    }

    private var subtitle: String {
        switch languageManager.selectedLanguage {
        case .english:
            return "Pawse stepped in. Take a short break and come back refreshed."
        case .turkish:
            return "Pawse devreye girdi. Kısa bir mola ver ve daha dinç geri dön."
        }
    }

    private var catMessage: String {
        if selectedBreakMediaType == .customGIF {
            switch languageManager.selectedLanguage {
            case .english:
                return "Your custom GIF is playing during your break."
            case .turkish:
                return "Özel GIF'in molan boyunca oynatılıyor."
            }
        }

        if selectedBreakMediaType == .customPhoto {
            switch languageManager.selectedLanguage {
            case .english:
                return "Your custom photo is watching your break."
            case .turkish:
                return "Özel fotoğrafın molanı takip ediyor."
            }
        }

        switch languageManager.selectedLanguage {
        case .english:
            return "\(catName) is watching your break."
        case .turkish:
            return "\(catName) molanı takip ediyor."
        }
    }

    private var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60

        switch languageManager.selectedLanguage {
        case .english:
            return String(format: "%02d:%02d left", minutes, seconds)
        case .turkish:
            return String(format: "%02d:%02d kaldı", minutes, seconds)
        }
    }

    @ViewBuilder
    private func breakHeroImage(activeCat: CatItem?, accent: Color) -> some View {
        if selectedBreakMediaType == .customGIF,
           let gifURL = customGIFService.loadGIFURL(fileName: settingsService.getCustomGIFFileName()) {

            AnimatedImageView(
                fileURL: gifURL,
                contentMode: .scaleAspectFit,
                cornerRadius: 28,
                internalScale: 1.0
            )
            .frame(width: 240, height: 270)
            .scaleEffect(0.48)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(accent.opacity(0.18), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)

        } else if selectedBreakMediaType == .customPhoto,
                  let image = customPhotoService.loadImage(fileName: settingsService.getCustomPhotoFileName()) {

            let transform = settingsService.getCustomPhotoTransform()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 205)
                .scaleEffect(transform.scale)
                .offset(x: transform.offsetX, y: transform.offsetY)
                .frame(width: 195, height: 230)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(accent.opacity(0.18), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)

        } else if let activeCat, let gifName = activeCat.animatedGIFName {
            AnimatedImageView(
                fileName: gifName,
                contentMode: .scaleAspectFit,
                cornerRadius: 28,
                internalScale: 1.0
            )
            .frame(width: 170, height: 205)
            .scaleEffect(0.9)
            .frame(width: 195, height: 230)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(accent.opacity(0.18), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)

        } else if let activeCat, UIImage(named: activeCat.imageName) != nil {
            Image(activeCat.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 205)
                .frame(width: 195, height: 230)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(accent.opacity(0.18), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)

        } else {
            Image(systemName: activeCat?.systemImageName ?? "pawprint.fill")
                .font(.system(size: 82))
                .foregroundStyle(accent)
                .frame(width: 195, height: 230)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(accent.opacity(0.10))
                )
        }
    }
}

#Preview {
    BreakPreviewView(catName: "Sleepy Cat", remainingSeconds: 120)
        .environmentObject(LanguageManager())
}
