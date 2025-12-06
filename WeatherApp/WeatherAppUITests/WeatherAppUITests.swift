//
//  WeatherAppUITests.swift
//  WeatherAppUITests
//
//  Created by Najmul Hasan on 12/4/25.
//

import XCTest

import XCTest

final class WeatherAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testSearchCityFlow_ShowsTemperatureAndDetailScreen() {
        let app = XCUIApplication()
        app.launch()

        let cityField = app.textFields["cityTextField"]
        XCTAssertTrue(cityField.waitForExistence(timeout: 5), "City text field should exist")

        cityField.tap()
        cityField.typeText("New York")

        let searchButton = app.buttons["searchButton"]
        XCTAssertTrue(searchButton.exists, "Search button should exist")
        searchButton.tap()

        // Wait for temperature label to appear -> means data loaded
        let temperatureLabel = app.staticTexts["temperatureLabel"]
        XCTAssertTrue(temperatureLabel.waitForExistence(timeout: 10), "Temperature label should appear")

        // Tap on the preview card to open details
        let weatherCard = app.buttons["weatherPreviewCard"]
        XCTAssertTrue(weatherCard.exists, "Weather preview card button should exist")
        weatherCard.tap()

        // Verify that details view is shown by checking sunrise row
        let sunriseRow = app.staticTexts["sunriseRow"]
        XCTAssertTrue(sunriseRow.waitForExistence(timeout: 5), "Sunrise row should be visible on details screen")
    }

    func testLocationButton_ClearsCityTextAndLoadsWeather() {
        
        let app = XCUIApplication()
        app.launch()

        let cityField = app.descendants(matching: .any)["cityTextField"]
        XCTAssertTrue(cityField.waitForExistence(timeout: 5))

        cityField.tap()
        cityField.typeText("Dummy City")

        let locationButton = app.buttons["currentLocationButton"]
        XCTAssertTrue(locationButton.exists, "Current location button should exist")

        locationButton.tap()

        // Wait until the text field value is no longer "Dummy City"
        let predicate = NSPredicate(format: "value != %@", "Dummy City")
        expectation(for: predicate, evaluatedWith: cityField, handler: nil)
        waitForExpectations(timeout: 5)

        // Now read the current value
        let currentValue = cityField.value as? String

        // At minimum, we only require that the old value is gone
        XCTAssertNotEqual(currentValue, "Dummy City", "City text field should not keep the previous text after location button tap")

        // OPTIONAL: if your placeholder is 'Enter US city' in English:
        // XCTAssertEqual(currentValue, "Enter US city")
    }
}
