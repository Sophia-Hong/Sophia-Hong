import FactoryKit

/// Per-app monetization wiring. Product ids must match Configuration/Products.storekit and App Store Connect.
extension PaywallConfig {
    static let `default` = PaywallConfig(
        appName: "__APP_NAME__",
        headline: "Unlock everything",
        benefits: ["Unlimited items", "All themes", "Widgets", "Priority support"],
        productIDs: ["__BUNDLE_ID__.weekly", "__BUNDLE_ID__.yearly", "__BUNDLE_ID__.lifetime"],
        highlightedProductID: "__BUNDLE_ID__.yearly",
        termsURL: "__TERMS_URL__",
        privacyURL: "__PRIVACY_URL__"
    )
}

extension SettingsConfig {
    static let `default` = SettingsConfig(
        appName: "__APP_NAME__",
        supportEmail: "__SUPPORT_EMAIL__",
        termsURL: "__TERMS_URL__",
        privacyURL: "__PRIVACY_URL__",
        paywall: .default
    )
}
