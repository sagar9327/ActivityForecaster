//
//  ActivityForecasterApp.swift
//  ActivityForecaster
//

import SwiftUI

@main
struct ActivityForecasterApp: App {
    var body: some Scene {
        WindowGroup {
            CitySearchView(viewModel: CitySearchViewModel(geocodingService: OpenMeteoGeocodingService(), debounceNanoseconds: 300_000_000))
        }
    }
}
