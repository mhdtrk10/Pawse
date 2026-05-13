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
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Hero Section
                    heroSection
                        .padding(.top, 12)
                    
                    // Title - Show cat name or premium title
                    if let cat = selectedCat {
                        Text(cat.name)
                            .font(.title.bold())
                            .padding(.top, 4)
                    } else {
                        Text("Pawse Premium")
                            .font(.title.bold())
                            .padding(.top, 4)
                    }
                    
                    // Subscription Type & Price (only for single cat unlocks)
                    if let singleProduct = storeKitManager.product(for: feature.singleUnlockProductID ?? "") {
                        HStack(spacing: 8) {
                            Text(singleProduct.displayPrice)
                                .font(.title2.bold())
                                .foregroundStyle(AppColors.primary)
                            
                            Text("•")
                                .foregroundStyle(AppColors.secondaryText)
                            
                            Text(languageManager.selectedLanguage == .english ? "One-time purchase" : "Tek seferlik")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    } else {
                        // For custom photo/gif - show feature-specific icon
                        Image(systemName: featureIcon)
                            .font(.system(size: 60))
                            .foregroundStyle(AppColors.primary.gradient)
                            .padding(.vertical, 8)
                    }
                    
                    // Features List - Compact spacing
                    VStack(alignment: .leading, spacing: 10) {
                        Text(languageManager.selectedLanguage == .english ? "Includes:" : "İçerikler:")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        FeatureRow(
                            icon: "sparkles",
                            text: languageManager.selectedLanguage == .english 
                                ? "Unlock premium cat animations" 
                                : "Premium kedi animasyonlarının kilidini aç"
                        )
                        
                        FeatureRow(
                            icon: "photo",
                            text: languageManager.selectedLanguage == .english 
                                ? "Custom photo & GIF support" 
                                : "Özel fotoğraf ve GIF desteği"
                        )
                        
                        FeatureRow(
                            icon: "star.fill",
                            text: languageManager.selectedLanguage == .english 
                                ? "Access all premium cats" 
                                : "Tüm premium kedilere erişim"
                        )
                        
                        FeatureRow(
                            icon: "crown.fill",
                            text: languageManager.selectedLanguage == .english 
                                ? "Exclusive themes and colors" 
                                : "Özel temalar ve renkler"
                        )
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                }
            }
            .safeAreaInset(edge: .bottom) {
                // CTA Buttons - Always visible at bottom
                VStack(spacing: 8) {
                    // Single Unlock Button (if available for this cat) - ONE-TIME PURCHASE
                    if let singleProductID = feature.singleUnlockProductID,
                       let singleProduct = storeKitManager.product(for: singleProductID) {
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
                            Group {
                                if storeKitManager.isPurchaseInProgress {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    HStack(spacing: 8) {
                                        Text(languageManager.selectedLanguage == .english ? "Unlock This Cat" : "Bu Kediyi Aç")
                                            .font(.callout.weight(.semibold))
                                        Text(singleProduct.displayPrice)
                                            .font(.callout.weight(.bold))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.primary)
                        .disabled(storeKitManager.isPurchaseInProgress)
                    }
                    
                    // Monthly Premium Button - SUBSCRIPTION
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
                        Group {
                            if storeKitManager.isPurchaseInProgress {
                                ProgressView()
                            } else {
                                if let monthlyProduct = monthlyProduct {
                                    HStack(spacing: 8) {
                                        Text(languageManager.selectedLanguage == .english ? "Monthly Premium" : "Aylık Premium")
                                            .font(.subheadline.weight(.medium))
                                        Text(monthlyProduct.displayPrice + " / " + (languageManager.selectedLanguage == .english ? "mo" : "ay"))
                                            .font(.subheadline.weight(.semibold))
                                    }
                                } else {
                                    Text(languageManager.selectedLanguage == .english ? "Monthly Premium" : "Aylık Premium")
                                        .font(.subheadline.weight(.medium))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.bordered)
                    .tint(AppColors.primary)
                    .disabled(storeKitManager.isPurchaseInProgress)
                    
                    HStack(spacing: 16) {
                        Button {
                            Task {
                                await storeKitManager.restorePurchases()
                                premiumAccessManager.syncWithStoreKitPurchasedIDs(storeKitManager.purchasedProductIDs)
                            }
                        } label: {
                            Text(languageManager.selectedLanguage == .english ? "Restore Purchases" : "Satın Almaları Geri Yükle")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppColors.primary)
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
                    
                    // Legal Links
                    HStack(spacing: 12) {
                        Link(destination: URL(string: "https://mhdtrk10.github.io")!) {
                            Text(languageManager.selectedLanguage == .english ? "Privacy Policy" : "Gizlilik Politikası")
                                .font(.caption2)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                        
                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(AppColors.secondaryText)
                        
                        Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                            Text(languageManager.selectedLanguage == .english ? "Terms of Use" : "Kullanım Koşulları")
                                .font(.caption2)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.regularMaterial)
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }
            }
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

    private var monthlyProduct: Product? {
        storeKitManager.product(for: feature.monthlyProductID)
    }
    
    private var featureIcon: String {
        switch feature {
        case .customPhoto:
            return "photo.badge.plus"
        case .customGIF:
            return "photo.on.rectangle.angled"
        default:
            return "sparkles"
        }
    }
}

// MARK: - Feature Row Component

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.primary)
                .frame(width: 18)
            
            Text(text)
                .font(.caption)
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    PremiumFeatureSheetView(feature: .premiumCat(catID: "space_cat", catName: "Space Cat"))
        .environmentObject(LanguageManager())
        .environmentObject(PremiumAccessManager())
        .environmentObject(StoreKitManager())
}
