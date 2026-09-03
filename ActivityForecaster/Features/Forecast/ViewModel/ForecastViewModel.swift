//
//  ForecastViewModel.swift
//  ActivityForecaster
//

import Foundation
import Combine

/// Data container holding location, forecast, and daily suitability breakdowns.
struct ForecastData: Equatable, Sendable {
    let location: Location
    let forecast: Forecast
    let dailySuitabilities: [DailySuitability]
}

/// Suitability results for a specific forecast date.
struct DailySuitability: Equatable, Sendable, Identifiable {
    var id: Date { date }
    let date: Date
    let rankedResults: [SuitabilityResult]

    private static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    static func formattedDate(for date: Date) -> String {
        mediumDateFormatter.string(from: date)
    }

    var formattedDate: String {
        Self.formattedDate(for: date)
    }
}

/// Represents presentation states for the Forecast & Suitability feature.
enum ForecastState: Equatable, Sendable {
    case idle
    case loading
    case success(ForecastData)
    case error(String)
}

/// ViewModel coordinating location forecast fetching, suitability evaluation, and activity ranking.
@MainActor
final class ForecastViewModel: ObservableObject {
    @Published private(set) var location: Location
    @Published private(set) var state: ForecastState = .idle

    private let forecastService: ForecastServiceProtocol
    private let suitabilityEngine: SuitabilityEngine
    private(set) var fetchTask: Task<Void, Never>?

    init(
        location: Location,
        forecastService: ForecastServiceProtocol = OpenMeteoForecastService(),
        suitabilityEngine: SuitabilityEngine = SuitabilityEngine()
    ) {
        self.location = location
        self.forecastService = forecastService
        self.suitabilityEngine = suitabilityEngine
    }

    /// Fetches forecast data for the selected location and calculates suitability results.
    func loadForecast() {
        fetchTask?.cancel()
        state = .loading

        let currentLocation = location
        fetchTask = Task { @MainActor in
            do {
                let forecast = try await forecastService.fetchForecast(for: currentLocation)
                guard !Task.isCancelled else { return }

                let dailySuitabilityMap = suitabilityEngine.calculateSuitability(for: forecast)

                let sortedDailySuitabilities = forecast.dailyForecasts.compactMap { dailyForecast -> DailySuitability? in
                    guard let rankedResults = dailySuitabilityMap[dailyForecast.date] else { return nil }
                    return DailySuitability(date: dailyForecast.date, rankedResults: rankedResults)
                }

                let forecastData = ForecastData(
                    location: currentLocation,
                    forecast: forecast,
                    dailySuitabilities: sortedDailySuitabilities
                )

                state = .success(forecastData)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                state = .error(message)
            }
        }
    }

    /// Updates the selected location and reloads forecast and suitability results.
    func updateLocation(_ newLocation: Location) {
        guard newLocation != location else { return }
        location = newLocation
        loadForecast()
    }

    /// Formatted location administrative area and country subtitle.
    var locationSubtitle: String? {
        let parts = [location.administrativeArea, location.country].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    /// Formats a date into a medium presentation style string.
    func formattedDate(_ date: Date) -> String {
        DailySuitability.formattedDate(for: date)
    }

    /// Cancels any in-flight forecast fetch task.
    func cancelForecast() {
        fetchTask?.cancel()
        fetchTask = nil
    }
}
