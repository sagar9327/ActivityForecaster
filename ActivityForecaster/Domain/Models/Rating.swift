//
//  Rating.swift
//  ActivityForecaster
//

import Foundation

/// Suitability rating classification based on normalized 0...100 score.
enum Rating: String, Equatable, Hashable, Sendable, Comparable {
    case veryPoor = "Very Poor"
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case excellent = "Excellent"

    /// Maps a 0...100 numerical score into the standard suitability rating.
    static func from(score: Int) -> Rating {
        let clampedScore = max(0, min(100, score))
        switch clampedScore {
        case 90...100:
            return .excellent
        case 75...89:
            return .good
        case 50...74:
            return .fair
        case 25...49:
            return .poor
        default:
            return .veryPoor
        }
    }

    private var sortOrder: Int {
        switch self {
        case .veryPoor: return 0
        case .poor: return 1
        case .fair: return 2
        case .good: return 3
        case .excellent: return 4
        }
    }

    static func < (lhs: Rating, rhs: Rating) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension Rating {
    /// Semantic UI badge background color for rating classification.
    var color: Color {
        switch self {
        case .excellent:
            return .green
        case .good:
            return .blue
        case .fair:
            return .orange
        case .poor:
            return .purple
        case .veryPoor:
            return .red
        }
    }
}
#endif
