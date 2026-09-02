//
//  EmptyStateView.swift
//  ActivityForecaster
//

import SwiftUI

struct EmptyStateView: View {
    let iconName: String
    let title: String
    let message: String

    init(
        iconName: String = "magnifyingglass",
        title: String,
        message: String
    ) {
        self.iconName = iconName
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 44))
                .foregroundColor(.secondary)

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        iconName: "building.2.crop.circle",
        title: "No Matching Cities",
        message: "Try searching with a different city or town name."
    )
}
