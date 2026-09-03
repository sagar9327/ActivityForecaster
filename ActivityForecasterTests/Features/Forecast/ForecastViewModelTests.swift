//
//  ForecastViewModelTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

@MainActor
final class ForecastViewModelTests: XCTestCase {

    private var mockService: MockForecastService!
    private var suitabilityEngine: SuitabilityEngine!
    private let testLocation = Location(
        name: "Tokyo",
        country: "Japan",
        administrativeArea: "Tokyo",
        latitude: 35.6762,
        longitude: 139.6503
    )

    override func setUp() {
        super.setUp()
        mockService = MockForecastService()
        suitabilityEngine = SuitabilityEngine()
    }

    override func tearDown() {
        mockService = nil
        suitabilityEngine = nil
        super.tearDown()
    }

    // A. Successful forecast loading
    func testSuccessfulForecastLoading() async {
        let forecast = makeSampleForecast(for: testLocation)
        mockService.result = .success(forecast)

        let viewModel = ForecastViewModel(
            location: testLocation,
            forecastService: mockService,
            suitabilityEngine: suitabilityEngine
        )
        trackForMemoryLeaks(viewModel)

        XCTAssertEqual(viewModel.state, .idle)

        viewModel.loadForecast()
        XCTAssertEqual(viewModel.state, .loading)

        await viewModel.fetchTask?.value

        if case .success(let data) = viewModel.state {
            XCTAssertEqual(data.location, testLocation)
            XCTAssertEqual(data.dailySuitabilities.count, 1)
            XCTAssertEqual(data.dailySuitabilities.first?.rankedResults.count, 4)
        } else {
            XCTFail("Expected .success state, got \(viewModel.state)")
        }
    }

