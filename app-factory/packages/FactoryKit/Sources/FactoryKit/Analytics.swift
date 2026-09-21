import Foundation
import OSLog

/// Local-only analytics: logs to the unified log. No network, no SDK, no privacy-manifest impact.
/// If you ever add a real backend, update every app's App Privacy answers first.
public enum Analytics {
    private static let log = Logger(subsystem: "factorykit", category: "analytics")
    public static func track(_ event: String, _ props: [String: String] = [:]) {
        log.info("\(event, privacy: .public) \(props.description, privacy: .public)")
    }
}
