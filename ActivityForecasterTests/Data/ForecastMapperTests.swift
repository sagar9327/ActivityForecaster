//
//  ForecastMapperTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class ForecastMapperTests: XCTestCase {

    private let sampleLocation = Location(
        name: "London",
        country: "United Kingdom",
        administrativeArea: "England",
        latitude: 51.5074,
        longitude: -0.1278
    )

    func testMapValidForecastResponseToForecast() throws {
        let daily = ForecastResponse.DailyResponse(
            time: ["2026-09-02", "2026-09-03"],
            weatherCode: [0, 61],
            temperature2mMax: [22.5, 18.0],
            temperature2mMin: [14.0, 11.2],
            precipitationSum: [0.0, 4.2],
            snowfallSum: [0.0, 0.0],
            windSpeed10mMax: [12.4, 25.1]
        )
        let response = ForecastResponse(
            latitude: 51.5074,
            longitude: -0.1278,
            timezone: "GMT",
            dailyUnits: nil,
            daily: daily
        )

        let forecast = try ForecastMapper.map(response, for: sampleLocation)

        XCTAssertEqual(forecast.location, sampleLocation)
        XCTAssertEqual(forecast.dailyForecasts.count, 2)

        let day1 = forecast.dailyForecasts[0]
        XCTAssertEqual(day1.temperatureMax, 22.5)
        XCTAssertEqual(day1.temperatureMin, 14.0)
        XCTAssertEqual(day1.precipitationSum, 0.0)
        XCTAssertEqual(day1.snowfallSum, 0.0)
        XCTAssertEqual(day1.windSpeedMax, 12.4)
        XCTAssertEqual(day1.weatherCode, 0)

        let day2 = forecast.dailyForecasts[1]
        XCTAssertEqual(day2.temperatureMax, 18.0)
        XCTAssertEqual(day2.precipitationSum, 4.2)
        XCTAssertEqual(day2.weatherCode, 61)
    }

    func testISO8601DateConversion() {
        let parsedDate = ForecastMapper.parseDate("2026-09-02")
        XCTAssertNotNil(parsedDate)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let components = calendar.dateComponents([.year, .month, .day], from: parsedDate!)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 9)
        XCTAssertEqual(components.day, 2)

        XCTAssertNil(ForecastMapper.parseDate("invalid-date-string"))
    }

    func testInvalidDateInResponseThrowsError() {
        let daily = ForecastResponse.DailyResponse(
            time: ["INVALID_DATE_FORMAT"],
            weatherCode: [0],
            temperature2mMax: [22.5],
            temperature2mMin: [14.0],
            precipitationSum: [0.0],
            snowfallSum: [0.0],
            windSpeed10mMax: [12.4]
        )
        let response = ForecastResponse(
            latitude: 51.5,
            longitude: -0.12,
            timezone: "GMT",
            dailyUnits: nil,
            daily: daily
        )

        XCTAssertThrowsError(try ForecastMapper.map(response, for: sampleLocation)) { error in
            guard let netErr = error as? NetworkError,
                  case .mappingError(let reason) = netErr else {
                XCTFail("Expected NetworkError.mappingError, got \(error)")
                return
            }
            XCTAssertTrue(reason.contains("Invalid date"))
        }
    }

    func testMismatchedParallelArraysThrowsError() {
        let daily = ForecastResponse.DailyResponse(
            time: ["2026-09-02", "2026-09-03"],
            weatherCode: [0], // mismatched count!
            temperature2mMax: [22.5, 18.0],
            temperature2mMin: [14.0, 11.2],
            precipitationSum: [0.0, 4.2],
            snowfallSum: [0.0, 0.0],
            windSpeed10mMax: [12.4, 25.1]
        )
        let response = ForecastResponse(
            latitude: 51.5,
            longitude: -0.12,
            timezone: "GMT",
            dailyUnits: nil,
            daily: daily
        )

        XCTAssertThrowsError(try ForecastMapper.map(response, for: sampleLocation)) { error in
            guard let netErr = error as? NetworkError,
                  case .mappingError(let reason) = netErr else {
                XCTFail("Expected NetworkError.mappingError, got \(error)")
                return
            }
            XCTAssertTrue(reason.contains("Mismatched"))
        }
    }

    func testMissingDailyDataThrowsError() {
        let response = ForecastResponse(
            latitude: 51.5,
            longitude: -0.12,
            timezone: "GMT",
            dailyUnits: nil,
            daily: nil
        )

        XCTAssertThrowsError(try ForecastMapper.map(response, for: sampleLocation))
    }
}
