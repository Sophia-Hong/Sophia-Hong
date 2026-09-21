import SwiftUI
import StoreKit

public struct SettingsConfig: Sendable {
    public var appName: String
    public var supportEmail: String
    public var termsURL: String
    public var privacyURL: String
    public var paywall: PaywallConfig
    public init(appName: String, supportEmail: String, termsURL: String, privacyURL: String, paywall: PaywallConfig) {
        self.appName = appName; self.supportEmail = supportEmail; self.termsURL = termsURL; self.privacyURL = privacyURL; self.paywall = paywall
    }
}

/// Standard settings: upgrade/restore, rate, support, legal, version. Apps add rows via `extra`.
public struct SettingsView<Extra: View>: View {
    @Environment(Entitlements.self) private var entitlements
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    let config: SettingsConfig
    let extra: Extra
    @State private var showPaywall = false

    public init(config: SettingsConfig, @ViewBuilder extra: () -> Extra) { self.config = config; self.extra = extra() }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    if entitlements.isPro {
                        Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                    } else {
                        Button { showPaywall = true } label: { Label("Upgrade to Pro", systemImage: "star.fill") }
                    }
                    Button("Restore Purchases") { Task { _ = try? await entitlements.provider.restore(); await entitlements.refresh() } }
                }
                extra
                Section {
                    Button { requestReview() } label: { Label("Rate \(config.appName)", systemImage: "heart") }
                    Link(destination: URL(string: "mailto:\(config.supportEmail)")!) { Label("Contact Support", systemImage: "envelope") }
                }
                Section {
                    Link("Privacy Policy", destination: URL(string: config.privacyURL) ?? URL(string: "https://apple.com")!)
                    Link("Terms of Use", destination: URL(string: config.termsURL) ?? URL(string: "https://apple.com")!)
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                }
            }
            .navigationTitle("Settings")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .sheet(isPresented: $showPaywall) { PaywallView(config: config.paywall) }
        }
    }
}

public extension SettingsView where Extra == EmptyView {
    init(config: SettingsConfig) { self.init(config: config) { EmptyView() } }
}