    // B. Forecast service failure
    func testForecastServiceFailureExposesErrorState() async {
        mockService.result = .failure(NetworkError.httpError(statusCode: 500))

        let viewModel = ForecastViewModel(
            location: testLocation,
            forecastService: mockService,
            suitabilityEngine: suitabilityEngine
        )

        viewModel.loadForecast()
        XCTAssertEqual(viewModel.state, .loading)

        await viewModel.fetchTask?.value

        if case .error(let message) = viewModel.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected .error state, got \(viewModel.state)")
        }
    }

    // C. Suitability integration (all four activities evaluated)
    func testSuitabilityIntegrationEvaluatesAllFourActivities() async {
        let forecast = makeSampleForecast(for: testLocation)
        mockService.result = .success(forecast)

        let viewModel = ForecastViewModel(
            location: testLocation,
            forecastService: mockService,
            suitabilityEngine: suitabilityEngine
        )

        viewModel.loadForecast()
        await viewModel.fetchTask?.value

        guard case .success(let data) = viewModel.state,
              let daily = data.dailySuitabilities.first else {
            XCTFail("Expected .success state with daily suitability")
            return
        }

        let evaluatedActivities = Set(daily.rankedResults.map { $0.activity })
        XCTAssertEqual(evaluatedActivities.count, 4)
        XCTAssertTrue(evaluatedActivities.contains(.skiing))
        XCTAssertTrue(evaluatedActivities.contains(.surfing))
        XCTAssertTrue(evaluatedActivities.contains(.outdoorSightseeing))
        XCTAssertTrue(evaluatedActivities.contains(.indoorSightseeing))
    }

    // D. Ranking & Tie-breaking
    func testActivityRankingAndDeterministicTieBreaking() async {
        let forecast = makeSampleForecast(for: testLocation)
        mockService.result = .success(forecast)

        let viewModel = ForecastViewModel(
            location: testLocation,
            forecastService: mockService,
            suitabilityEngine: suitabilityEngine
        )

        viewModel.loadForecast()
        await viewModel.fetchTask?.value

        guard case .success(let data) = viewModel.state,
              let daily = data.dailySuitabilities.first else {
            XCTFail("Expected .success state")
            return
        }

        let results = daily.rankedResults
        for i in 0..<(results.count - 1) {
            let current = results[i]
            let next = results[i + 1]
            if current.score == next.score {
                XCTAssertLessThan(current.activity.rawValue, next.activity.rawValue, "Equal scores must be sorted alphabetically by activity rawValue")
            } else {
                XCTAssertGreaterThan(current.score, next.score, "Results must be sorted descending by score")
            }
        }
    }

    // E. Location handling & Updates
    func testForecastServiceReceivesCorrectLocationAndCoordinates() async {
        let forecast = makeSampleForecast(for: testLocation)
        mockService.result = .success(forecast)

        let viewModel = ForecastViewModel(
            location: testLocation,
            forecastService: mockService,
            suitabilityEngine: suitabilityEngine
        )

        viewModel.loadForecast()
        await viewModel.fetchTask?.value

        XCTAssertEqual(mockService.requestedLocation, testLocation)
        XCTAssertEqual(mockService.requestedLocation?.latitude, 35.6762)
        XCTAssertEqual(mockService.requestedLocation?.longitude, 139.6503)
        XCTAssertEqual(mockService.requestedLocation?.name, "Tokyo")
    }

    func testUpdateLocationChangesLocationAndReloadsForecast() async {
        let forecast = makeSampleForecast(for: testLocation)
        mockService.result = .success(forecast)

        let viewModel = ForecastViewModel(
            location: testLocation,
            forecastService: mockService,
            suitabilityEngine: suitabilityEngine
        )

        let newLocation = Location(name: "Osaka", country: "Japan", administrativeArea: "Osaka", latitude: 34.6937, longitude: 135.5023)
        viewModel.updateLocation(newLocation)

        XCTAssertEqual(viewModel.location, newLocation)
        XCTAssertEqual(viewModel.state, .loading)

        await viewModel.fetchTask?.value

        XCTAssertEqual(mockService.requestedLocation, newLocation)
    }

    func testLocationSubtitleAndDateFormatting() {
        let viewModel = ForecastViewModel(
            location: testLocation,
            forecastService: mockService,
            suitabilityEngine: suitabilityEngine
        )

        XCTAssertEqual(viewModel.locationSubtitle, "Tokyo, Japan")

        let date = Date(timeIntervalSince1970: 1700000000)
        XCTAssertFalse(viewModel.formattedDate(date).isEmpty)
    }

    // F. Loading state transitions
    func testStateTransitionsFromIdleToLoadingToSuccess() async {
        let forecast = makeSampleForecast(for: testLocation)
        mockService.result = .success(forecast)

        let viewModel = ForecastViewModel(
            location: testLocation,
            forecastService: mockService,
            suitabilityEngine: suitabilityEngine
        )

        XCTAssertEqual(viewModel.state, .idle)

        viewModel.loadForecast()
        XCTAssertEqual(viewModel.state, .loading)

        await viewModel.fetchTask?.value
        if case .success = viewModel.state {
            // Passed
        } else {
            XCTFail("State should be .success")
        }
    }

    func testStateTransitionsFromIdleToLoadingToError() async {
        mockService.result = .failure(NetworkError.emptyData)

        let viewModel = ForecastViewModel(
            location: testLocation,
            forecastService: mockService,
            suitabilityEngine: suitabilityEngine
        )

        XCTAssertEqual(viewModel.state, .idle)

        viewModel.loadForecast()
        XCTAssertEqual(viewModel.state, .loading)

        await viewModel.fetchTask?.value
        if case .error = viewModel.state {
            // Passed
        } else {
            XCTFail("State should be .error")
        }
    }

    // G. Cancellation
    func testTaskCancellationWhenNewRequestOrExplicitCancelTriggered() async {
        mockService.delayNanoseconds = 500_000_000 // 500ms
        let forecast = makeSampleForecast(for: testLocation)
        mockService.result = .success(forecast)

        let viewModel = ForecastViewModel(
            location: testLocation,
            forecastService: mockService,
            suitabilityEngine: suitabilityEngine
        )

        viewModel.loadForecast()
        let initialTask = viewModel.fetchTask

        viewModel.cancelForecast()
        XCTAssertTrue(initialTask?.isCancelled == true)
    }

    // H. Memory Leak Detection Verification Test
    func testMemoryLeak() {
        var instance: ForecastViewModel? = ForecastViewModel(
            location: testLocation,
            forecastService: mockService,
            suitabilityEngine: suitabilityEngine
        )
        // Track instance for memory leaks
        trackForMemoryLeaks(instance!)
    }

    // Helper method
    private func makeSampleForecast(for location: Location) -> Forecast {
        let now = Date()
        let dailyForecast = DailyForecast(
            date: now,
            temperatureMax: 24.0,
            temperatureMin: 18.0,
            precipitationSum: 0.0,
            snowfallSum: 0.0,
            windSpeedMax: 12.0,
            weatherCode: 0
        )
        return Forecast(location: location, dailyForecasts: [dailyForecast])
    }
}
