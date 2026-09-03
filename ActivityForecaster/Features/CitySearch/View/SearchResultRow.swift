//
//  SearchResultRow.swift
//  ActivityForecaster
//

import SwiftUI

struct SearchResultRow: View {
    let location: Location
    let subtitle: String?
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .font(.headline)

                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .accessibilityIdentifier("citySearchResultRow_\(location.name)")
    }
}

#Preview {
    List {
        SearchResultRow(
            location: Location(name: "London", country: "United Kingdom", administrativeArea: "England", latitude: 51.5074, longitude: -0.1278),
            subtitle: "England, United Kingdom",
            isSelected: true
        )
        SearchResultRow(
            location: Location(name: "Tokyo", country: "Japan", administrativeArea: "Tokyo", latitude: 35.6762, longitude: 139.6503),
            subtitle: "Tokyo, Japan",
            isSelected: false
        )
    }
}
