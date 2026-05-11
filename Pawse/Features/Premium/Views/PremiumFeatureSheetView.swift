//
//  PremiumFeatureSheetView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 8.05.2026.
//

import SwiftUI
import StoreKit

struct PremiumFeatureSheetView: View {
    let feature: PremiumFeature

    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var premiumAccessManager: PremiumAccessManager
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @Environment(\.dismiss) private var dismiss

    private let catalogService = CatCatalogService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                

                heroSection
                    //.padding(.bottom, 12)
                
                Spacer()

                VStack(spacing: 10) {
                    Text(title)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                

                pricingCard
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    if let singleProductID = feature.singleUnlockProductID {
                        Button {
                            Task {
                                let success = await storeKitManager.purchase(productID: singleProductID)
                                if success {
                                    premiumAccessManager.syncWithStoreKitPurchasedIDs(storeKitManager.purchasedProductIDs)

                                    if case .premiumCat(let catID, _) = feature {
                                        premiumAccessManager.unlockCatForTesting(catID)
                                    }

                                    dismiss()
                                }
                            }
                        } label: {
                            Text(singleUnlockButtonTitle)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal)
                        .disabled(storeKitManager.isPurchaseInProgress)
                    }

                    Button {
                        Task {
                            let success = await storeKitManager.purchase(productID: feature.monthlyProductID)
                            if success {
                                premiumAccessManager.syncWithStoreKitPurchasedIDs(storeKitManager.purchasedProductIDs)
                                premiumAccessManager.activateMonthlyPremiumForTesting()
                                dismiss()
                            }
                        }
                    } label: {
                        Text(monthlyUnlockButtonTitle)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .disabled(storeKitManager.isPurchaseInProgress)

                    if storeKitManager.isPurchaseInProgress {
                        ProgressView()
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Maybe Later" : "Daha Sonra")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }

                
            }
            .padding()
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                languageManager.selectedLanguage == .english ? "Purchase Error" : "Satın Alma Hatası",
                isPresented: Binding(
                    get: { storeKitManager.purchaseErrorMessage != nil },
                    set: { if !$0 { storeKitManager.clearPurchaseError() } }
                )
            ) {
                Button(languageManager.selectedLanguage == .english ? "OK" : "Tamam") {
                    storeKitManager.clearPurchaseError()
                }
            } message: {
                Text(storeKitManager.purchaseErrorMessage ?? "")
            }
        }
    }

    @ViewBuilder
    private var heroSection: some View {
        let accent = heroAccentColor

        // Circle background removed - just show the media directly
        heroMedia(accent: accent)
            //.padding(.bottom, 12)
    }

    @ViewBuilder
    private func heroMedia(accent: Color) -> some View {
        if let cat = selectedCat {
            if let gifName = cat.animatedGIFName {
                // GIF: Rectangular shape (wider than tall) - larger size
                AnimatedImageView(
                    fileName: gifName,
                    contentMode: .scaleAspectFit,
                    cornerRadius: 32,
                    internalScale: 1.0
                )
                .frame(width: 300, height: 260)  // Rectangular: wider than tall
                .scaleEffect(0.62)  // Keep user's scaleEffect
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(accent.opacity(0.20), lineWidth: 2)
                )
            } else if UIImage(named: cat.imageName) != nil {
                // Photo: Rectangular shape (wider than tall) - larger size
                Image(cat.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 260)  // Larger rectangular (was 180x180)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(accent.opacity(0.20), lineWidth: 2)
                    )
            } else {
                Image(systemName: cat.systemImageName)
                    .font(.system(size: 80))  // Larger icon
                    .foregroundStyle(accent)
                    .frame(width: 260, height: 180)  // Rectangular frame
            }
        } else {
            Image(systemName: "crown.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.primary)
        }
    }

    @ViewBuilder
    private var pricingCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 14) {
                if let singleProduct = singleUnlockProduct {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(languageManager.selectedLanguage == .english ? "Single Unlock" : "Tekil Açma")
                            .font(.headline)

                        Text(singleProduct.displayPrice)
                            .font(.title3.bold())
                            .foregroundStyle(AppColors.primary)

                        Text(languageManager.selectedLanguage == .english ? "Unlock only this cat." : "Sadece bu kedinin kilidini aç.")
                            .font(.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }

                if let monthlyProduct = monthlyProduct {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(languageManager.selectedLanguage == .english ? "Monthly Premium" : "Aylık Premium")
                            .font(.headline)

                        Text(monthlyProduct.displayPrice)
                            .font(.title3.bold())
                            .foregroundStyle(AppColors.primary)

                        Text(
                            languageManager.selectedLanguage == .english
                            ? "All premium cats + Custom Photo + Custom GIF"
                            : "Tüm premium kediler + Özel Fotoğraf + Özel GIF"
                        )
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var selectedCat: CatItem? {
        switch feature {
        case .premiumCat(let catID, _):
            return catalogService.fetchCats().first(where: { $0.id == catID })
        case .customPhoto, .customGIF:
            return nil
        }
    }

    private var heroAccentColor: Color {
        if let selectedCat {
            return CatThemeHelper.color(for: selectedCat.accentColorKey)
        }
        return AppColors.primary
    }

    private var title: String {
        switch languageManager.selectedLanguage {
        case .english: return feature.titleEN
        case .turkish: return feature.titleTR
        }
    }

    private var message: String {
        switch languageManager.selectedLanguage {
        case .english: return feature.messageEN
        case .turkish: return feature.messageTR
        }
    }

    private var singleUnlockProduct: Product? {
        guard let id = feature.singleUnlockProductID else { return nil }
        return storeKitManager.product(for: id)
    }

    private var monthlyProduct: Product? {
        storeKitManager.product(for: feature.monthlyProductID)
    }

    private var singleUnlockButtonTitle: String {
        let price = singleUnlockProduct?.displayPrice ?? "$0.99"
        switch languageManager.selectedLanguage {
        case .english:
            return "Unlock This Cat for \(price)"
        case .turkish:
            return "Bu Kediyi \(price) ile Aç"
        }
    }

    private var monthlyUnlockButtonTitle: String {
        let price = monthlyProduct?.displayPrice ?? "$3.99"
        switch languageManager.selectedLanguage {
        case .english:
            return "Get Monthly Premium for \(price)"
        case .turkish:
            return "\(price) ile Aylık Premium Al"
        }
    }
}

#Preview {
    PremiumFeatureSheetView(feature: .premiumCat(catID: "space_cat", catName: "Space Cat"))
        .environmentObject(LanguageManager())
        .environmentObject(PremiumAccessManager())
        .environmentObject(StoreKitManager())
}
