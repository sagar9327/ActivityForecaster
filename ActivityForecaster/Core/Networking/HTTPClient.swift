//
//  HTTPClient.swift
//  ActivityForecaster
//

import Foundation

/// Protocol for HTTP client network requests to enable testing with mocks.
protocol HTTPClientProtocol: Sendable {
    func execute<T: Decodable>(_ request: URLRequest) async throws -> T
}

/// Concrete implementation of HTTPClientProtocol using URLSession.
final class URLSessionHTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.networkFailure(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        guard !data.isEmpty else {
            throw NetworkError.emptyData
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
}
