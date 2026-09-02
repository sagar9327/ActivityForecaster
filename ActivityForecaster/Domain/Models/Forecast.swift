//
//  Forecast.swift
//  ActivityForecaster
//

import Foundation

/// Domain model representing weather forecast for a location over multiple days.
struct Forecast: Equatable, Hashable, Sendable {
    let location: Location
    let dailyForecasts: [DailyForecast]

    init(location: Location, dailyForecasts: [DailyForecast]) {
        self.location = location
        self.dailyForecasts = dailyForecasts
    }
}
