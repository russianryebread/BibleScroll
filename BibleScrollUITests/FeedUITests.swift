import XCTest

final class FeedUITests: XCTestCase {
    func testSwipeBackAndOpenHistory() {
        let app = XCUIApplication()
        app.launchArguments = ["-UITestHistory"]
        app.launch()

        XCTAssertTrue(app.buttons["JOHN 1:4–5  ·  KJV"].waitForExistence(timeout: 10))
        app.swipeDown()
        XCTAssertTrue(app.buttons["PSALM 23:1–2  ·  KJV"].waitForExistence(timeout: 5))

        app.buttons["Settings"].tap()
        let historyEntry = app.buttons.matching(NSPredicate(format: "label CONTAINS 'John 1:4–5'")).firstMatch
        for _ in 0..<4 where !historyEntry.exists { app.swipeUp() }
        XCTAssertTrue(historyEntry.exists)
    }

    func testReferenceOpensFullChapter() {
        let app = XCUIApplication()
        app.launchArguments = ["-UITestHistory"]
        app.launch()

        let reference = app.buttons["JOHN 1:4–5  ·  KJV"]
        XCTAssertTrue(reference.waitForExistence(timeout: 10))
        reference.tap()
        XCTAssertTrue(app.navigationBars["John 1"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["1"].exists)
    }

    func testLongHistoryOpensFullList() {
        let app = XCUIApplication()
        app.launchArguments = ["-UITestLongHistory"]
        app.launch()

        app.buttons["Settings"].tap()
        let allHistory = app.buttons["See all history (17)"]
        for _ in 0..<12 where !allHistory.isHittable { app.swipeUp() }
        XCTAssertTrue(allHistory.isHittable)
        allHistory.tap()
        XCTAssertTrue(app.navigationBars["Reading history"].waitForExistence(timeout: 5))
    }
}
