//
//  SurfingScoringRule.swift
//  ActivityForecaster
//

import Foundation

/// Scoring rule for evaluating weather suitability for Surfing.
struct SurfingScoringRule: ActivityScoringRule {
    let activity: Activity = .surfing

    func calculateSuitability(for forecast: DailyForecast) -> SuitabilityResult {
        var rawScore = 0

        // Thunderstorm safety check: Zero tolerance
        let code = forecast.weatherCode
        if [95, 96, 99].contains(code) {
            return SuitabilityResult(
                activity: activity,
                score: 0,
                date: forecast.date
            )
        }

        // 1. Wind speed factor
        let wind = forecast.windSpeedMax
        if wind <= 20.0 {
            rawScore += 50
        } else if wind <= 35.0 {
            rawScore += 30
        } else {
            rawScore += 10
        }

        // 2. Air Temperature factor
        let temp = forecast.averageTemperature
        if temp >= 18.0 {
            rawScore += 30
        } else if temp >= 10.0 {
            rawScore += 20
        } else {
            rawScore += 5
        }

        // 3. Precipitation factor
        let precip = forecast.precipitationSum
        if precip <= 2.0 {
            rawScore += 20
        } else if precip <= 10.0 {
            rawScore += 10
        } else {
            rawScore -= 15
        }

        let clampedScore = max(0, min(100, rawScore))
        return SuitabilityResult(
            activity: activity,
            score: clampedScore,
            date: forecast.date
        )
    }
}
