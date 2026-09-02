//
//  ForecastView.swift
//  ActivityForecaster
//

import SwiftUI

struct ForecastView: View {
    @StateObject var viewModel: ForecastViewModel

    init(viewModel: ForecastViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.location.name)
                    .font(.title2)
                    .bold()
                if let area = viewModel.locationSubtitle {
                    Text(area)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            switch viewModel.state {
            case .idle:
                Text("Tap load forecast to calculate activity suitability.")
                    .foregroundColor(.secondary)
                    .padding()

            case .loading:
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Loading forecast & calculating suitability...")
                        .foregroundColor(.secondary)
                }
                .padding()

            case .error(let message):
                VStack(alignment: .leading, spacing: 8) {
                    Text("Error loading forecast:")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(message)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        viewModel.loadForecast()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()

            case .success(let data):
                List {
                    ForEach(data.dailySuitabilities) { daily in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(daily.formattedDate)
                                .font(.subheadline)
                                .bold()
                            ForEach(daily.rankedResults) { result in
                                HStack {
                                    Text(result.activity.displayName)
                                        .font(.caption)
                                    Spacer()
                                    Text("\(result.score) (\(result.rating.rawValue))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("Activity Suitability")
        .onAppear {
            if viewModel.state == .idle {
                viewModel.loadForecast()
            }
        }
    }
}
