//
//  MockGeocodingService.swift
//  ActivityForecasterTests
//

import Foundation
@testable import ActivityForecaster

/// Mock implementation of GeocodingServiceProtocol for unit testing.
final class MockGeocodingService: GeocodingServiceProtocol, @unchecked Sendable {
    var locationsToReturn: [Location] = []
    var errorToThrow: Error?
    private(set) var searchCallCount = 0
    private(set) var lastQuerySearched: String?
    var delayNanoseconds: UInt64 = 0

    func searchCity(_ query: String) async throws -> [Location] {
        searchCallCount += 1
        lastQuerySearched = query

        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }

        if let error = errorToThrow {
            throw error
        }

        return locationsToReturn
    }
}
