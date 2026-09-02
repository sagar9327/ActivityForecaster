//
//  GeocodingService.swift
//  ActivityForecaster
//

import Foundation

/// Protocol for searching locations via Geocoding API.
protocol GeocodingServiceProtocol: Sendable {
    func searchCity(_ query: String) async throws -> [Location]
}

/// Concrete implementation of GeocodingService using Open-Meteo Geocoding API.
final class OpenMeteoGeocodingService: GeocodingServiceProtocol {
    private let client: HTTPClientProtocol
    private let baseURLString: String

    init(
        client: HTTPClientProtocol = URLSessionHTTPClient(),
        baseURLString: String = "https://geocoding-api.open-meteo.com/v1/search"
    ) {
        self.client = client
        self.baseURLString = baseURLString
    }

    func searchCity(_ query: String) async throws -> [Location] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        guard var components = URLComponents(string: baseURLString) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "name", value: trimmedQuery),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let request = URLRequest(url: url)
        let response: GeocodingResponse = try await client.execute(request)
        return GeocodingMapper.map(response)
    }
}
