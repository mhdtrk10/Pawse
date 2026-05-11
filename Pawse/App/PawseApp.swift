//
//  PawseApp.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI
// ADDED FOR LOCAL NOTIFICATIONS - START
import UserNotifications
// ADDED FOR LOCAL NOTIFICATIONS - END

@main
struct PawseApp: App {
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var premiumAccessManager = PremiumAccessManager()
    @StateObject private var storeKitManager = StoreKitManager()
    
    // ADDED FOR LOCAL NOTIFICATIONS - START
    @Environment(\.scenePhase) private var scenePhase
    // ADDED FOR LOCAL NOTIFICATIONS - END

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(languageManager)
                .environmentObject(premiumAccessManager)
                .environmentObject(storeKitManager)
                .environment(\.locale, languageManager.locale)
                .task {
                    await storeKitManager.loadProducts()
                    await storeKitManager.refreshEntitlements()
                    // Sync premium access with StoreKit purchases
                    premiumAccessManager.syncWithStoreKitPurchasedIDs(storeKitManager.purchasedProductIDs)
                }
                // ADDED FOR LOCAL NOTIFICATIONS - START
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        // Clear badge when app becomes active
                        Task {
                            await clearBadge()
                        }
                        // Re-sync premium access with StoreKit
                        Task {
                            await storeKitManager.refreshEntitlements()
                            premiumAccessManager.syncWithStoreKitPurchasedIDs(storeKitManager.purchasedProductIDs)
                        }
                    }
                }
                // ADDED FOR LOCAL NOTIFICATIONS - END
        }
    }
    
    // ADDED FOR LOCAL NOTIFICATIONS - START
    /// Clears the app badge number when user opens the app
    private func clearBadge() async {
        do {
            try await UNUserNotificationCenter.current().setBadgeCount(0)
            print("🔴 [Badge] Badge cleared")
        } catch {
            print("❌ [Badge] Error clearing badge: \(error)")
        }
    }
    // ADDED FOR LOCAL NOTIFICATIONS - END
}
