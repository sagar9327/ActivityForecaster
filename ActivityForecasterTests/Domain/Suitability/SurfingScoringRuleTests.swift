//
//  SurfingScoringRuleTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class SurfingScoringRuleTests: XCTestCase {

    private let rule = SurfingScoringRule()
    private let now = Date()

    func testFavorableSurfingConditions() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: 26.0,
            temperatureMin: 20.0,
            precipitationSum: 0.0,
            snowfallSum: 0.0,
            windSpeedMax: 12.0,
            weatherCode: 1
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertEqual(result.activity, .surfing)
        XCTAssertGreaterThanOrEqual(result.score, 90)
        XCTAssertEqual(result.rating, .excellent)
        XCTAssertTrue(result.reasons.contains(where: { $0.contains("wave, swell, and tide") }))
    }

    func testThunderstormSafetyHazard() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: 25.0,
            temperatureMin: 22.0,
            precipitationSum: 15.0,
            snowfallSum: 0.0,
            windSpeedMax: 20.0,
            weatherCode: 95
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertEqual(result.activity, .surfing)
        XCTAssertEqual(result.score, 0)
        XCTAssertEqual(result.rating, .veryPoor)
        XCTAssertTrue(result.reasons.contains(where: { $0.contains("Thunderstorm hazard") }))
    }

    func testChoppyWindConditions() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: 22.0,
            temperatureMin: 18.0,
            precipitationSum: 0.0,
            snowfallSum: 0.0,
            windSpeedMax: 45.0
        )

        let result = rule.calculateSuitability(for: forecast)

        XCTAssertTrue(result.reasons.contains(where: { $0.contains("Strong wind causes choppy water") }))
    }
}
