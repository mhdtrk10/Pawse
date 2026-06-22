//
//  PremiumCatSheetView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 5.05.2026.
//

import SwiftUI
import StoreKit

struct PremiumCatSheetView: View {
    let cat: CatItem

    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @EnvironmentObject private var premiumAccessManager: PremiumAccessManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let accent = CatThemeHelper.color(for: cat.accentColorKey)

        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(accent.opacity(0.15))
                        .frame(width: 360, height: 360)

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
                    Task {
                        if let productID = singleUnlockProductID {
                            let success = await storeKitManager.purchase(productID: productID)
                            if success {
                                premiumAccessManager.syncWithStoreKitPurchasedIDs(storeKitManager.purchasedProductIDs)
                                premiumAccessManager.unlockCatForTesting(cat.id)
                                dismiss()
                            }
                        }
                    }
                } label: {
                    if storeKitManager.isPurchaseInProgress {
                        ProgressView()
                            .tint(.white)
                    } else if let product = singleUnlockProduct {
                        Text("\(languageManager.selectedLanguage == .english ? "Unlock for" : "Kilidi Aç") \(product.displayPrice)")
                            .font(.headline)
                    } else {
                        Text(languageManager.selectedLanguage == .english ? "Loading..." : "Yükleniyor...")
                            .font(.headline)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                .disabled(storeKitManager.isPurchaseInProgress || singleUnlockProduct == nil)

                HStack(spacing: 16) {
                    Button {
                        Task {
                            await storeKitManager.restorePurchases()
                            premiumAccessManager.syncWithStoreKitPurchasedIDs(storeKitManager.purchasedProductIDs)
                        }
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Restore Purchases" : "Satın Almaları Geri Yükle")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(accent)
                    }
                    .disabled(storeKitManager.isPurchaseInProgress)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Maybe Later" : "Daha Sonra")
                            .font(.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }

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
                contentMode: .scaleAspectFit,
                cornerRadius: 32,
                internalScale: 1.0
            )
            .frame(width: 280, height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(accent.opacity(0.18), lineWidth: 2)
            )
        } else if UIImage(named: cat.imageName) != nil {
            Image(cat.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 280, height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(accent.opacity(0.18), lineWidth: 2)
                )
        } else {
            Image(systemName: cat.systemImageName)
                .font(.system(size: 96))
                .foregroundStyle(accent)
                .frame(width: 280, height: 280)
        }
    }
    
    private var singleUnlockProductID: String? {
        switch cat.id {
        case "sleepy_cat": return StoreProductID.sleepyCat
        case "angry_cat": return StoreProductID.angryCat
        case "office_cat": return StoreProductID.officeCat
        case "space_cat": return StoreProductID.spaceCat
        default: return nil
        }
    }
    
    private var singleUnlockProduct: Product? {
        guard let productID = singleUnlockProductID else { return nil }
        return storeKitManager.product(for: productID)
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
    .environmentObject(StoreKitManager())
    .environmentObject(PremiumAccessManager())
}
