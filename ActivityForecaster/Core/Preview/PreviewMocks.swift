//
//  PreviewMocks.swift
//  ActivityForecaster
//

#if DEBUG
import Foundation

/// Lightweight mock implementation of GeocodingServiceProtocol for SwiftUI Previews.
final class PreviewGeocodingService: GeocodingServiceProtocol {
    var locationsToReturn: [Location] = []
    var errorToThrow: Error?

    init(locationsToReturn: [Location] = [], errorToThrow: Error? = nil) {
        self.locationsToReturn = locationsToReturn
        self.errorToThrow = errorToThrow
    }

    func searchCity(_ query: String) async throws -> [Location] {
        if let error = errorToThrow {
            throw error
        }
        return locationsToReturn
    }
}

/// Lightweight mock implementation of ForecastServiceProtocol for SwiftUI Previews.
final class PreviewForecastService: ForecastServiceProtocol {
    var result: Result<Forecast, Error>

    init(result: Result<Forecast, Error>) {
        self.result = result
    }

    func fetchForecast(for location: Location) async throws -> Forecast {
        switch result {
        case .success(let forecast):
            return forecast
        case .failure(let error):
            throw error
        }
    }
}
#endif
