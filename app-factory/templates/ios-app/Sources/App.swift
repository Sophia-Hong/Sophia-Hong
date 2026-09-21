import SwiftUI
import SwiftData
import FactoryKit

@main
struct __TARGET__App: App {
    @State private var entitlements = Entitlements.shared
    @AppStorage("onboarded") private var onboarded = false

    var body: some Scene {
        WindowGroup {
            Group {
                if onboarded {
                    ContentView()
                } else {
                    OnboardingView(pages: OnboardingPage.defaults(appName: "__APP_NAME__")) { onboarded = true }
                }
            }
            .environment(entitlements)
            .task { await entitlements.refresh() }
        }
        .modelContainer(for: [Item.self])
    }
}
