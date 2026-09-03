//
//  CitySearchView.swift
//  ActivityForecaster
//

import SwiftUI

struct CitySearchView: View {
    @StateObject var viewModel: CitySearchViewModel

    init(viewModel: CitySearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Input Header
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search city or town...", text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .submitLabel(.search)
                        .accessibilityIdentifier("citySearchTextField")

                    Button(action: {
                        viewModel.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("clearSearchButton")
                    .opacity(viewModel.searchQuery.isEmpty ? 0 : 1)
                    .disabled(viewModel.searchQuery.isEmpty)
                }
                .frame(height: 36)
                .padding(.horizontal, 12)
                .background(Color(uiColor: .tertiarySystemFill))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.vertical, 8)

                Divider()

                // Presentation State Switch
                switch viewModel.state {
                case .idle:
                    EmptyStateView(
                        iconName: "building.2.crop.circle",
                        title: "Find Weather Suitability",
                        message: "Enter a city or town name above to search for locations and activity forecasts."
                    )

                case .loading:
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Searching locations...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .empty:
                    EmptyStateView(
                        iconName: "magnifyingglass",
                        title: "No Cities Found",
                        message: "No matching cities were found for '\(viewModel.searchQuery)'. Try checking spelling or search for another location."
                    )

                case .error(let message):
                    ErrorStateView(
                        title: "Search Error",
                        message: message,
                        retryAction: {
                            viewModel.queryDidChange(viewModel.searchQuery)
                        }
                    )

                case .results(let locations):
                    List(locations, id: \.self) { location in
                        NavigationLink(value: location) {
                            SearchResultRow(
                                location: location,
                                subtitle: viewModel.locationSubtitle(for: location),
                                isSelected: viewModel.selectedLocation == location
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("City Search")
            .navigationDestination(for: Location.self) { location in
                ForecastView(viewModel: ForecastViewModel(location: location))
                    .onAppear {
                        viewModel.selectLocation(location)
                    }
            }
        }
    }
}

#Preview("City Search - Results") {
    let mockService = PreviewGeocodingService(locationsToReturn: [
        Location(name: "London", country: "United Kingdom", administrativeArea: "England", latitude: 51.5074, longitude: -0.1278),
        Location(name: "Tokyo", country: "Japan", administrativeArea: "Tokyo", latitude: 35.6762, longitude: 139.6503),
        Location(name: "Paris", country: "France", administrativeArea: "Île-de-France", latitude: 48.8566, longitude: 2.3522)
    ])
    let vm = CitySearchViewModel(geocodingService: mockService, debounceNanoseconds: 0)
    vm.searchQuery = "London"
    return CitySearchView(viewModel: vm)
}

#Preview("City Search - Idle") {
    let mockService = PreviewGeocodingService()
    let vm = CitySearchViewModel(geocodingService: mockService)
    return CitySearchView(viewModel: vm)
}

#Preview("City Search - Empty") {
    let mockService = PreviewGeocodingService(locationsToReturn: [])
    let vm = CitySearchViewModel(geocodingService: mockService, debounceNanoseconds: 0)
    vm.searchQuery = "UnknownPlace"
    return CitySearchView(viewModel: vm)
}
