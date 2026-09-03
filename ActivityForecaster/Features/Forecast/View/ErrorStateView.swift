//
//  ErrorStateView.swift
//  ActivityForecaster
//

import SwiftUI

struct ErrorStateView: View {
    let title: String
    let message: String
    let retryAction: (() -> Void)?

    init(
        title: String = "Unable to Load Forecast",
        message: String,
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundColor(.orange)

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("retryButton")
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorStateView(
        message: "Server responded with HTTP error code 500.",
        retryAction: {}
    )
}
