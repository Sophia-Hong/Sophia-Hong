import XCTest
@testable import FactoryKit

final class FactoryKitTests: XCTestCase {
    func testDefaultOnboardingHasThreePages() {
        XCTAssertEqual(OnboardingPage.defaults(appName: "X").count, 3)
    }
    @MainActor func testEntitlementsDebugToggle() {
        Entitlements.shared._setPro(true)
        XCTAssertTrue(Entitlements.shared.isPro)
        Entitlements.shared._setPro(false)
    }
}
