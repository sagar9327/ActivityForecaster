//
//  GeocodingServiceTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class GeocodingServiceTests: XCTestCase {

    private final class MockHTTPClient: HTTPClientProtocol {
        var resultToReturn: Any?
        var errorToThrow: Error?
        var lastExecutedRequest: URLRequest?

        func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
            lastExecutedRequest = request
            if let error = errorToThrow {
                throw error
            }
            if let result = resultToReturn as? T {
                return result
            }
            throw NetworkError.invalidResponse
        }
    }

    func testSearchCitySuccess() async throws {
        let mockClient = MockHTTPClient()
        let item = GeocodingResponse.LocationResponse(
            id: 1,
            name: "Mumbai",
            latitude: 19.076,
            longitude: 72.8777,
            country: "India",
            admin1: "Maharashtra"
        )
        mockClient.resultToReturn = GeocodingResponse(results: [item])

        let service = OpenMeteoGeocodingService(client: mockClient)
        let locations = try await service.searchCity("Mumbai")

        XCTAssertEqual(locations.count, 1)
        XCTAssertEqual(locations.first?.name, "Mumbai")
        XCTAssertEqual(locations.first?.country, "India")
        XCTAssertEqual(locations.first?.latitude, 19.076)

        // Verify URL query construction
        let requestURL = try XCTUnwrap(mockClient.lastExecutedRequest?.url)
        XCTAssertTrue(requestURL.absoluteString.contains("name=Mumbai"))
        XCTAssertTrue(requestURL.absoluteString.contains("count=10"))
    }

    func testSearchCityEmptyQueryReturnsEmptyListWithoutNetworkCall() async throws {
        let mockClient = MockHTTPClient()
        let service = OpenMeteoGeocodingService(client: mockClient)

        let locations = try await service.searchCity("   ")

        XCTAssertTrue(locations.isEmpty)
        XCTAssertNil(mockClient.lastExecutedRequest)
    }

    func testSearchCityNetworkErrorHandling() async {
        let mockClient = MockHTTPClient()
        mockClient.errorToThrow = NetworkError.httpError(statusCode: 500)

        let service = OpenMeteoGeocodingService(client: mockClient)

        do {
            _ = try await service.searchCity("London")
            XCTFail("Expected NetworkError.httpError")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.httpError(statusCode: 500))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
