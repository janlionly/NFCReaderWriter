import XCTest
@testable import NFCReaderWriter

final class NFCReaderWriterTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NFCReaderWriter().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
