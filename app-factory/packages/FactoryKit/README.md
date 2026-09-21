# FactoryKit

Shared iOS 17+ Swift package every factory app depends on. Apps should **never** reimplement these.

| API | Use |
|---|---|
| `Entitlements.shared` (`@Observable`) | `isPro`, `activeProductIDs`, `refresh()`. Inject with `.environment(Entitlements.shared)` at the app root and `.task { await Entitlements.shared.refresh() }`. Gate paid features with `if entitlements.isPro`. |
| `PurchaseProvider` / `StoreKitProvider` | StoreKit 2 wrapper. Swap `Entitlements.shared.provider` for RevenueCat or a mock. |
| `PaywallView(config:)` | Guideline 3.1.2-compliant paywall. Config in `Sources/PaywallConfig.swift` of each app. Present as a sheet after the first value moment, never before onboarding. |
| `OnboardingView(pages:onFinish:)` | 3 pages by default (`OnboardingPage.defaults(appName:)`). |
| `SettingsView(config:) { extra rows }` | Upgrade/restore, rate, support mail, privacy/terms, version. |
| `ReviewPrompter.shared.recordSignificantEvent()` | Call on completed core actions; it self-throttles. |
| `Analytics.track(event, props)` | Local os_log only. |

Product ids convention: `<bundle id>.weekly` (3-day trial), `.yearly`, `.lifetime` (non-consumable). Games: `.removeads` (non-consumable), `.coins100` (consumable).

Changing this package changes every app; keep changes additive.
