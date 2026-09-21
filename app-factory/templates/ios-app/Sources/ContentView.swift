import SwiftUI
import SwiftData
import FactoryKit

/// Replace this with the real main screen from SPEC.md. Kept minimal so the template compiles as-is.
struct ContentView: View {
    @Environment(Entitlements.self) private var entitlements
    @Environment(\.modelContext) private var context
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]
    @State private var showPaywall = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Text(item.title)
                }
                .onDelete { idx in idx.map { items[$0] }.forEach(context.delete) }
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("Nothing yet", systemImage: "tray", description: Text("Tap + to add your first item."))
                }
            }
            .navigationTitle("__APP_NAME__")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape") }
                        .accessibilityLabel("Settings")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if entitlements.isPro || items.count < FreeLimits.maxItems {
                            context.insert(Item(title: "Item \(items.count + 1)"))
                            ReviewPrompter.shared.recordSignificantEvent()
                        } else {
                            showPaywall = true
                        }
                    } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Add item")
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView(config: .default) }
            .sheet(isPresented: $showSettings) { SettingsView(config: .default) }
        }
    }
}

enum FreeLimits {
    static let maxItems = 5
}
