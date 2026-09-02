//
//  Activity.swift
//  ActivityForecaster
//

import Foundation

/// Extensible representation of supported outdoor/indoor activities.
enum Activity: String, CaseIterable, Identifiable, Equatable, Hashable, Sendable {
    case skiing
    case surfing
    case outdoorSightseeing
    case indoorSightseeing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .skiing:
            return "Skiing"
        case .surfing:
            return "Surfing"
        case .outdoorSightseeing:
            return "Outdoor Sightseeing"
        case .indoorSightseeing:
            return "Indoor Sightseeing"
        }
    }
}
