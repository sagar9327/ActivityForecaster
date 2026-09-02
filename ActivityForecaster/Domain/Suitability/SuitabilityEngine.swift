//
//  SuitabilityEngine.swift
//  ActivityForecaster
//

import Foundation

/// Core domain engine that evaluates forecast weather against registered activity scoring rules.
final class SuitabilityEngine: Sendable {
    private let rules: [ActivityScoringRule]

    init(rules: [ActivityScoringRule] = [
        SkiingScoringRule(),
        SurfingScoringRule(),
        OutdoorSightseeingScoringRule(),
        IndoorSightseeingScoringRule()
    ]) {
        self.rules = rules
    }

    /// Evaluates suitability results for all rules for a single daily forecast.
    func calculateSuitability(for dailyForecast: DailyForecast) -> [SuitabilityResult] {
        rules.map { $0.calculateSuitability(for: dailyForecast) }
    }

    /// Evaluates suitability results for a daily forecast sorted by highest score first with deterministic tie-breaking.
    func calculateRankedSuitability(for dailyForecast: DailyForecast) -> [SuitabilityResult] {
        calculateSuitability(for: dailyForecast).sorted { lhs, rhs in
            if lhs.score != rhs.score {
                return lhs.score > rhs.score
            }
            return lhs.activity.rawValue < rhs.activity.rawValue
        }
    }

    /// Evaluates multi-day suitability results mapped by forecast date.
    func calculateSuitability(for forecast: Forecast) -> [Date: [SuitabilityResult]] {
        var resultsByDate: [Date: [SuitabilityResult]] = [:]
        for daily in forecast.dailyForecasts {
            resultsByDate[daily.date] = calculateRankedSuitability(for: daily)
        }
        return resultsByDate
    }
}

