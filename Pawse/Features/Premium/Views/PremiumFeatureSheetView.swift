//
//  PremiumFeatureSheetView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 8.05.2026.
//

import SwiftUI
import StoreKit

enum SubscriptionPlan: String {
    case monthly
    case yearly
}

struct PremiumFeatureSheetView: View {
    let feature: PremiumFeature

    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var premiumAccessManager: PremiumAccessManager
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: SubscriptionPlan = .yearly
    private let catalogService = CatCatalogService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Hero Section
                    heroSection
                        .padding(.top, 12)
                    
                    // Title
                    Text("Pawse Premium")
                        .font(.title.bold())
                    
                    // Plan Toggle with Save Badge
                    VStack(spacing: 12) {
                        planToggle
                        
                        // Price Display
                        priceDisplay
                    }
                    .padding(.horizontal)
                    
                    // Features List
                    VStack(alignment: .leading, spacing: 12) {
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
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
            .background(AppColors.background)
            .safeAreaInset(edge: .bottom) {
                bottomCTASection
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
    
    // MARK: - Plan Toggle
    
    @ViewBuilder
    private var planToggle: some View {
        HStack(spacing: 0) {
            // Monthly Button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedPlan = .monthly
                }
            } label: {
                VStack(spacing: 4) {
                    // Invisible badge placeholder for equal height
                    Text("PLACEHOLDER")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.clear)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                    
                    Text(languageManager.selectedLanguage == .english ? "Monthly" : "Aylık")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selectedPlan == .monthly ? .white : AppColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
                .background(
                    selectedPlan == .monthly 
                        ? AppColors.primary 
                        : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Yearly Button with Badge
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedPlan = .yearly
                }
            } label: {
                VStack(spacing: 4) {
                    // Save Badge
                    Text(languageManager.selectedLanguage == .english ? "SAVE 50%" : "%50 TASARRUF")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.orange)
                        )
                        .opacity(selectedPlan == .yearly ? 1.0 : 0.9)
                    
                    Text(languageManager.selectedLanguage == .english ? "Yearly" : "Yıllık")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selectedPlan == .yearly ? .white : AppColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
                .background(
                    selectedPlan == .yearly 
                        ? AppColors.primary 
                        : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray5))
        )
    }
    
    // MARK: - Price Display
    
    @ViewBuilder
    private var priceDisplay: some View {
        VStack(spacing: 8) {
            if selectedPlan == .monthly {
                if let monthlyProduct = storeKitManager.product(for: feature.monthlyProductID) {
                    VStack(spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(monthlyProduct.displayPrice)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(AppColors.primary)
                            
                            Text("/ " + (languageManager.selectedLanguage == .english ? "month" : "ay"))
                                .font(.subheadline)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                        
                        // Invisible placeholder to maintain height
                        Text(" ")
                            .font(.caption)
                            .foregroundStyle(.clear)
                    }
                } else {
                    ProgressView()
                }
            } else {
                if let yearlyProduct = storeKitManager.product(for: feature.yearlyProductID) {
                    VStack(spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(yearlyProduct.displayPrice)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(AppColors.primary)
                            
                            Text("/ " + (languageManager.selectedLanguage == .english ? "year" : "yıl"))
                                .font(.subheadline)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                        
                        // Monthly equivalent - with proper handling
                        monthlyEquivalentText(for: yearlyProduct)
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .frame(height: 80)
        .animation(.easeInOut(duration: 0.2), value: selectedPlan)
    }
    
    @ViewBuilder
    private func monthlyEquivalentText(for product: Product) -> some View {
        if let formatted = formatMonthlyEquivalent(for: product) {
            Text("≈ \(formatted)/\(languageManager.selectedLanguage == .english ? "mo" : "ay")")
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
    
    private func formatMonthlyEquivalent(for product: Product) -> String? {
        guard let price = product.price as? Decimal else { return nil }
        
        let monthlyEquivalent = price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = product.priceFormatStyle.currencyCode
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: monthlyEquivalent as NSNumber)
    }
    
    // MARK: - Bottom CTA Section
    
    @ViewBuilder
    private var bottomCTASection: some View {
        VStack(spacing: 12) {
            if storeKitManager.isLoadingProducts {
                HStack {
                    ProgressView()
                    Text(languageManager.selectedLanguage == .english ? "Loading products..." : "Ürünler yükleniyor...")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else if storeKitManager.products.isEmpty {
                // Error state
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    
                    Text(languageManager.selectedLanguage == .english 
                        ? "Unable to load products. Please check your internet connection and try again." 
                        : "Ürünler yüklenemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        Task {
                            await storeKitManager.loadProducts()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text(languageManager.selectedLanguage == .english ? "Retry" : "Tekrar Dene")
                        }
                        .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primary)
                }
                .padding()
            } else {
                // Main Subscribe Button
                subscribeButton
                
                // Billing info
                Text(billingText)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                
                // Restore Purchases
                Button {
                    Task {
                        await storeKitManager.restorePurchases()
                        premiumAccessManager.syncWithStoreKitPurchasedIDs(storeKitManager.purchasedProductIDs)
                    }
                } label: {
                    Text(languageManager.selectedLanguage == .english ? "Restore Purchases" : "Satın Almaları Geri Yükle")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppColors.primary)
                }
                .disabled(storeKitManager.isPurchaseInProgress)
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
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(.regularMaterial)
    }
    
    @ViewBuilder
    private var subscribeButton: some View {
        Button {
            Task {
                let productID = selectedPlan == .monthly ? feature.monthlyProductID : feature.yearlyProductID
                let success = await storeKitManager.purchase(productID: productID)
                if success {
                    premiumAccessManager.syncWithStoreKitPurchasedIDs(storeKitManager.purchasedProductIDs)
                    // Activate premium for testing (works for both monthly and yearly)
                    premiumAccessManager.activateMonthlyPremiumForTesting()
                    dismiss()
                }
            }
        } label: {
            subscribeButtonLabel
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppColors.primary)
        .disabled(storeKitManager.isPurchaseInProgress || currentProduct == nil)
    }
    
    @ViewBuilder
    private var subscribeButtonLabel: some View {
        if storeKitManager.isPurchaseInProgress {
            ProgressView()
                .tint(.white)
        } else if selectedPlan == .monthly {
            if let product = storeKitManager.product(for: feature.monthlyProductID) {
                Text("Subscribe — \(product.displayPrice)/\(languageManager.selectedLanguage == .english ? "month" : "ay")")
                    .font(.headline)
            } else {
                Text(languageManager.selectedLanguage == .english ? "Subscribe" : "Abone Ol")
                    .font(.headline)
            }
        } else {
            if let product = storeKitManager.product(for: feature.yearlyProductID) {
                Text("Subscribe — \(product.displayPrice)/\(languageManager.selectedLanguage == .english ? "year" : "yıl")")
                    .font(.headline)
            } else {
                Text(languageManager.selectedLanguage == .english ? "Subscribe" : "Abone Ol")
                    .font(.headline)
            }
        }
    }
    
    private var billingText: String {
        if selectedPlan == .monthly {
            return languageManager.selectedLanguage == .english 
                ? "Billed monthly. Cancel anytime." 
                : "Aylık ücretlendirilir. İstediğiniz zaman iptal edebilirsiniz."
        } else {
            return languageManager.selectedLanguage == .english 
                ? "Billed annually. Cancel anytime." 
                : "Yıllık ücretlendirilir. İstediğiniz zaman iptal edebilirsiniz."
        }
    }
    
    private var currentProduct: Product? {
        if selectedPlan == .monthly {
            return storeKitManager.product(for: feature.monthlyProductID)
        } else {
            return storeKitManager.product(for: feature.yearlyProductID)
        }
    }

    // MARK: - Hero Section

    @ViewBuilder
    private var heroSection: some View {
        Image(systemName: "crown.fill")
            .font(.system(size: 72))
            .foregroundStyle(
                LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .padding(.vertical, 12)
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
    
    private var yearlyProduct: Product? {
        storeKitManager.product(for: feature.yearlyProductID)
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
