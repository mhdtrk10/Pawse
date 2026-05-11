//
//  SettingsView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var premiumAccessManager: PremiumAccessManager
    @EnvironmentObject private var storeKitManager: StoreKitManager

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.preferences) {
                    Toggle(L10n.sound, isOn: Binding(
                        get: { viewModel.soundEnabled },
                        set: { viewModel.updateSoundEnabled($0) }
                    ))

                    Toggle(L10n.haptics, isOn: Binding(
                        get: { viewModel.hapticsEnabled },
                        set: { viewModel.updateHapticsEnabled($0) }
                    ))
                }

                Section(L10n.language) {
                    Picker("", selection: $viewModel.selectedLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedLanguage) { _, newValue in
                        viewModel.updateLanguage(newValue)
                        languageManager.updateLanguage(newValue)
                    }
                }

                Section(L10n.demo) {
                    Button(L10n.loadDemoSettings) {
                        viewModel.applyDemoSettings()
                    }
                }
                /*
                Section(languageManager.selectedLanguage == .english ? "Premium Test" : "Premium Test") {
                    premiumStatusRow(
                        title: languageManager.selectedLanguage == .english ? "Monthly Premium" : "Aylık Premium",
                        value: premiumAccessManager.isMonthlyPremiumActive
                            ? (languageManager.selectedLanguage == .english ? "Active" : "Aktif")
                            : (languageManager.selectedLanguage == .english ? "Inactive" : "Pasif")
                    )

                    premiumStatusRow(
                        title: languageManager.selectedLanguage == .english ? "Unlocked Cats" : "Açılan Kediler",
                        value: "\(premiumAccessManager.unlockedCatIDs.count)"
                    )

                    Button {
                        premiumAccessManager.activateMonthlyPremiumForTesting()
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Activate Monthly Premium (Local Test)" : "Aylık Premium Aç (Yerel Test)")
                    }

                    Button {
                        premiumAccessManager.deactivateMonthlyPremiumForTesting()
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Deactivate Monthly Premium (Local Test)" : "Aylık Premium Kapat (Yerel Test)")
                    }

                    Button {
                        premiumAccessManager.clearUnlockedCatsForTesting()
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Clear Unlocked Cats (Local Only)" : "Açılan Kedileri Temizle (Sadece Yerel)")
                    }

                    Button(role: .destructive) {
                        premiumAccessManager.lockAllForTesting()
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Clear Local Premium UI State" : "Yerel Premium Durumunu Temizle")
                    }

                    Text(
                        languageManager.selectedLanguage == .english
                        ? "StoreKit test purchases remain active until you clear transactions from Xcode. These buttons only reset local app state."
                        : "StoreKit test satın alımları, Xcode üzerinden transaction temizlenene kadar aktif kalır. Bu butonlar sadece uygulamanın yerel durumunu sıfırlar."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                */
                Section(languageManager.selectedLanguage == .english ? "Purchases" : "Satın Alımlar") {
                    Button {
                        Task {
                            let success = await storeKitManager.restorePurchases()
                            if success {
                                premiumAccessManager.syncWithStoreKitPurchasedIDs(storeKitManager.purchasedProductIDs)
                            }
                        }
                    } label: {
                        HStack {
                            Text(languageManager.selectedLanguage == .english ? "Restore Purchases" : "Satın Alımları Geri Yükle")

                            Spacer()

                            if storeKitManager.isRestoringPurchases {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(storeKitManager.isRestoringPurchases)
                }

                Section(L10n.about) {
                    Text("Pawse v1.0")
                    Text(L10n.privacyPolicy)
                    Text(L10n.contact)
                }
            }
            .navigationTitle(L10n.settings)
            .alert(
                languageManager.selectedLanguage == .english ? "Restore Purchases" : "Satın Alımları Geri Yükle",
                isPresented: Binding(
                    get: { storeKitManager.restoreMessage != nil },
                    set: { if !$0 { storeKitManager.clearRestoreMessage() } }
                )
            ) {
                Button(languageManager.selectedLanguage == .english ? "OK" : "Tamam") {
                    storeKitManager.clearRestoreMessage()
                }
            } message: {
                Text(
                    languageManager.selectedLanguage == .english
                    ? localizedRestoreMessageEN(storeKitManager.restoreMessage)
                    : localizedRestoreMessageTR(storeKitManager.restoreMessage)
                )
            }
        }
    }

    @ViewBuilder
    private func premiumStatusRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
    private func localizedRestoreMessageEN(_ message: String?) -> String {
        switch message {
        case "Purchases restored.":
            return "Purchases restored."
        case "Failed to restore purchases.":
            return "Failed to restore purchases."
        default:
            return message ?? ""
        }
    }

    private func localizedRestoreMessageTR(_ message: String?) -> String {
        switch message {
        case "Purchases restored.":
            return "Satın alımlar geri yüklendi."
        case "Failed to restore purchases.":
            return "Satın alımlar geri yüklenemedi."
        default:
            return message ?? ""
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageManager())
        .environmentObject(PremiumAccessManager())
}
