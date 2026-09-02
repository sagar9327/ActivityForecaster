//
//  Location.swift
//  ActivityForecaster
//

import Foundation

/// Domain model representing a selected city or town.
struct Location: Equatable, Hashable, Sendable {
    let name: String
    let country: String?
    let administrativeArea: String?
    let latitude: Double
    let longitude: Double

    init(
        name: String,
        country: String? = nil,
        administrativeArea: String? = nil,
        latitude: Double,
        longitude: Double
    ) {
        self.name = name
        self.country = country
        self.administrativeArea = administrativeArea
        self.latitude = latitude
        self.longitude = longitude
    }
}
