//
//  OutdoorSightseeingScoringRuleTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class OutdoorSightseeingScoringRuleTests: XCTestCase {

    private let rule = OutdoorSightseeingScoringRule()
    private let now = Date()

    func testIdealOutdoorSightseeingConditions() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: 24.0,
            temperatureMin: 20.0,
            precipitationSum: 0.0,
            snowfallSum: 0.0,
            windSpeedMax: 10.0,
            weatherCode: 0
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertEqual(result.activity, .outdoorSightseeing)
        XCTAssertGreaterThanOrEqual(result.score, 90)
        XCTAssertEqual(result.rating, .excellent)
        XCTAssertTrue(result.reasons.contains("Comfortable outdoor temperature (22°C)"))
        XCTAssertTrue(result.reasons.contains("Dry conditions with no rain"))
    }

    func testHeavyRainOutdoorSightseeingConditions() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: 20.0,
            temperatureMin: 16.0,
            precipitationSum: 25.0,
            snowfallSum: 0.0,
            windSpeedMax: 40.0,
            weatherCode: 65
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertEqual(result.activity, .outdoorSightseeing)
        XCTAssertLessThanOrEqual(result.score, 49)
        XCTAssertTrue(result.reasons.contains(where: { $0.contains("Heavy rain") }))
    }

    func testSevereThunderstormHazard() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: 22.0,
            temperatureMin: 18.0,
            precipitationSum: 10.0,
            snowfallSum: 0.0,
            windSpeedMax: 30.0,
            weatherCode: 96
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertEqual(result.score, 10)
        XCTAssertEqual(result.rating, .veryPoor)
    }
}
