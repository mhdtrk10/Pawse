//
//  StoreKitManager.swift
//  Pawse
//
//  Created by Mehdi Oturak on 10.05.2026.
//
import Combine
import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoadingProducts = false
    @Published var isPurchaseInProgress = false
    @Published var purchaseErrorMessage: String?
    @Published var restoreMessage: String?
    @Published var isRestoringPurchases = false

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }


        do {
            let storeProducts = try await Product.products(for: StoreProductID.all)
            self.products = storeProducts.sorted { $0.id < $1.id }
        } catch {
            print("Failed to load StoreKit products: \(error)")
            purchaseErrorMessage = "Failed to load products."
        }
    }

    func refreshEntitlements() async {
        var purchasedIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            purchasedIDs.insert(transaction.productID)
        }

        self.purchasedProductIDs = purchasedIDs
    }

    func purchase(productID: String) async -> Bool {
        print("Attempting purchase for:", productID)
        print("Available loaded products:", products.map(\.id))

        guard let product = products.first(where: { $0.id == productID }) else {
            purchaseErrorMessage = "Product not found."
            print("Product not found for ID:", productID)
            return false
        }

        isPurchaseInProgress = true
        defer { isPurchaseInProgress = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    purchaseErrorMessage = "Purchase could not be verified."
                    print("Purchase verification failed.")
                    return false
                }

                await transaction.finish()
                await refreshEntitlements()
                print("Purchase success:", transaction.productID)
                return true

            case .userCancelled:
                print("User cancelled purchase.")
                return false

            case .pending:
                purchaseErrorMessage = "Purchase is pending."
                print("Purchase pending.")
                return false

            @unknown default:
                purchaseErrorMessage = "Unknown purchase result."
                print("Unknown purchase result.")
                return false
            }
        } catch {
            print("Purchase failed with error:", error)
            purchaseErrorMessage = "Purchase failed."
            return false
        }
    }

    func restorePurchases() async -> Bool {
        isRestoringPurchases = true
        defer { isRestoringPurchases = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            restoreMessage = "Purchases restored."
            return true
        } catch {
            print("Restore purchases failed: \(error)")
            restoreMessage = "Failed to restore purchases."
            return false
        }
    }

    func isPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }

    func product(for id: String) -> Product? {
        products.first(where: { $0.id == id })
    }

    func clearPurchaseError() {
        purchaseErrorMessage = nil
    }

    func clearRestoreMessage() {
        restoreMessage = nil
    }
}
