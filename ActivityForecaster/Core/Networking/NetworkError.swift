//
//  NetworkError.swift
//  ActivityForecaster
//

import Foundation

/// Application networking and data processing errors.
enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case networkFailure(String)
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(String)
    case mappingError(reason: String)
    case emptyData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .networkFailure(let details):
            return "Network failure: \(details)"
        case .invalidResponse:
            return "Received invalid response from server."
        case .httpError(let statusCode):
            return "Server responded with HTTP error code \(statusCode)."
        case .decodingError(let details):
            return "Failed to decode response data: \(details)"
        case .mappingError(let reason):
            return "Data mapping failure: \(reason)"
        case .emptyData:
            return "No data received from server."
        }
    }
}
