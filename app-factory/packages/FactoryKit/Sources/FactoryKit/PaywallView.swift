import SwiftUI
import StoreKit

public struct PaywallConfig: Sendable {
    public var appName: String
    public var headline: String
    public var benefits: [String]
    public var productIDs: [String]
    public var highlightedProductID: String?
    public var termsURL: String
    public var privacyURL: String
    public init(appName: String, headline: String, benefits: [String], productIDs: [String], highlightedProductID: String? = nil, termsURL: String, privacyURL: String) {
        self.appName = appName; self.headline = headline; self.benefits = benefits; self.productIDs = productIDs
        self.highlightedProductID = highlightedProductID; self.termsURL = termsURL; self.privacyURL = privacyURL
    }
}

/// Guideline 3.1.2-compliant paywall: live prices, trial + renewal text, restore, terms/privacy links, always-visible close.
public struct PaywallView: View {
    @Environment(Entitlements.self) private var entitlements
    @Environment(\.dismiss) private var dismiss
    let config: PaywallConfig
    @State private var products: [Product] = []
    @State private var selected: Product?
    @State private var busy = false
    @State private var error: String?

    public init(config: PaywallConfig) { self.config = config }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text(config.headline).font(.largeTitle.bold()).multilineTextAlignment(.center)
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(config.benefits, id: \.self) { b in
                            Label(b, systemImage: "checkmark.circle.fill").foregroundStyle(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if products.isEmpty {
                        ProgressView().padding()
                    } else {
                        ForEach(products, id: \.id) { p in
                            productRow(p)
                        }
                    }
                    if let selected {
                        Button {
                            Task { await buy(selected) }
                        } label: {
                            Text(ctaText(selected)).frame(maxWidth: .infinity).padding(.vertical, 6)
                        }
                        .buttonStyle(.borderedProminent).disabled(busy)
                        Text(disclosure(selected)).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }
                    if let error { Text(error).font(.footnote).foregroundStyle(.red) }
                    HStack(spacing: 16) {
                        Button("Restore Purchases") { Task { await restore() } }
                        Link("Terms", destination: URL(string: config.termsURL) ?? URL(string: "https://apple.com")!)
                        Link("Privacy", destination: URL(string: config.privacyURL) ?? URL(string: "https://apple.com")!)
                    }
                    .font(.footnote)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                        .accessibilityLabel("Close")
                }
            }
            .task { await load() }
            .onChange(of: entitlements.isPro) { _, pro in if pro { dismiss() } }
        }
    }

    @ViewBuilder private func productRow(_ p: Product) -> some View {
        let isSel = selected?.id == p.id
        Button { selected = p } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(p.displayName).font(.headline)
                    Text(periodText(p)).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text(p.displayPrice).font(.headline)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).stroke(isSel ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: isSel ? 2 : 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(p.displayName), \(p.displayPrice)")
    }

    private func periodText(_ p: Product) -> String {
        guard let sub = p.subscription else { return "One-time purchase" }
        var s = "per \(unitName(sub.subscriptionPeriod))"
        if let intro = sub.introductoryOffer, intro.paymentMode == .freeTrial {
            s = "\(intro.period.value)-day free trial, then " + s
        }
        return s
    }
    private func unitName(_ period: Product.SubscriptionPeriod) -> String {
        let n = period.value
        switch period.unit {
        case .day: return n == 1 ? "day" : "\(n) days"
        case .week: return n == 1 ? "week" : "\(n) weeks"
        case .month: return n == 1 ? "month" : "\(n) months"
        case .year: return n == 1 ? "year" : "\(n) years"
        @unknown default: return "period"
        }
    }
    private func ctaText(_ p: Product) -> String {
        if let intro = p.subscription?.introductoryOffer, intro.paymentMode == .freeTrial { return "Start free trial" }
        return p.subscription == nil ? "Buy \(p.displayPrice)" : "Subscribe \(p.displayPrice)"
    }
    private func disclosure(_ p: Product) -> String {
        guard let sub = p.subscription else { return "One-time payment charged to your Apple ID." }
        let base = "Payment is charged to your Apple ID. Subscription renews automatically at \(p.displayPrice)/\(unitName(sub.subscriptionPeriod)) unless cancelled at least 24 hours before the end of the current period. Manage in Settings."
        if let intro = sub.introductoryOffer, intro.paymentMode == .freeTrial {
            return "Free for \(intro.period.value) days, then \(p.displayPrice)/\(unitName(sub.subscriptionPeriod)). " + base
        }
        return base
    }

    private func load() async {
        do {
            products = try await entitlements.provider.products(ids: config.productIDs)
            selected = products.first { $0.id == config.highlightedProductID } ?? products.first
        } catch { self.error = "Couldn't load prices. Check your connection." }
    }
    private func buy(_ p: Product) async {
        busy = true; defer { busy = false }
        do {
            if try await entitlements.provider.purchase(p) { await entitlements.refresh(); Analytics.track("purchase", ["product": p.id]) }
        } catch { self.error = error.localizedDescription }
    }
    private func restore() async {
        busy = true; defer { busy = false }
        do {
            _ = try await entitlements.provider.restore(); await entitlements.refresh()
            if !entitlements.isPro { error = "No previous purchase found." }
        } catch { self.error = error.localizedDescription }
    }
}
