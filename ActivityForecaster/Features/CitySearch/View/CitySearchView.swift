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
            VStack(spacing: 16) {
                HStack {
                    TextField("Search city...", text: $viewModel.searchQuery)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()

                    if !viewModel.searchQuery.isEmpty {
                        Button("Clear") {
                            viewModel.clearSearch()
                        }
                    }
                }
                .padding(.horizontal)

                switch viewModel.state {
                case .idle:
                    Text("Enter a city name to search")
                        .foregroundColor(.secondary)
                        .padding()
                case .loading:
                    ProgressView("Searching cities...")
                        .padding()
                case .empty:
                    Text("No matching cities found")
                        .foregroundColor(.secondary)
                        .padding()
                case .error(let message):
                    Text("Error: \(message)")
                        .foregroundColor(.red)
                        .padding()
                case .results(let locations):
                    List(locations, id: \.self) { location in
                        Button {
                            viewModel.selectLocation(location)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(location.name)
                                        .font(.headline)
                                    if let details = locationDetails(for: location) {
                                        Text(details)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                if viewModel.selectedLocation == location {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle("City Search")
        }
    }

    private func locationDetails(for location: Location) -> String? {
        let parts = [location.administrativeArea, location.country].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}

