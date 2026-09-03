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

    func testPrecipitationBoundaries() {
        // precip == 0.0 => +15
        let precip0 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 0.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: precip0).score, 75) // 50 (base) + 15 (precip) + 10 (temp) = 75

        // precip == 0.1 => +25
        let precip0_1 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 0.1, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: precip0_1).score, 85) // 50 + 25 + 10 = 85

        // precip == 5.0 => +25
        let precip5 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 5.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: precip5).score, 85)

        // precip == 5.1 => +35
        let precip5_1 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 5.1, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: precip5_1).score, 95) // 50 + 35 + 10 = 95
    }

    func testTemperatureBoundaries() {
        // temp == 9.9 => +15
        let temp9_9 = DailyForecast(date: now, temperatureMax: 9.9, temperatureMin: 9.9, precipitationSum: 0.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: temp9_9).score, 80) // 50 + 15 + 15 = 80

        // temp == 10.0 => +10
        let temp10 = DailyForecast(date: now, temperatureMax: 10.0, temperatureMin: 10.0, precipitationSum: 0.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: temp10).score, 75) // 50 + 15 + 10 = 75

        // temp == 30.0 => +10
        let temp30 = DailyForecast(date: now, temperatureMax: 30.0, temperatureMin: 30.0, precipitationSum: 0.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: temp30).score, 75)

        // temp == 30.1 => +15
        let temp30_1 = DailyForecast(date: now, temperatureMax: 30.1, temperatureMin: 30.1, precipitationSum: 0.0, windSpeedMax: 10.0)
        XCTAssertEqual(rule.calculateSuitability(for: temp30_1).score, 80) // 50 + 15 + 15 = 80
    }

    func testWindSpeedBoundaries() {
        // wind == 30.0 => 0
        let wind30 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 0.0, windSpeedMax: 30.0)
        XCTAssertEqual(rule.calculateSuitability(for: wind30).score, 75) // 50 + 15 + 10 = 75

        // wind == 30.1 => +10
        let wind30_1 = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 20.0, precipitationSum: 0.0, windSpeedMax: 30.1)
        XCTAssertEqual(rule.calculateSuitability(for: wind30_1).score, 85) // 50 + 15 + 10 + 10 = 85
    }

    func testScoreNormalizationClamping() {
        let maxIndoorForecast = DailyForecast(date: now, temperatureMax: 5.0, temperatureMin: 5.0, precipitationSum: 10.0, windSpeedMax: 40.0)
        // 50 (base) + 35 (precip) + 15 (temp) + 10 (wind) = 110 -> 100
        XCTAssertEqual(rule.calculateSuitability(for: maxIndoorForecast).score, 100)
    }
}
