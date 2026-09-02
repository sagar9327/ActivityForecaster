//
//  ForecastResponseTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class ForecastResponseTests: XCTestCase {

    func testDecodeForecastResponseFromJSON() throws {
        let jsonString = """
        {
          "latitude": 51.5,
          "longitude": -0.12,
          "timezone": "Europe/London",
          "daily_units": {
            "time": "iso8601",
            "weather_code": "wmo code",
            "temperature_2m_max": "°C",
            "temperature_2m_min": "°C",
            "precipitation_sum": "mm",
            "snowfall_sum": "cm",
            "wind_speed_10m_max": "km/h"
          },
          "daily": {
            "time": ["2026-09-02", "2026-09-03"],
            "weather_code": [0, 61],
            "temperature_2m_max": [22.5, 18.0],
            "temperature_2m_min": [14.0, 11.2],
            "precipitation_sum": [0.0, 4.2],
            "snowfall_sum": [0.0, 0.0],
            "wind_speed_10m_max": [12.4, 25.1]
          }
        }
        """

        let data = Data(jsonString.utf8)
        let response = try JSONDecoder().decode(ForecastResponse.self, from: data)

        XCTAssertEqual(response.latitude, 51.5)
        XCTAssertEqual(response.longitude, -0.12)
        XCTAssertEqual(response.timezone, "Europe/London")

        let daily = try XCTUnwrap(response.daily)
        XCTAssertEqual(daily.time, ["2026-09-02", "2026-09-03"])
        XCTAssertEqual(daily.weatherCode, [0, 61])
        XCTAssertEqual(daily.temperature2mMax, [22.5, 18.0])
        XCTAssertEqual(daily.temperature2mMin, [14.0, 11.2])
        XCTAssertEqual(daily.precipitationSum, [0.0, 4.2])
        XCTAssertEqual(daily.snowfallSum, [0.0, 0.0])
        XCTAssertEqual(daily.windSpeed10mMax, [12.4, 25.1])
    }
}
