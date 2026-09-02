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
        var reasons: [String] = []

        // 1. Temperature factor
        let temp = forecast.averageTemperature
        if temp < -15.0 {
            rawScore += 40
            reasons.append("Extreme freezing cold (\(Int(temp))°C)")
        } else if temp <= 0.0 {
            rawScore += 60
            reasons.append("Ideal sub-zero temperature for snow (\(Int(temp))°C)")
        } else if temp <= 5.0 {
            rawScore += 35
            reasons.append("Near freezing, potential snow melting (\(Int(temp))°C)")
        } else {
            rawScore += 10
            reasons.append("Warm temperature melts snow (\(Int(temp))°C)")
        }

        // 2. Fresh Snowfall factor
        let snow = forecast.snowfallSum
        if snow > 15.0 {
            rawScore += 40
            reasons.append("Heavy fresh snowfall (\(String(format: "%.1f", snow)) cm)")
        } else if snow >= 5.0 {
            rawScore += 30
            reasons.append("Good fresh snowfall (\(String(format: "%.1f", snow)) cm)")
        } else if snow > 0.0 {
            rawScore += 15
            reasons.append("Light fresh snow (\(String(format: "%.1f", snow)) cm)")
        }

        // 3. Wind Speed factor
        let wind = forecast.windSpeedMax
        if wind <= 20.0 {
            rawScore += 15
            reasons.append("Calm to moderate wind (\(Int(wind)) km/h)")
        } else if wind <= 40.0 {
            rawScore += 5
            reasons.append("Moderate wind speed (\(Int(wind)) km/h)")
        } else {
            rawScore -= 20
            reasons.append("High wind speed may affect ski lifts (\(Int(wind)) km/h)")
        }

        // 4. Rain Penalty
        if temp > 0.0 && forecast.precipitationSum > 1.0 {
            rawScore -= 25
            reasons.append("Rain degrades snow quality")
        }

        // 5. Weather code snow bonus / fog penalty
        let code = forecast.weatherCode
        if [71, 73, 75, 77, 85, 86].contains(code) {
            rawScore += 10
            reasons.append("Snowy weather conditions")
        } else if [45, 48].contains(code) {
            rawScore -= 10
            reasons.append("Low visibility fog")
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
