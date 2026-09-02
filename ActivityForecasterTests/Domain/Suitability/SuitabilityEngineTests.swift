//
//  SuitabilityEngineTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class SuitabilityEngineTests: XCTestCase {

    private let engine = SuitabilityEngine()
    private let now = Date()

    func testCalculateSuitabilityForSingleDay() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: 24.0,
            temperatureMin: 18.0,
            precipitationSum: 0.0,
            snowfallSum: 0.0,
            windSpeedMax: 10.0,
            weatherCode: 0
        )

        let results = engine.calculateSuitability(for: forecast)

        XCTAssertEqual(results.count, 4)
        XCTAssertTrue(results.contains(where: { $0.activity == .skiing }))
        XCTAssertTrue(results.contains(where: { $0.activity == .surfing }))
        XCTAssertTrue(results.contains(where: { $0.activity == .outdoorSightseeing }))
        XCTAssertTrue(results.contains(where: { $0.activity == .indoorSightseeing }))
    }

    func testRankedSuitabilitySorting() {
        let forecast = DailyForecast(
            date: now,
            temperatureMax: 24.0,
            temperatureMin: 20.0,
            precipitationSum: 0.0,
            snowfallSum: 0.0,
            windSpeedMax: 10.0,
            weatherCode: 0
        )

        let ranked = engine.calculateRankedSuitability(for: forecast)

        XCTAssertEqual(ranked.count, 4)
        for i in 0..<(ranked.count - 1) {
            XCTAssertGreaterThanOrEqual(ranked[i].score, ranked[i + 1].score, "Results should be sorted descending by score")
        }
    }

    func testMultiDayForecastSuitability() {
        let location = Location(name: "London", latitude: 51.5074, longitude: -0.1278)
        let day1 = DailyForecast(date: now, temperatureMax: 22.0, temperatureMin: 18.0)
        let day2 = DailyForecast(date: now.addingTimeInterval(86400), temperatureMax: -5.0, temperatureMin: -10.0, snowfallSum: 15.0)

        let forecast = Forecast(location: location, dailyForecasts: [day1, day2])
        let multiDayResults = engine.calculateSuitability(for: forecast)

        XCTAssertEqual(multiDayResults.keys.count, 2)
        XCTAssertEqual(multiDayResults[day1.date]?.count, 4)
        XCTAssertEqual(multiDayResults[day2.date]?.count, 4)
    }

    // Extensibility Test: Adding a new activity without changing engine core
    func testExtensibilityWithCustomScoringRule() {
        struct CyclingScoringRule: ActivityScoringRule {
            let activity: Activity = .outdoorSightseeing // custom rule
            func calculateSuitability(for forecast: DailyForecast) -> SuitabilityResult {
                SuitabilityResult(activity: activity, score: 85, reasons: ["Great cycling weather"])
            }
        }

        let customEngine = SuitabilityEngine(rules: [CyclingScoringRule()])
        let forecast = DailyForecast(date: now, temperatureMax: 20.0, temperatureMin: 15.0)

        let results = customEngine.calculateSuitability(for: forecast)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.score, 85)
        XCTAssertEqual(results.first?.reasons, ["Great cycling weather"])
    }
}
