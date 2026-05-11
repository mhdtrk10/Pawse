//
//  PremiumCatSheetView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 5.05.2026.
//

import SwiftUI

struct PremiumCatSheetView: View {
    let cat: CatItem

    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let accent = CatThemeHelper.color(for: cat.accentColorKey)

        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(accent.opacity(0.15))
                        .frame(width: 420, height: 420)  // DOUBLE original (210 x 2)

                    premiumCatImage(accent: accent)
                    
                    
                }

                VStack(spacing: 10) {
                    Text(cat.name)
                        .font(.title.bold())

                    Text(languageManager.selectedLanguage == .english ? "Premium Cat" : "Premium Kedi")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(accent)
                    
                    if cat.animatedGIFName != nil {
                        Text(languageManager.selectedLanguage == .english ? "Animated" : "Animasyonlu")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(accent)
                    }

                    Text(CatThemeHelper.localizedMoodMessage(for: cat, language: languageManager.selectedLanguage))
                        .font(.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                CardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(languageManager.selectedLanguage == .english ? "What makes it special?" : "Bunu özel yapan ne?")
                            .font(.headline)

                        Text(
                            languageManager.selectedLanguage == .english
                            ? "This cat comes with a more unique visual style and is reserved for premium content in future versions."
                            : "Bu kedi daha özel bir görsel stile sahiptir ve sonraki sürümlerde premium içerik için ayrılmıştır."
                        )
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)

                Button {
                    dismiss()
                } label: {
                    Text(languageManager.selectedLanguage == .english ? "Got it" : "Anladım")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)

                Text(languageManager.selectedLanguage == .english ? "Unlock flow coming soon" : "Kilidi açma akışı yakında")
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)

                Spacer()
            }
            .padding()
            .navigationTitle(languageManager.selectedLanguage == .english ? "Cat Details" : "Kedi Detayı")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func premiumCatImage(accent: Color) -> some View {
        if let gifName = cat.animatedGIFName {
            // DOUBLE original size (160 x 2 = 320)
            AnimatedImageView(
                fileName: gifName,
                contentMode: .scaleAspectFit,
                cornerRadius: 40,
                internalScale: 1.0
            )
            .frame(width: 320, height: 320)  // DOUBLE original (160 x 2)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(accent.opacity(0.18), lineWidth: 2)
            )
        } else if UIImage(named: cat.imageName) != nil {
            Image(cat.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 320, height: 320)  // DOUBLE original (160 x 2)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(accent.opacity(0.18), lineWidth: 2)
                )
        } else {
            Image(systemName: cat.systemImageName)
                .font(.system(size: 108))  // DOUBLE original (54 x 2)
                .foregroundStyle(accent)
                .frame(width: 320, height: 320)  // DOUBLE original (160 x 2)
        }
    }
    
}

#Preview {
    PremiumCatSheetView(
        cat: CatItem(
            id: "space_cat",
            name: "Space Cat",
            subtitle: "Premium",
            systemImageName: "sparkles",
            imageName: "space_cat_image",
            animatedGIFName: "cat_astronaut.gif",
            isPremium: true,
            accentColorKey: "purple",
            moodMessageEN: "A cosmic pause from the feed.",
            moodMessageTR: "Akıştan kozmik bir mola."
        )
    )
    .environmentObject(LanguageManager())
}
