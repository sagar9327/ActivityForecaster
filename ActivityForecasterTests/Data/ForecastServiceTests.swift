//
//  ForecastServiceTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class ForecastServiceTests: XCTestCase {

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

    private let sampleLocation = Location(
        name: "Berlin",
        country: "Germany",
        administrativeArea: "Berlin",
        latitude: 52.52,
        longitude: 13.405
    )

    func testFetchForecastSuccess() async throws {
        let mockClient = MockHTTPClient()
        let daily = ForecastResponse.DailyResponse(
            time: ["2026-09-02"],
            weatherCode: [0],
            temperature2mMax: [25.0],
            temperature2mMin: [15.0],
            precipitationSum: [0.0],
            snowfallSum: [0.0],
            windSpeed10mMax: [10.0]
        )
        mockClient.resultToReturn = ForecastResponse(
            latitude: 52.52,
            longitude: 13.405,
            timezone: "Europe/Berlin",
            dailyUnits: nil,
            daily: daily
        )

        let service = OpenMeteoForecastService(client: mockClient)
        let forecast = try await service.fetchForecast(for: sampleLocation)

        XCTAssertEqual(forecast.location, sampleLocation)
        XCTAssertEqual(forecast.dailyForecasts.count, 1)

        let day = forecast.dailyForecasts[0]
        XCTAssertEqual(day.temperatureMax, 25.0)
        XCTAssertEqual(day.temperatureMin, 15.0)

        // Verify URL query construction
        let url = try XCTUnwrap(mockClient.lastExecutedRequest?.url)
        XCTAssertTrue(url.absoluteString.contains("latitude=52.52"))
        XCTAssertTrue(url.absoluteString.contains("longitude=13.405"))
        XCTAssertTrue(url.absoluteString.contains("daily=weather_code"))
    }

    func testFetchForecastMappingErrorPropagation() async {
        let mockClient = MockHTTPClient()
        // Invalid forecast response missing daily array
        mockClient.resultToReturn = ForecastResponse(
            latitude: 52.52,
            longitude: 13.405,
            timezone: "Europe/Berlin",
            dailyUnits: nil,
            daily: nil
        )

        let service = OpenMeteoForecastService(client: mockClient)

        do {
            _ = try await service.fetchForecast(for: sampleLocation)
            XCTFail("Expected mapping error")
        } catch let error as NetworkError {
            guard case .mappingError = error else {
                XCTFail("Expected NetworkError.mappingError, got \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
