//
//  StoreKitManager.swift
//  Walkaround
//
//  In-App Purchase management via Apple StoreKit 2 with persistent trip passes.
//

import Foundation
import StoreKit
import Combine

public enum PremiumTier: String, CaseIterable {
    case free
    case singleTripPass
    case annualPro
    case lifetime
}

@MainActor
public class StoreKitManager: ObservableObject {
    public static let shared = StoreKitManager()

    public static let singleTripProductId = "com.walkaround.single_trip"
    public static let annualProProductId = "com.walkaround.annual_pro"
    public static let lifetimeProductId = "com.walkaround.lifetime"

    @Published public var hasProAccess: Bool = false
    @Published public var remainingSingleTripPasses: Int {
        didSet {
            UserDefaults.standard.set(remainingSingleTripPasses, forKey: "tripPassesRemaining")
        }
    }
    @Published public var availableProducts: [Product] = []
    @Published public var isPurchasing: Bool = false
    @Published public var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    private init() {
        // Load persisted trip passes (first launch defaults to 1 free pass)
        let key = "tripPassesRemaining"
        if UserDefaults.standard.object(forKey: key) == nil {
            self.remainingSingleTripPasses = 1
            UserDefaults.standard.set(1, forKey: key)
        } else {
            self.remainingSingleTripPasses = UserDefaults.standard.integer(forKey: key)
        }

        // Listen for StoreKit 2 transaction updates
        updatesTask = listenForTransactions()
        Task {
            await fetchProducts()
            await updatePurchasedState()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    public func fetchProducts() async {
        do {
            let productIds = [
                Self.singleTripProductId,
                Self.annualProProductId,
                Self.lifetimeProductId
            ]
            let products = try await Product.products(for: productIds)
            self.availableProducts = products
        } catch {
            print("StoreKit fetch error: \(error)")
        }
    }

    public func purchase(product: Product) async -> Bool {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await updatePurchasedState()
                    return true
                case .unverified(_, let error):
                    errorMessage = "Purchase could not be verified: \(error.localizedDescription)"
                    return false
                }
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    public func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func updatePurchasedState() async {
        var pro = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.annualProProductId || transaction.productID == Self.lifetimeProductId {
                    pro = true
                }
            }
        }
        self.hasProAccess = pro
    }

    public func canExportDossier(for rental: Rental) -> Bool {
        if hasProAccess { return true }
        if remainingSingleTripPasses > 0 { return true }
        return false
    }

    public func consumeTripPass() {
        if !hasProAccess && remainingSingleTripPasses > 0 {
            remainingSingleTripPasses -= 1
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updatePurchasedState()
                }
            }
        }
    }
}
