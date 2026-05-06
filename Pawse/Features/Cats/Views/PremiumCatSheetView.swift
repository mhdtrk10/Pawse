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
                        .frame(width: 210, height: 210)

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
            AnimatedImageView(
                fileName: gifName,
                contentMode: .scaleAspectFill,
                cornerRadius: 24
            )
            .frame(width: 160, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(accent.opacity(0.18), lineWidth: 1)
            )
        } else if UIImage(named: cat.imageName) != nil {
            Image(cat.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(accent.opacity(0.18), lineWidth: 1)
                )
        } else {
            Image(systemName: cat.systemImageName)
                .font(.system(size: 54))
                .foregroundStyle(accent)
                .frame(width: 160, height: 160)
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
