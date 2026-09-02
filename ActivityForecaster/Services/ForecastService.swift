//
//  ForecastService.swift
//  ActivityForecaster
//

import Foundation

/// Protocol for fetching weather forecasts.
protocol ForecastServiceProtocol: Sendable {
    func fetchForecast(for location: Location) async throws -> Forecast
}

/// Concrete implementation of ForecastService using Open-Meteo Forecast API.
final class OpenMeteoForecastService: ForecastServiceProtocol {
    private let client: HTTPClientProtocol
    private let baseURLString: String

    init(
        client: HTTPClientProtocol = URLSessionHTTPClient(),
        baseURLString: String = "https://api.open-meteo.com/v1/forecast"
    ) {
        self.client = client
        self.baseURLString = baseURLString
    }

    func fetchForecast(for location: Location) async throws -> Forecast {
        guard var components = URLComponents(string: baseURLString) else {
            throw NetworkError.invalidURL
        }

        let dailyVariables = [
            "weather_code",
            "temperature_2m_max",
            "temperature_2m_min",
            "precipitation_sum",
            "snowfall_sum",
            "wind_speed_10m_max"
        ].joined(separator: ",")

        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "daily", value: dailyVariables),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let request = URLRequest(url: url)
        let response: ForecastResponse = try await client.execute(request)
        return try ForecastMapper.map(response, for: location)
    }
}
