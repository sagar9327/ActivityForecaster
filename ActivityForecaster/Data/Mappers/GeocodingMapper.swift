//
//  GeocodingMapper.swift
//  ActivityForecaster
//

import Foundation

/// Mapper responsible for transforming GeocodingResponse into domain [Location] models.
enum GeocodingMapper {
    static func map(_ response: GeocodingResponse) -> [Location] {
        guard let results = response.results else {
            return []
        }

        return results.map { item in
            Location(
                name: item.name,
                country: item.country,
                administrativeArea: item.admin1,
                latitude: item.latitude,
                longitude: item.longitude
            )
        }
    }
}
