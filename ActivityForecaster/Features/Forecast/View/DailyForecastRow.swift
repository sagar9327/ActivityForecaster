//
//  DailyForecastRow.swift
//  ActivityForecaster
//

import SwiftUI

struct DailyForecastRow: View {
    let daily: DailySuitability

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(daily.formattedDate)
                .font(.headline)

            ForEach(daily.rankedResults) { result in
                HStack(spacing: 10) {
                    Image(systemName: result.activity.iconName)
                        .font(.body)
                        .foregroundColor(.accentColor)
                        .frame(width: 28, height: 28)
                        .background(Color.accentColor.opacity(0.12))
                        .clipShape(Circle())

                    Text(result.activity.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("\(result.score)")
                            .font(.subheadline)
                            .bold()

                        Text(result.rating.rawValue)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(result.rating.color.opacity(0.15))
                            .foregroundColor(result.rating.color)
                            .cornerRadius(6)
                    }
                }
                .accessibilityIdentifier("activityResult_\(result.activity.rawValue)")
            }
        }
        .padding(.vertical, 6)
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
