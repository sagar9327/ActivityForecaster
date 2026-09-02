//
//  IndoorSightseeingScoringRuleTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class IndoorSightseeingScoringRuleTests: XCTestCase {

    private let rule = IndoorSightseeingScoringRule()
    private let now = Date()

    func testRainyWeatherEnhancesIndoorSuitability() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: 8.0,
            temperatureMin: 4.0,
            precipitationSum: 15.0,
            snowfallSum: 0.0,
            windSpeedMax: 35.0,
            weatherCode: 63
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertEqual(result.activity, .indoorSightseeing)
        XCTAssertGreaterThanOrEqual(result.score, 90)
        XCTAssertEqual(result.rating, .excellent)
    }

    func testDryWeatherIndoorSightseeing() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: 22.0,
            temperatureMin: 18.0,
            precipitationSum: 0.0,
            snowfallSum: 0.0,
            windSpeedMax: 10.0,
            weatherCode: 0
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertEqual(result.activity, .indoorSightseeing)
        XCTAssertGreaterThanOrEqual(result.score, 50)
        XCTAssertLessThanOrEqual(result.score, 89)
    }
}
