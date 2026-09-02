//
//  MockForecastService.swift
//  ActivityForecasterTests
//

import Foundation
@testable import ActivityForecaster

final class MockForecastService: ForecastServiceProtocol, @unchecked Sendable {
    var result: Result<Forecast, Error>?
    private(set) var requestedLocation: Location?
    private(set) var fetchCount: Int = 0
    var delayNanoseconds: UInt64 = 0

    func fetchForecast(for location: Location) async throws -> Forecast {
        fetchCount += 1
        requestedLocation = location

        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }

        try Task.checkCancellation()

        switch result {
        case .success(let forecast):
            return forecast
        case .failure(let error):
            throw error
        case .none:
            fatalError("MockForecastService result not configured before fetchForecast was called.")
        }
    }
}
