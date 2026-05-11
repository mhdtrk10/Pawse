//
//  PremiumAccessManager.swift
//  Pawse
//
//  Created by Mehdi Oturak on 8.05.2026.
//
import Combine
import Foundation

@MainActor
final class PremiumAccessManager: ObservableObject {
    @Published var isMonthlyPremiumActive: Bool
    @Published var unlockedCatIDs: Set<String>

    private let storage = UserDefaultsManager.shared

    init() {
        self.isMonthlyPremiumActive = storage.isMonthlyPremiumActive
        self.unlockedCatIDs = storage.loadUnlockedCatIDs()
    }

    func syncWithStoreKitPurchasedIDs(_ purchasedIDs: Set<String>) {
        // Reset everything first, then only add what's actually purchased
        var newUnlockedCatIDs: Set<String> = []
        var newMonthlyPremiumState = false

        if purchasedIDs.contains(StoreProductID.premiumMonthly) {
            newMonthlyPremiumState = true
        }

        if purchasedIDs.contains(StoreProductID.sleepyCat) {
            newUnlockedCatIDs.insert("sleepy_cat")
        }
        if purchasedIDs.contains(StoreProductID.angryCat) {
            newUnlockedCatIDs.insert("angry_cat")
        }
        if purchasedIDs.contains(StoreProductID.officeCat) {
            newUnlockedCatIDs.insert("office_cat")
        }
        if purchasedIDs.contains(StoreProductID.spaceCat) {
            newUnlockedCatIDs.insert("space_cat")
        }

        isMonthlyPremiumActive = newMonthlyPremiumState
        unlockedCatIDs = newUnlockedCatIDs
        persist()
        
        print("🔄 [PremiumAccessManager] Synced with StoreKit: Monthly=\(newMonthlyPremiumState), UnlockedCats=\(newUnlockedCatIDs)")
    }

    func activateMonthlyPremiumForTesting() {
        isMonthlyPremiumActive = true
        persist()
    }

    func deactivateMonthlyPremiumForTesting() {
        isMonthlyPremiumActive = false
        persist()
    }

    func unlockCatForTesting(_ catID: String) {
        unlockedCatIDs.insert(catID)
        persist()
    }

    func clearUnlockedCatsForTesting() {
        unlockedCatIDs.removeAll()
        persist()
    }

    func lockAllForTesting() {
        isMonthlyPremiumActive = false
        unlockedCatIDs.removeAll()
        persist()
    }

    func hasAccess(to cat: CatItem) -> Bool {
        if !cat.isPremium { return true }
        if isMonthlyPremiumActive { return true }
        return unlockedCatIDs.contains(cat.id)
    }

    func hasAccess(to feature: PremiumFeature) -> Bool {
        switch feature {
        case .premiumCat(let catID, _):
            return isMonthlyPremiumActive || unlockedCatIDs.contains(catID)
        case .customPhoto, .customGIF:
            return isMonthlyPremiumActive
        }
    }

    private func persist() {
        storage.isMonthlyPremiumActive = isMonthlyPremiumActive
        storage.saveUnlockedCatIDs(unlockedCatIDs)
    }
}
