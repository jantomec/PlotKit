import XCTest
@testable import PlotKit

final class PlotKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PlotKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
