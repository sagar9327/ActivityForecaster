//
//  SkiingScoringRuleTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class SkiingScoringRuleTests: XCTestCase {

    private let rule = SkiingScoringRule()
    private let now = Date()

    func testExcellentSkiingConditions() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: -2.0,
            temperatureMin: -8.0,
            precipitationSum: 0.0,
            snowfallSum: 20.0,
            windSpeedMax: 10.0,
            weatherCode: 73
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertEqual(result.activity, .skiing)
        XCTAssertGreaterThanOrEqual(result.score, 90)
        XCTAssertEqual(result.rating, .excellent)
        XCTAssertFalse(result.reasons.isEmpty)
    }

    func testPoorWarmRainySkiingConditions() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: 12.0,
            temperatureMin: 6.0,
            precipitationSum: 15.0,
            snowfallSum: 0.0,
            windSpeedMax: 45.0,
            weatherCode: 63
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertEqual(result.activity, .skiing)
        XCTAssertLessThanOrEqual(result.score, 24)
        XCTAssertEqual(result.rating, .veryPoor)
    }

    func testHighWindPenalty() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: -5.0,
            temperatureMin: -10.0,
            precipitationSum: 0.0,
            snowfallSum: 5.0,
            windSpeedMax: 55.0
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertTrue(result.reasons.contains(where: { $0.contains("High wind speed") }))
    }

    func testScoreNormalizationClamping() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: -5.0,
            temperatureMin: -10.0,
            precipitationSum: 0.0,
            snowfallSum: 100.0,
            windSpeedMax: 5.0,
            weatherCode: 75
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertLessThanOrEqual(result.score, 100)
        XCTAssertGreaterThanOrEqual(result.score, 0)
    }
}
