import XCTest
@testable import __TARGET__

final class ItemTests: XCTestCase {
    func testItemDefaults() {
        let item = Item(title: "A")
        XCTAssertEqual(item.title, "A")
        XCTAssertLessThanOrEqual(item.createdAt.timeIntervalSinceNow, 1)
    }
    func testFreeLimitIsSmallButUseful() {
        XCTAssertGreaterThanOrEqual(FreeLimits.maxItems, 3)
    }
}
