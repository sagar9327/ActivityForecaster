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
                        DailyForecastRow(daily: daily)
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("Activity Suitability")
        .accessibilityIdentifier("forecastScreen")
        .onAppear {
            if viewModel.state == .idle {
                viewModel.loadForecast()
            }
        }
    }
}

#Preview("Forecast View - Loaded") {
    let location = Location(name: "Tokyo", country: "Japan", administrativeArea: "Tokyo", latitude: 35.6762, longitude: 139.6503)
    let now = Date()
    let forecast = Forecast(
        location: location,
        dailyForecasts: [
            DailyForecast(date: now, temperatureMax: 24.0, temperatureMin: 18.0, precipitationSum: 0.0, snowfallSum: 0.0, windSpeedMax: 12.0, weatherCode: 0),
            DailyForecast(date: now.addingTimeInterval(86400), temperatureMax: -4.0, temperatureMin: -10.0, precipitationSum: 0.0, snowfallSum: 15.0, windSpeedMax: 25.0, weatherCode: 73)
        ]
    )
    let mockService = PreviewForecastService(result: .success(forecast))

    let vm = ForecastViewModel(location: location, forecastService: mockService)
    vm.loadForecast()
    return NavigationStack {
        ForecastView(viewModel: vm)
    }
}

#Preview("Forecast View - Error") {
    let location = Location(name: "Tokyo", country: "Japan", administrativeArea: "Tokyo", latitude: 35.6762, longitude: 139.6503)
    let mockService = PreviewForecastService(result: .failure(NetworkError.httpError(statusCode: 500)))

    let vm = ForecastViewModel(location: location, forecastService: mockService)
    vm.loadForecast()
    return NavigationStack {
        ForecastView(viewModel: vm)
    }
}
