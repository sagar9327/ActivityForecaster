//
//  DailyForecastRow.swift
//  ActivityForecaster
//

import SwiftUI

struct DailyForecastRow: View {
    let daily: DailySuitability

    var body: some View {
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
                .accessibilityIdentifier("activityResult_\(result.activity.rawValue)")
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let now = Date()
    let daily = DailySuitability(
        date: now,
        rankedResults: [
            SuitabilityResult(activity: .outdoorSightseeing, score: 88, date: now),
            SuitabilityResult(activity: .indoorSightseeing, score: 76, date: now),
            SuitabilityResult(activity: .surfing, score: 42, date: now),
            SuitabilityResult(activity: .skiing, score: 15, date: now)
        ]
    )

    List {
        DailyForecastRow(daily: daily)
    }
}
