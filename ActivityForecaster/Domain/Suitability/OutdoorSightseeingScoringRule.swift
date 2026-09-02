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
        var reasons: [String] = []

        // Severe weather cap
        let code = forecast.weatherCode
        if [95, 96, 99].contains(code) {
            return SuitabilityResult(
                activity: activity,
                score: 10,
                reasons: ["Thunderstorm hazard — poor for outdoor sightseeing"],
                date: forecast.date
            )
        }

        // 1. Temperature factor
        let temp = forecast.averageTemperature
        if temp >= 18.0 && temp <= 26.0 {
            rawScore += 45
            reasons.append("Comfortable outdoor temperature (\(Int(temp))°C)")
        } else if (temp >= 12.0 && temp < 18.0) || (temp > 26.0 && temp <= 30.0) {
            rawScore += 35
            reasons.append("Moderate temperature (\(Int(temp))°C)")
        } else if (temp >= 5.0 && temp < 12.0) || (temp > 30.0 && temp <= 35.0) {
            rawScore += 20
            reasons.append("Cool or warm temperature (\(Int(temp))°C)")
        } else {
            rawScore += 5
            reasons.append("Extreme temperature for outdoors (\(Int(temp))°C)")
        }

        // 2. Precipitation factor
        let precip = forecast.precipitationSum
        if precip == 0.0 {
            rawScore += 40
            reasons.append("Dry conditions with no rain")
        } else if precip <= 2.0 {
            rawScore += 25
            reasons.append("Light rain")
        } else if precip <= 10.0 {
            rawScore += 10
            reasons.append("Moderate rain")
        } else {
            rawScore -= 20
            reasons.append("Heavy rain discourages outdoor walking")
        }

        // 3. Wind speed factor
        let wind = forecast.windSpeedMax
        if wind <= 20.0 {
            rawScore += 15
            reasons.append("Light wind (\(Int(wind)) km/h)")
        } else if wind <= 35.0 {
            rawScore += 5
            reasons.append("Moderate wind (\(Int(wind)) km/h)")
        } else {
            rawScore -= 15
            reasons.append("Strong wind (\(Int(wind)) km/h)")
        }

        // 4. Weather code clear sky bonus
        if [0, 1, 2].contains(code) {
            rawScore += 10
            reasons.append("Clear or mostly sunny skies")
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
