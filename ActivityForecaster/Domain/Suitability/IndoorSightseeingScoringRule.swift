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
        var reasons: [String] = []

        // 1. Precipitation factor (poor outdoor weather enhances indoor appeal)
        let precip = forecast.precipitationSum
        if precip > 5.0 {
            rawScore += 35
            reasons.append("Rainy weather makes indoor attractions ideal")
        } else if precip > 0.0 {
            rawScore += 25
            reasons.append("Light rain makes indoor activities well-suited")
        } else {
            rawScore += 15
            reasons.append("Good option for indoor cultural activities")
        }

        // 2. Temperature factor
        let temp = forecast.averageTemperature
        if temp < 10.0 || temp > 30.0 {
            rawScore += 15
            reasons.append("Uncomfortable outdoor temperature makes indoor sites appealing (\(Int(temp))°C)")
        } else {
            rawScore += 10
            reasons.append("Pleasant weather for visiting museums or indoor sites (\(Int(temp))°C)")
        }

        // 3. Wind Speed factor
        let wind = forecast.windSpeedMax
        if wind > 30.0 {
            rawScore += 10
            reasons.append("Windy outside, sheltered indoors (\(Int(wind)) km/h)")
        }

        let clampedScore = max(0, min(100, rawScore))
        return SuitabilityResult(
            activity: activity,
            score: clampedScore,
            reasons: reasons,
            date: forecast.date
        )
    }
}
