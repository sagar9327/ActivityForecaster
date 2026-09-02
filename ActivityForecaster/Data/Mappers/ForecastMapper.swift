//
//  ForecastMapper.swift
//  ActivityForecaster
//

import Foundation

/// Mapper responsible for transforming parallel array ForecastResponse into domain Forecast model.
enum ForecastMapper {

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func map(_ response: ForecastResponse, for location: Location) throws -> Forecast {
        guard let daily = response.daily,
              let times = daily.time,
              let tempMax = daily.temperature2mMax,
              let tempMin = daily.temperature2mMin,
              let precipitation = daily.precipitationSum,
              let snowfall = daily.snowfallSum,
              let windSpeed = daily.windSpeed10mMax,
              let weatherCodes = daily.weatherCode else {
            throw NetworkError.mappingError(reason: "Missing essential daily forecast arrays in API response.")
        }

        let count = times.count
        guard count > 0 else {
            throw NetworkError.mappingError(reason: "Empty daily forecast times array.")
        }

        // Validate parallel array lengths consistency
        guard tempMax.count == count,
              tempMin.count == count,
              precipitation.count == count,
              snowfall.count == count,
              windSpeed.count == count,
              weatherCodes.count == count else {
            throw NetworkError.mappingError(reason: "Mismatched daily forecast array lengths.")
        }

        var dailyForecasts: [DailyForecast] = []
        dailyForecasts.reserveCapacity(count)

        for i in 0..<count {
            let timeString = times[i]
            guard let date = dateFormatter.date(from: timeString) else {
                throw NetworkError.mappingError(reason: "Invalid date format string '\(timeString)'. Expected 'yyyy-MM-dd'.")
            }

            let dailyItem = DailyForecast(
                date: date,
                temperatureMax: tempMax[i],
                temperatureMin: tempMin[i],
                precipitationSum: precipitation[i],
                snowfallSum: snowfall[i],
                windSpeedMax: windSpeed[i],
                weatherCode: weatherCodes[i]
            )

            dailyForecasts.append(dailyItem)
        }

        return Forecast(location: location, dailyForecasts: dailyForecasts)
    }

    /// Exposes date parsing utility for explicit date conversion testing.
    static func parseDate(_ dateString: String) -> Date? {
        dateFormatter.date(from: dateString)
    }
}
