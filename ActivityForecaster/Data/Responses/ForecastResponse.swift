//
//  ForecastResponse.swift
//  ActivityForecaster
//

import Foundation

/// Decodable representation of Open-Meteo Forecast API response.
struct ForecastResponse: Decodable, Sendable {
    struct DailyUnitsResponse: Decodable, Sendable {
        let time: String?
        let weatherCode: String?
        let temperature2mMax: String?
        let temperature2mMin: String?
        let precipitationSum: String?
        let snowfallSum: String?
        let windSpeed10mMax: String?

        enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
            case precipitationSum = "precipitation_sum"
            case snowfallSum = "snowfall_sum"
            case windSpeed10mMax = "wind_speed_10m_max"
        }
    }

    struct DailyResponse: Decodable, Sendable {
        let time: [String]?
        let weatherCode: [Int]?
        let temperature2mMax: [Double]?
        let temperature2mMin: [Double]?
        let precipitationSum: [Double]?
        let snowfallSum: [Double]?
        let windSpeed10mMax: [Double]?

        enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
            case precipitationSum = "precipitation_sum"
            case snowfallSum = "snowfall_sum"
            case windSpeed10mMax = "wind_speed_10m_max"
        }
    }

    let latitude: Double?
    let longitude: Double?
    let timezone: String?
    let dailyUnits: DailyUnitsResponse?
    let daily: DailyResponse?

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case timezone
        case dailyUnits = "daily_units"
        case daily
    }
}
