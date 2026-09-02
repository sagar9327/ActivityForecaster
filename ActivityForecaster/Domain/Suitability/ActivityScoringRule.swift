//
//  ActivityScoringRule.swift
//  ActivityForecaster
//

import Foundation

/// Protocol defining the scoring abstraction for activity-specific suitability calculation.
protocol ActivityScoringRule: Sendable {
    var activity: Activity { get }
    func calculateSuitability(for forecast: DailyForecast) -> SuitabilityResult
}
