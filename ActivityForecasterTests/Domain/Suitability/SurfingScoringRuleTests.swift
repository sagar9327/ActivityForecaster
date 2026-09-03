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
    }

    func testThunderstormSafetyHazardCodes() {
        for code in [95, 96, 99] {
            let forecast = DailyForecast(
                date: now,
                temperatureMax: 25.0,
                temperatureMin: 22.0,
                precipitationSum: 0.0,
                windSpeedMax: 10.0,
                weatherCode: code
            )

            let result = rule.calculateSuitability(for: forecast)

            XCTAssertEqual(result.activity, .surfing)
            XCTAssertEqual(result.score, 0, "Thunderstorm code \(code) must return score 0")
            XCTAssertEqual(result.rating, .veryPoor)
        }

        // Non-thunderstorm weather code 94 should evaluate normally
        let code94Forecast = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, weatherCode: 94)
        XCTAssertGreaterThan(rule.calculateSuitability(for: code94Forecast).score, 0)
    }

    func testWindSpeedBoundaries() {
        // wind <= 20.0 => +50
        let wind20 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 0.0, windSpeedMax: 20.0)
        XCTAssertEqual(rule.calculateSuitability(for: wind20).score, 100) // 50 (wind) + 30 (temp) + 20 (precip) = 100

        // wind == 20.1 => +30
        let wind20_1 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 0.0, windSpeedMax: 20.1)
        XCTAssertEqual(rule.calculateSuitability(for: wind20_1).score, 80) // 30 + 30 + 20 = 80

        // wind == 35.0 => +30
        let wind35 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 0.0, windSpeedMax: 35.0)
        XCTAssertEqual(rule.calculateSuitability(for: wind35).score, 80)

        // wind == 35.1 => +10
        let wind35_1 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 0.0, windSpeedMax: 35.1)
        XCTAssertEqual(rule.calculateSuitability(for: wind35_1).score, 60) // 10 + 30 + 20 = 60
    }

    func testAirTemperatureBoundaries() {
        // temp >= 18.0 => +30
        let temp18 = DailyForecast(date: now, temperatureMax: 18.0, temperatureMin: 18.0, precipitationSum: 0.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: temp18).score, 100) // 50 + 30 + 20

        // temp == 17.9 => +20
        let temp17_9 = DailyForecast(date: now, temperatureMax: 17.9, temperatureMin: 17.9, precipitationSum: 0.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: temp17_9).score, 90) // 50 + 20 + 20

        // temp == 10.0 => +20
        let temp10 = DailyForecast(date: now, temperatureMax: 10.0, temperatureMin: 10.0, precipitationSum: 0.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: temp10).score, 90)

        // temp == 9.9 => +5
        let temp9_9 = DailyForecast(date: now, temperatureMax: 9.9, temperatureMin: 9.9, precipitationSum: 0.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: temp9_9).score, 75) // 50 + 5 + 20
    }

    func testPrecipitationBoundaries() {
        // precip <= 2.0 => +20
        let precip2 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 2.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: precip2).score, 100) // 50 + 30 + 20

        // precip == 2.1 => +10
        let precip2_1 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 2.1, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: precip2_1).score, 90) // 50 + 30 + 10

        // precip == 10.0 => +10
        let precip10 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 10.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: precip10).score, 90)

        // precip == 10.1 => -15
        let precip10_1 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 10.1, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: precip10_1).score, 65) // 50 + 30 - 15 = 65
    }

    func testScoreNormalizationClamping() {
        // High score maxing out factors
        let perfectSurfing = DailyForecast(date: now, temperatureMax: 25.0, temperatureMin: 25.0, precipitationSum: 0.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: perfectSurfing).score, 100)

        // Low score with heavy rain & wind penalty
        let terribleSurfing = DailyForecast(date: now, temperatureMax: 5.0, temperatureMin: 5.0, precipitationSum: 20.0, windSpeedMax: 50.0)
        // 10 (wind) + 5 (temp) - 15 (precip) = 0 -> clamped to 0
        XCTAssertEqual(rule.calculateSuitability(for: terribleSurfing).score, 0)
    }
}
