//
//  GeocodingResponse.swift
//  ActivityForecaster
//

import Foundation

/// Decodable representation of Open-Meteo Geocoding API response.
struct GeocodingResponse: Decodable, Sendable {
    struct LocationResponse: Decodable, Sendable {
        let id: Int?
        let name: String
        let latitude: Double
        let longitude: Double
        let country: String?
        let admin1: String?

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case latitude
            case longitude
            case country
            case admin1
        }
    }

    let results: [LocationResponse]?
}
