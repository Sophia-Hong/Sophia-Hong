import SwiftUI

public struct OnboardingPage: Identifiable, Sendable {
    public let id = UUID()
    public var symbol: String
    public var title: String
    public var body: String
    public init(symbol: String, title: String, body: String) { self.symbol = symbol; self.title = title; self.body = body }

    public static func defaults(appName: String) -> [OnboardingPage] {
        [
            .init(symbol: "sparkles", title: "Welcome to \(appName)", body: "Everything works offline. No account needed."),
            .init(symbol: "lock.shield", title: "Private by design", body: "Your data stays on your device."),
            .init(symbol: "bolt.fill", title: "Fast to start", body: "Tap continue and you're in."),
        ]
    }
}

/// Three-page onboarding; last page calls `onFinish`. No paywall here (show it after first value moment).
public struct OnboardingView: View {
    let pages: [OnboardingPage]
    let onFinish: () -> Void
    @State private var index = 0
    public init(pages: [OnboardingPage], onFinish: @escaping () -> Void) { self.pages = pages; self.onFinish = onFinish }

    public var body: some View {
        VStack {
            TabView(selection: $index) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { i, p in
                    VStack(spacing: 16) {
                        Image(systemName: p.symbol).font(.system(size: 72)).foregroundStyle(Color.accentColor)
                        Text(p.title).font(.title.bold()).multilineTextAlignment(.center)
                        Text(p.body).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }
                    .padding(32).tag(i)
                }
            }
            .tabViewStyle(.page)
            Button(index == pages.count - 1 ? "Get Started" : "Continue") {
                if index < pages.count - 1 { withAnimation { index += 1 } } else { Analytics.track("onboarding_done"); onFinish() }
            }
            .buttonStyle(.borderedProminent).padding()
        }
    }
}
