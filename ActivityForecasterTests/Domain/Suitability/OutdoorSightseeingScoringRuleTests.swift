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
    }

    func testSevereThunderstormHazardCap() {
        for code in [95, 96, 99] {
            let forecast = DailyForecast(
                date: now,
                temperatureMax: 22.0,
                temperatureMin: 18.0,
                precipitationSum: 0.0,
                windSpeedMax: 10.0,
                weatherCode: code
            )

            let result = rule.calculateSuitability(for: forecast)

            XCTAssertEqual(result.score, 10, "Severe weather code \(code) must cap score at 10")
            XCTAssertEqual(result.rating, .veryPoor)
        }
    }

    func testTemperatureBoundaries() {
        // temp == 4.9 => +5
        let temp4_9 = DailyForecast(date: now, temperatureMax: 4.9, temperatureMin: 4.9, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp4_9).score, 60) // 5 (temp) + 40 (precip) + 15 (wind) = 60

        // temp == 5.0 => +20
        let temp5 = DailyForecast(date: now, temperatureMax: 5.0, temperatureMin: 5.0, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp5).score, 75) // 20 + 40 + 15 = 75

        // temp == 11.9 => +20
        let temp11_9 = DailyForecast(date: now, temperatureMax: 11.9, temperatureMin: 11.9, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp11_9).score, 75)

        // temp == 12.0 => +35
        let temp12 = DailyForecast(date: now, temperatureMax: 12.0, temperatureMin: 12.0, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp12).score, 90) // 35 + 40 + 15 = 90

        // temp == 17.9 => +35
        let temp17_9 = DailyForecast(date: now, temperatureMax: 17.9, temperatureMin: 17.9, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp17_9).score, 90)

        // temp == 18.0 => +45
        let temp18 = DailyForecast(date: now, temperatureMax: 18.0, temperatureMin: 18.0, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp18).score, 100) // 45 + 40 + 15 = 100

        // temp == 26.0 => +45
        let temp26 = DailyForecast(date: now, temperatureMax: 26.0, temperatureMin: 26.0, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp26).score, 100)

        // temp == 26.1 => +35
        let temp26_1 = DailyForecast(date: now, temperatureMax: 26.1, temperatureMin: 26.1, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp26_1).score, 90)

        // temp == 30.0 => +35
        let temp30 = DailyForecast(date: now, temperatureMax: 30.0, temperatureMin: 30.0, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp30).score, 90)

        // temp == 30.1 => +20
        let temp30_1 = DailyForecast(date: now, temperatureMax: 30.1, temperatureMin: 30.1, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp30_1).score, 75)

        // temp == 35.0 => +20
        let temp35 = DailyForecast(date: now, temperatureMax: 35.0, temperatureMin: 35.0, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp35).score, 75)

        // temp == 35.1 => +5
        let temp35_1 = DailyForecast(date: now, temperatureMax: 35.1, temperatureMin: 35.1, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: temp35_1).score, 60)
    }

    func testPrecipitationBoundaries() {
        // precip == 0.0 => +40
        let precip0 = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 22.0, precipitationSum: 0.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: precip0).score, 100) // 45 + 40 + 15 = 100

        // precip == 0.1 => +25
        let precip0_1 = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 22.0, precipitationSum: 0.1, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: precip0_1).score, 85) // 45 + 25 + 15 = 85

        // precip == 2.0 => +25
        let precip2 = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 22.0, precipitationSum: 2.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: precip2).score, 85)

        // precip == 2.1 => +10
        let precip2_1 = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 22.0, precipitationSum: 2.1, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: precip2_1).score, 70) // 45 + 10 + 15 = 70

        // precip == 10.0 => +10
        let precip10 = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 22.0, precipitationSum: 10.0, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: precip10).score, 70)

        // precip == 10.1 => -20
        let precip10_1 = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 22.0, precipitationSum: 10.1, windSpeedMax: 10.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: precip10_1).score, 40) // 45 - 20 + 15 = 40
    }

    func testWindSpeedBoundaries() {
        // wind <= 20.0 => +15
        let wind20 = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 22.0, precipitationSum: 0.0, windSpeedMax: 20.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: wind20).score, 100) // 45 + 40 + 15 = 100

        // wind == 20.1 => +5
        let wind20_1 = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 22.0, precipitationSum: 0.0, windSpeedMax: 20.1, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: wind20_1).score, 90) // 45 + 40 + 5 = 90

        // wind == 35.0 => +5
        let wind35 = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 22.0, precipitationSum: 0.0, windSpeedMax: 35.0, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: wind35).score, 90)

        // wind == 35.1 => -15
        let wind35_1 = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 22.0, precipitationSum: 0.0, windSpeedMax: 35.1, weatherCode: 3)
        XCTAssertEqual(rule.calculateSuitability(for: wind35_1).score, 70) // 45 + 40 - 15 = 70
    }

    func testClearSkyBonus() {
        for code in [0, 1, 2] {
            let forecast = DailyForecast(date: now, temperatureMax: 10.0, temperatureMin: 10.0, precipitationSum: 5.0, windSpeedMax: 25.0, weatherCode: code)
            // 20 (temp) + 10 (precip) + 5 (wind) + 10 (code) = 45
            XCTAssertEqual(rule.calculateSuitability(for: forecast).score, 45)
        }
    }

    func testScoreNormalizationClamping() {
        // High score clamping to 100
        let idealForecast = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 22.0, precipitationSum: 0.0, windSpeedMax: 5.0, weatherCode: 0)
        // 45 + 40 + 15 + 10 = 110 -> 100
        XCTAssertEqual(rule.calculateSuitability(for: idealForecast).score, 100)

        // Low score clamping to 0
        let terribleForecast = DailyForecast(date: now, temperatureMax: 40.0, temperatureMin: 40.0, precipitationSum: 20.0, windSpeedMax: 50.0, weatherCode: 65)
        // 5 (temp) - 20 (precip) - 15 (wind) = -30 -> 0
        XCTAssertEqual(rule.calculateSuitability(for: terribleForecast).score, 0)
    }
}
