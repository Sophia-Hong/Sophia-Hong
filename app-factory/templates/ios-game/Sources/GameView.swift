import SwiftUI
import SpriteKit
import FactoryKit

/// Entry screen for game-kind apps (copied over ContentView.swift by new_app.sh --game).
struct ContentView: View {
    @Environment(Entitlements.self) private var entitlements
    @State private var scene = GameScene(size: CGSize(width: 390, height: 844))
    @State private var showPaywall = false
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            SpriteView(scene: scene, preferredFramesPerSecond: 60)
                .ignoresSafeArea()
            HStack {
                if !entitlements.isPro {
                    Button("Remove ads") { showPaywall = true }.buttonStyle(.borderedProminent)
                }
                Button { showSettings = true } label: { Image(systemName: "gearshape") }
                    .accessibilityLabel("Settings")
            }
            .padding()
        }
        .sheet(isPresented: $showPaywall) { PaywallView(config: .default) }
        .sheet(isPresented: $showSettings) { SettingsView(config: .default) }
        .onAppear { scene.scaleMode = .resizeFill }
    }
}
