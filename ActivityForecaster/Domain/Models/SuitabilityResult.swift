//
//  SuitabilityResult.swift
//  ActivityForecaster
//

import Foundation

/// Represents the calculated suitability score, rating, and explanatory reasons for an activity.
struct SuitabilityResult: Equatable, Hashable, Sendable, Identifiable {
    var id: String { "\(activity.rawValue)_\(date?.timeIntervalSince1970 ?? 0.0)" }

    let activity: Activity
    let score: Int          // Clamped 0...100
    let rating: Rating
    let reasons: [String]
    let date: Date?

    init(
        activity: Activity,
        score: Int,
        reasons: [String] = [],
        date: Date? = nil
    ) {
        let clampedScore = max(0, min(100, score))
        self.activity = activity
        self.score = clampedScore
        self.rating = Rating.from(score: clampedScore)
        self.reasons = reasons
        self.date = date
    }
}
