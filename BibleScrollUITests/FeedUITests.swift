import XCTest

final class FeedUITests: XCTestCase {
    func testSwipeBackAndOpenHistory() {
        let app = XCUIApplication()
        app.launchArguments = ["-UITestHistory"]
        app.launch()

        XCTAssertTrue(app.staticTexts["JOHN 1:4–5  ·  KJV"].waitForExistence(timeout: 10))
        app.swipeDown()
        XCTAssertTrue(app.staticTexts["PSALM 23:1–2  ·  KJV"].waitForExistence(timeout: 5))

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Reading history"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS 'John 1:4–5'")).firstMatch.exists)
    }
}
