import Foundation
import StoreKit
import UIKit

/// Asks for a rating after N significant events, at most once per 90 days (Apple caps at 3 prompts/365 days).
@MainActor
public final class ReviewPrompter {
    public static let shared = ReviewPrompter()
    public var threshold = 5
    private let d = UserDefaults.standard
    private let countKey = "fk.review.count", lastKey = "fk.review.last"

    public func recordSignificantEvent() {
        let c = d.integer(forKey: countKey) + 1
        d.set(c, forKey: countKey)
        guard c >= threshold else { return }
        let last = d.double(forKey: lastKey)
        guard Date().timeIntervalSince1970 - last > 90 * 86_400 else { return }
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
            d.set(Date().timeIntervalSince1970, forKey: lastKey)
            d.set(0, forKey: countKey)
        }
    }
}
