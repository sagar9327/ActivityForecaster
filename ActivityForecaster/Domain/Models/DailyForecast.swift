//
//  DailyForecast.swift
//  ActivityForecaster
//

import Foundation

/// Domain model representing daily weather forecast parameters required for activity scoring.
struct DailyForecast: Equatable, Hashable, Sendable {
    let date: Date
    let temperatureMax: Double       // °C
    let temperatureMin: Double       // °C
    let precipitationSum: Double     // mm
    let snowfallSum: Double          // cm
    let windSpeedMax: Double         // km/h
    let weatherCode: Int             // WMO Weather Code
    let temperatureApparentMax: Double? // °C optional feel-like temp

    init(
        date: Date,
        temperatureMax: Double,
        temperatureMin: Double,
        precipitationSum: Double = 0.0,
        snowfallSum: Double = 0.0,
        windSpeedMax: Double = 0.0,
        weatherCode: Int = 0,
        temperatureApparentMax: Double? = nil
    ) {
        self.date = date
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.precipitationSum = precipitationSum
        self.snowfallSum = snowfallSum
        self.windSpeedMax = windSpeedMax
        self.weatherCode = weatherCode
        self.temperatureApparentMax = temperatureApparentMax
    }

    /// Calculated mean temperature for the day.
    var averageTemperature: Double {
        (temperatureMax + temperatureMin) / 2.0
    }
}
