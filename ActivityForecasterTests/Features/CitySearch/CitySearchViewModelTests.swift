//
//  CitySearchViewModelTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

@MainActor
final class CitySearchViewModelTests: XCTestCase {

    private let sampleLondon = Location(
        name: "London",
        country: "United Kingdom",
        administrativeArea: "England",
        latitude: 51.5074,
        longitude: -0.1278
    )

    private let sampleParis = Location(
        name: "Paris",
        country: "France",
        administrativeArea: "Île-de-France",
        latitude: 48.8566,
        longitude: 2.3522
    )

    func testSuccessfulSearchPopulatesResults() async throws {
        let mockService = MockGeocodingService()
        mockService.locationsToReturn = [sampleLondon]
        let viewModel = CitySearchViewModel(geocodingService: mockService, debounceNanoseconds: 0)

        viewModel.searchQuery = "London"
        await viewModel.searchTask?.value

        XCTAssertEqual(viewModel.state, .results([sampleLondon]))
        XCTAssertEqual(mockService.searchCallCount, 1)
        XCTAssertEqual(mockService.lastQuerySearched, "London")
    }

    func testEmptyServiceResultSetsEmptyState() async throws {
        let mockService = MockGeocodingService()
        mockService.locationsToReturn = []
        let viewModel = CitySearchViewModel(geocodingService: mockService, debounceNanoseconds: 0)

        viewModel.searchQuery = "SomeUnknownCity"
        await viewModel.searchTask?.value

        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertEqual(mockService.searchCallCount, 1)
    }

    func testServiceErrorExposesErrorState() async throws {
        let mockService = MockGeocodingService()
        mockService.errorToThrow = NetworkError.httpError(statusCode: 500)
        let viewModel = CitySearchViewModel(geocodingService: mockService, debounceNanoseconds: 0)

        viewModel.searchQuery = "Berlin"
        await viewModel.searchTask?.value

        if case .error(let message) = viewModel.state {
            XCTAssertTrue(message.contains("500"))
        } else {
            XCTFail("Expected error state, got \(viewModel.state)")
        }
    }

    func testEmptyOrWhitespaceQueryResetsStateToIdleWithoutNetworkCall() async throws {
        let mockService = MockGeocodingService()
        let viewModel = CitySearchViewModel(geocodingService: mockService, debounceNanoseconds: 0)

        viewModel.searchQuery = "   "
        await viewModel.searchTask?.value

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(mockService.searchCallCount, 0)
    }

    func testDebounceIgnoresIntermediateKeystrokes() async throws {
        let mockService = MockGeocodingService()
        mockService.locationsToReturn = [sampleLondon]
        let viewModel = CitySearchViewModel(geocodingService: mockService, debounceNanoseconds: 10_000_000) // 10ms

        viewModel.searchQuery = "L"
        viewModel.searchQuery = "Lo"
        viewModel.searchQuery = "Lon"
        viewModel.searchQuery = "London"

        await viewModel.searchTask?.value

        XCTAssertEqual(mockService.searchCallCount, 1)
        XCTAssertEqual(mockService.lastQuerySearched, "London")
        XCTAssertEqual(viewModel.state, .results([sampleLondon]))
    }

    func testCancellationWhenNewQueryArrives() async throws {
        let mockService = MockGeocodingService()
        mockService.delayNanoseconds = 50_000_000 // 50ms delay
        mockService.locationsToReturn = [sampleLondon]
        let viewModel = CitySearchViewModel(geocodingService: mockService, debounceNanoseconds: 0)

        viewModel.searchQuery = "London"
        
        // Immediately trigger new search
        mockService.locationsToReturn = [sampleParis]
        viewModel.searchQuery = "Paris"

        await viewModel.searchTask?.value

        XCTAssertEqual(mockService.lastQuerySearched, "Paris")
        XCTAssertEqual(viewModel.state, .results([sampleParis]))
    }

    func testLocationSelectionRetainsLocationWithoutForecastCall() async throws {
        let mockService = MockGeocodingService()
        mockService.locationsToReturn = [sampleLondon, sampleParis]
        let viewModel = CitySearchViewModel(geocodingService: mockService, debounceNanoseconds: 0)

        viewModel.searchQuery = "Capitals"
        await viewModel.searchTask?.value

        viewModel.selectLocation(sampleParis)

        XCTAssertEqual(viewModel.selectedLocation, sampleParis)
    }

    func testClearSearchResetsQueryAndState() async throws {
        let mockService = MockGeocodingService()
        mockService.locationsToReturn = [sampleLondon]
        let viewModel = CitySearchViewModel(geocodingService: mockService, debounceNanoseconds: 0)

        viewModel.searchQuery = "London"
        await viewModel.searchTask?.value

        viewModel.clearSearch()

        XCTAssertEqual(viewModel.searchQuery, "")
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testLocationSubtitleFormatting() {
        let mockService = MockGeocodingService()
        let viewModel = CitySearchViewModel(geocodingService: mockService, debounceNanoseconds: 0)

        let locFull = Location(name: "City", country: "Country", administrativeArea: "Admin", latitude: 0, longitude: 0)
        XCTAssertEqual(viewModel.locationSubtitle(for: locFull), "Admin, Country")

        let locCountryOnly = Location(name: "City", country: "Country", administrativeArea: nil, latitude: 0, longitude: 0)
        XCTAssertEqual(viewModel.locationSubtitle(for: locCountryOnly), "Country")

        let locNone = Location(name: "City", country: nil, administrativeArea: nil, latitude: 0, longitude: 0)
        XCTAssertNil(viewModel.locationSubtitle(for: locNone))
    }
}
