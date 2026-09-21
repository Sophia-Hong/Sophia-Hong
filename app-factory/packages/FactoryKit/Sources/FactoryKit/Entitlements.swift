import Foundation
import StoreKit
import Observation

/// Abstraction so RevenueCat (or a mock) can replace StoreKit 2 later without touching apps.
public protocol PurchaseProvider: Sendable {
    func products(ids: [String]) async throws -> [Product]
    func purchase(_ product: Product) async throws -> Bool
    func restore() async throws -> Bool
    func currentEntitlementIDs() async -> Set<String>
}

public struct StoreKitProvider: PurchaseProvider {
    public init() {}
    public func products(ids: [String]) async throws -> [Product] {
        try await Product.products(for: ids).sorted { $0.price < $1.price }
    }
    public func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            guard case .verified(let tx) = verification else { return false }
            await tx.finish()
            return true
        case .userCancelled, .pending: return false
        @unknown default: return false
        }
    }
    public func restore() async throws -> Bool {
        try await AppStore.sync()
        return await !currentEntitlementIDs().isEmpty
    }
    public func currentEntitlementIDs() async -> Set<String> {
        var ids = Set<String>()
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result, tx.revocationDate == nil { ids.insert(tx.productID) }
        }
        return ids
    }
}

/// App-wide pro state. Inject with `.environment(Entitlements.shared)`.
@Observable
@MainActor
public final class Entitlements {
    public static let shared = Entitlements()

    public private(set) var isPro = false
    public private(set) var activeProductIDs: Set<String> = []
    public var provider: PurchaseProvider = StoreKitProvider()
    private var updates: Task<Void, Never>?

    private init() {
        // Keep listening for renewals / refunds / family sharing changes.
        updates = Task { [weak self] in
            for await _ in Transaction.updates { await self?.refresh() }
        }
    }

    public func refresh() async {
        let ids = await provider.currentEntitlementIDs()
        activeProductIDs = ids
        isPro = !ids.isEmpty
    }

    #if DEBUG
    /// Tests and previews only.
    public func _setPro(_ value: Bool) { isPro = value }
    #endif
}
