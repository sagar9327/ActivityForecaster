//
//  SkiingScoringRule.swift
//  ActivityForecaster
//

import Foundation

/// Scoring rule for evaluating weather suitability for Skiing.
struct SkiingScoringRule: ActivityScoringRule {
    let activity: Activity = .skiing

    func calculateSuitability(for forecast: DailyForecast) -> SuitabilityResult {
        var rawScore = 0

        // 1. Temperature factor
        let temp = forecast.averageTemperature
        if temp < -15.0 {
            rawScore += 40
        } else if temp <= 0.0 {
            rawScore += 60
        } else if temp <= 5.0 {
            rawScore += 35
        } else {
            rawScore += 10
        }

        // 2. Fresh Snowfall factor
        let snow = forecast.snowfallSum
        if snow > 15.0 {
            rawScore += 40
        } else if snow >= 5.0 {
            rawScore += 30
        } else if snow > 0.0 {
            rawScore += 15
        }

        // 3. Wind Speed factor
        let wind = forecast.windSpeedMax
        if wind <= 20.0 {
            rawScore += 15
        } else if wind <= 40.0 {
            rawScore += 5
        } else {
            rawScore -= 20
        }

        // 4. Rain Penalty
        if temp > 0.0 && forecast.precipitationSum > 1.0 {
            rawScore -= 25
        }

        // 5. Weather code snow bonus / fog penalty
        let code = forecast.weatherCode
        if [71, 73, 75, 77, 85, 86].contains(code) {
            rawScore += 10
        } else if [45, 48].contains(code) {
            rawScore -= 10
        }

        let clampedScore = max(0, min(100, rawScore))
        return SuitabilityResult(
            activity: activity,
            score: clampedScore,
            date: forecast.date
        )
    }
}
