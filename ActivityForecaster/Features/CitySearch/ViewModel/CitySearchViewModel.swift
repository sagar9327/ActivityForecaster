//
//  CitySearchViewModel.swift
//  ActivityForecaster
//

import Foundation
import Combine

/// Represents presentation states for the City Search feature.
enum CitySearchState: Equatable, Sendable {
    case idle
    case loading
    case results([Location])
    case empty
    case error(String)
}

/// ViewModel coordinating City Search query input, debouncing, state management, and location selection.
@MainActor
final class CitySearchViewModel: ObservableObject {
    @Published var searchQuery: String = "" {
        didSet {
            queryDidChange(searchQuery)
        }
    }
    @Published private(set) var state: CitySearchState = .idle
    @Published private(set) var selectedLocation: Location? = nil

    private let geocodingService: GeocodingServiceProtocol
    private let debounceNanoseconds: UInt64
    private(set) var searchTask: Task<Void, Never>?

    init(
        geocodingService: GeocodingServiceProtocol,
        debounceNanoseconds: UInt64 = 300_000_000 // 300ms
    ) {
        self.geocodingService = geocodingService
        self.debounceNanoseconds = debounceNanoseconds
    }

    func queryDidChange(_ query: String) {
        searchTask?.cancel()

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            state = .idle
            return
        }

        searchTask = Task { @MainActor in
            do {
                if debounceNanoseconds > 0 {
                    try await Task.sleep(nanoseconds: debounceNanoseconds)
                }
                guard !Task.isCancelled else { return }

                state = .loading

                let locations = try await geocodingService.searchCity(trimmedQuery)
                guard !Task.isCancelled else { return }

                // Stale result protection check: verify current query matches searched query
                guard self.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedQuery else {
                    return
                }

                if locations.isEmpty {
                    state = .empty
                } else {
                    state = .results(locations)
                }
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                state = .error(message)
            }
        }
    }

    func selectLocation(_ location: Location) {
        selectedLocation = location
    }

    func clearSearch() {
        searchTask?.cancel()
        searchTask = nil
        searchQuery = ""
        state = .idle
    }
}
