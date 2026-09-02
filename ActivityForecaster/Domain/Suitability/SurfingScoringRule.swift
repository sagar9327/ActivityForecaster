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
        var reasons: [String] = []

        // Thunderstorm safety check: Zero tolerance
        let code = forecast.weatherCode
        if [95, 96, 99].contains(code) {
            return SuitabilityResult(
                activity: activity,
                score: 0,
                reasons: ["Thunderstorm hazard — unsafe for water activities", "Weather forecast score; surf quality also depends on wave, swell, and tide conditions."],
                date: forecast.date
            )
        }

        // 1. Wind speed factor
        let wind = forecast.windSpeedMax
        if wind <= 20.0 {
            rawScore += 50
            reasons.append("Favorable light wind speed (\(Int(wind)) km/h)")
        } else if wind <= 35.0 {
            rawScore += 30
            reasons.append("Moderate wind (\(Int(wind)) km/h)")
        } else {
            rawScore += 10
            reasons.append("Strong wind causes choppy water (\(Int(wind)) km/h)")
        }

        // 2. Air Temperature factor
        let temp = forecast.averageTemperature
        if temp >= 18.0 {
            rawScore += 30
            reasons.append("Warm air temperature (\(Int(temp))°C)")
        } else if temp >= 10.0 {
            rawScore += 20
            reasons.append("Mild air temperature (\(Int(temp))°C)")
        } else {
            rawScore += 5
            reasons.append("Cold air temperature (\(Int(temp))°C)")
        }

        // 3. Precipitation factor
        let precip = forecast.precipitationSum
        if precip <= 2.0 {
            rawScore += 20
            reasons.append("Minimal precipitation")
        } else if precip <= 10.0 {
            rawScore += 10
            reasons.append("Light to moderate rain")
        } else {
            rawScore -= 15
            reasons.append("Heavy rain reduces visibility")
        }

        // Always append marine condition disclaimer note
        reasons.append("Weather forecast score; surf quality also depends on wave, swell, and tide conditions.")

        let clampedScore = max(0, min(100, rawScore))
        return SuitabilityResult(
            activity: activity,
            score: clampedScore,
            reasons: reasons,
            date: forecast.date
        )
    }
}
