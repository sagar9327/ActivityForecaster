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

        XCTAssertEqual(result.activity, .skiing)
        XCTAssertLessThan(result.score, 90)
    }

    func testTemperatureBoundaries() {
        // temp < -15.0 => +40
        let belowMinus15 = DailyForecast(date: now, temperatureMax: -16.0, temperatureMin: -16.0)
        XCTAssertEqual(rule.calculateSuitability(for: belowMinus15).score, 55) // 40 (temp) + 15 (wind<=20)

        // temp == -15.0 => +60
        let exactMinus15 = DailyForecast(date: now, temperatureMax: -15.0, temperatureMin: -15.0)
        XCTAssertEqual(rule.calculateSuitability(for: exactMinus15).score, 75) // 60 (temp) + 15 (wind<=20)

        // temp == 0.0 => +60
        let exactZero = DailyForecast(date: now, temperatureMax: 0.0, temperatureMin: 0.0)
        XCTAssertEqual(rule.calculateSuitability(for: exactZero).score, 75)

        // temp == 0.1 => +35
        let aboveZero = DailyForecast(date: now, temperatureMax: 0.1, temperatureMin: 0.1)
        XCTAssertEqual(rule.calculateSuitability(for: aboveZero).score, 50) // 35 (temp) + 15 (wind)

        // temp == 5.0 => +35
        let exactFive = DailyForecast(date: now, temperatureMax: 5.0, temperatureMin: 5.0)
        XCTAssertEqual(rule.calculateSuitability(for: exactFive).score, 50)

        // temp == 5.1 => +10
        let aboveFive = DailyForecast(date: now, temperatureMax: 5.1, temperatureMin: 5.1)
        XCTAssertEqual(rule.calculateSuitability(for: aboveFive).score, 25) // 10 (temp) + 15 (wind)
    }

    func testSnowfallBoundaries() {
        // snow == 0.0 => 0
        let noSnow = DailyForecast(date: now, temperatureMax: -5.0, temperatureMin: -5.0, snowfallSum: 0.0)
        XCTAssertEqual(rule.calculateSuitability(for: noSnow).score, 75) // 60 + 0 + 15

        // snow == 0.1 => 15
        let lightSnow = DailyForecast(date: now, temperatureMax: -5.0, temperatureMin: -5.0, snowfallSum: 0.1)
        XCTAssertEqual(rule.calculateSuitability(for: lightSnow).score, 90) // 60 + 15 + 15

        // snow == 5.0 => 30
        let moderateSnow = DailyForecast(date: now, temperatureMax: -5.0, temperatureMin: -5.0, snowfallSum: 5.0)
        XCTAssertEqual(rule.calculateSuitability(for: moderateSnow).score, 100) // 60 + 30 + 15 = 105 -> 100

        // snow == 15.0 => 30
        let fifteenSnow = DailyForecast(date: now, temperatureMax: 10.0, temperatureMin: 10.0, snowfallSum: 15.0)
        XCTAssertEqual(rule.calculateSuitability(for: fifteenSnow).score, 55) // 10 + 30 + 15

        // snow == 15.1 => 40
        let heavySnow = DailyForecast(date: now, temperatureMax: 10.0, temperatureMin: 10.0, snowfallSum: 15.1)
        XCTAssertEqual(rule.calculateSuitability(for: heavySnow).score, 65) // 10 + 40 + 15
    }

    func testWindSpeedBoundaries() {
        // wind <= 20.0 => +15
        let wind20 = DailyForecast(date: now, temperatureMax: 10.0, temperatureMin: 10.0, windSpeedMax: 20.0)
        XCTAssertEqual(rule.calculateSuitability(for: wind20).score, 25) // 10 + 15

        // wind == 20.1 => +5
        let wind20_1 = DailyForecast(date: now, temperatureMax: 10.0, temperatureMin: 10.0, windSpeedMax: 20.1)
        XCTAssertEqual(rule.calculateSuitability(for: wind20_1).score, 15) // 10 + 5

        // wind == 40.0 => +5
        let wind40 = DailyForecast(date: now, temperatureMax: 10.0, temperatureMin: 10.0, windSpeedMax: 40.0)
        XCTAssertEqual(rule.calculateSuitability(for: wind40).score, 15)

        // wind == 40.1 => -20
        let wind40_1 = DailyForecast(date: now, temperatureMax: 10.0, temperatureMin: 10.0, windSpeedMax: 40.1)
        XCTAssertEqual(rule.calculateSuitability(for: wind40_1).score, 0) // max(0, 10 - 20) = 0
    }

    func testRainPenaltyThresholds() {
        // temp > 0.0 && precip > 1.0 => -25
        let rainPenalized = DailyForecast(date: now, temperatureMax: 2.0, temperatureMin: 2.0, precipitationSum: 1.1)
        XCTAssertEqual(rule.calculateSuitability(for: rainPenalized).score, 25) // 35 (temp) + 15 (wind) - 25 (rain) = 25

        let noRainPenaltyLowPrecip = DailyForecast(date: now, temperatureMax: 2.0, temperatureMin: 2.0, precipitationSum: 1.0)
        XCTAssertEqual(rule.calculateSuitability(for: noRainPenaltyLowPrecip).score, 50) // 35 + 15

        let noRainPenaltyColdTemp = DailyForecast(date: now, temperatureMax: 0.0, temperatureMin: 0.0, precipitationSum: 5.0)
        XCTAssertEqual(rule.calculateSuitability(for: noRainPenaltyColdTemp).score, 75) // 60 + 15
    }

    func testScoreNormalizationClampingLowerAndUpperBounds() {
        // Over 100 clamped to 100
        let superGoodForecast = DailyForecast(
            date: now,
            temperatureMax: -5.0,
            temperatureMin: -10.0,
            precipitationSum: 0.0,
            snowfallSum: 20.0,
            windSpeedMax: 5.0,
            weatherCode: 75
        ) // 60 + 40 + 15 + 10 = 125 -> 100

        let resultUpper = rule.calculateSuitability(for: superGoodForecast)
        XCTAssertEqual(resultUpper.score, 100)

        // Below 0 clamped to 0
        let superTerribleForecast = DailyForecast(
            date: now,
            temperatureMax: 15.0,
            temperatureMin: 10.0,
            precipitationSum: 20.0,
            snowfallSum: 0.0,
            windSpeedMax: 50.0,
            weatherCode: 45
        ) // 10 + 0 - 20 - 25 - 10 = -45 -> 0

        let resultLower = rule.calculateSuitability(for: superTerribleForecast)
        XCTAssertEqual(resultLower.score, 0)
    }
}
