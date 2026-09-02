//
//  OutdoorSightseeingScoringRule.swift
//  ActivityForecaster
//

import Foundation

/// Scoring rule for evaluating weather suitability for Outdoor Sightseeing.
struct OutdoorSightseeingScoringRule: ActivityScoringRule {
    let activity: Activity = .outdoorSightseeing

    func calculateSuitability(for forecast: DailyForecast) -> SuitabilityResult {
        var rawScore = 0

        // Severe weather cap
        let code = forecast.weatherCode
        if [95, 96, 99].contains(code) {
            return SuitabilityResult(
                activity: activity,
                score: 10,
                date: forecast.date
            )
        }

        // 1. Temperature factor
        let temp = forecast.averageTemperature
        if temp >= 18.0 && temp <= 26.0 {
            rawScore += 45
        } else if (temp >= 12.0 && temp < 18.0) || (temp > 26.0 && temp <= 30.0) {
            rawScore += 35
        } else if (temp >= 5.0 && temp < 12.0) || (temp > 30.0 && temp <= 35.0) {
            rawScore += 20
        } else {
            rawScore += 5
        }

        // 2. Precipitation factor
        let precip = forecast.precipitationSum
        if precip == 0.0 {
            rawScore += 40
        } else if precip <= 2.0 {
            rawScore += 25
        } else if precip <= 10.0 {
            rawScore += 10
        } else {
            rawScore -= 20
        }

        // 3. Wind speed factor
        let wind = forecast.windSpeedMax
        if wind <= 20.0 {
            rawScore += 15
        } else if wind <= 35.0 {
            rawScore += 5
        } else {
            rawScore -= 15
        }

        // 4. Weather code clear sky bonus
        if [0, 1, 2].contains(code) {
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
