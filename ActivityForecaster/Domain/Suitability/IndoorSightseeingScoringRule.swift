//
//  IndoorSightseeingScoringRule.swift
//  ActivityForecaster
//

import Foundation

/// Scoring rule for evaluating weather suitability for Indoor Sightseeing.
struct IndoorSightseeingScoringRule: ActivityScoringRule {
    let activity: Activity = .indoorSightseeing

    func calculateSuitability(for forecast: DailyForecast) -> SuitabilityResult {
        // Indoor activities are always a viable option (base score 50)
        var rawScore = 50

        // 1. Precipitation factor (poor outdoor weather enhances indoor appeal)
        let precip = forecast.precipitationSum
        if precip > 5.0 {
            rawScore += 35
        } else if precip > 0.0 {
            rawScore += 25
        } else {
            rawScore += 15
        }

        // 2. Temperature factor
        let temp = forecast.averageTemperature
        if temp < 10.0 || temp > 30.0 {
            rawScore += 15
        } else {
            rawScore += 10
        }

        // 3. Wind Speed factor
        let wind = forecast.windSpeedMax
        if wind > 30.0 {
            rawScore += 10
        }

        let clampedScore = max(0, min(100, rawScore))
        return SuitabilityResult(
            activity: activity,
            score: clampedScore,
            date: forecast.date
        )
    }
}
