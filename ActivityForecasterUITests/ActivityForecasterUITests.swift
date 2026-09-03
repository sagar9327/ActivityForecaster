//
//  ActivityForecasterUITests.swift
//  ActivityForecasterUITests
//

import XCTest

final class ActivityForecasterUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCitySearchScreenElements() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["City Search"].exists, "City Search navigation title should exist")
        XCTAssertTrue(app.textFields["Search city or town..."].exists, "Search text field should exist")
    }

    @MainActor
    func testSearchFieldAcceptsInputAndClearButton() throws {
        let app = XCUIApplication()
        app.launch()

        let searchField = app.textFields["Search city or town..."]
        XCTAssertTrue(searchField.exists)

        searchField.tap()
        searchField.typeText("London")

        XCTAssertEqual(searchField.value as? String, "London")

        let clearButton = app.buttons["Clear search"]
        if clearButton.exists {
            clearButton.tap()
            XCTAssertEqual(searchField.value as? String, "Search city or town...")
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
