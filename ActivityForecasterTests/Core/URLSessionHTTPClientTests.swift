//
//  URLSessionHTTPClientTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("No request handler configured for MockURLProtocol")
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

final class URLSessionHTTPClientTests: XCTestCase {

    private var httpClient: URLSessionHTTPClient!
    private let testURL = URL(string: "https://api.open-meteo.com/v1/forecast")!

    private struct TestResponse: Codable, Equatable {
        let title: String
        let value: Int
    }

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        httpClient = URLSessionHTTPClient(session: session)
    }

    override func tearDown() {
        httpClient = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testExecuteSuccessDecodesResponse() async throws {
        let expectedResponse = TestResponse(title: "Test", value: 42)
        let responseData = try JSONEncoder().encode(expectedResponse)

        MockURLProtocol.requestHandler = { request in
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, responseData)
        }

        let request = URLRequest(url: testURL)
        let result: TestResponse = try await httpClient.execute(request)

        XCTAssertEqual(result, expectedResponse)
    }

    func testExecuteNon2xxStatusCodeThrowsHttpError() async {
        MockURLProtocol.requestHandler = { request in
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, "Internal Server Error".data(using: .utf8))
        }

        let request = URLRequest(url: testURL)

        do {
            let _: TestResponse = try await httpClient.execute(request)
            XCTFail("Expected NetworkError.httpError")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.httpError(statusCode: 500))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testExecuteEmptyDataThrowsEmptyDataError() async {
        MockURLProtocol.requestHandler = { request in
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, Data())
        }

        let request = URLRequest(url: testURL)

        do {
            let _: TestResponse = try await httpClient.execute(request)
            XCTFail("Expected NetworkError.emptyData")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.emptyData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testExecuteMalformedJSONThrowsDecodingError() async {
        MockURLProtocol.requestHandler = { request in
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, "{ invalid json }".data(using: .utf8))
        }

        let request = URLRequest(url: testURL)

        do {
            let _: TestResponse = try await httpClient.execute(request)
            XCTFail("Expected NetworkError.decodingError")
        } catch let error as NetworkError {
            guard case .decodingError = error else {
                XCTFail("Expected NetworkError.decodingError, got \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testExecuteLowLevelNetworkFailureThrowsNetworkFailureError() async {
        MockURLProtocol.requestHandler = { _ in
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        }

        let request = URLRequest(url: testURL)

        do {
            let _: TestResponse = try await httpClient.execute(request)
            XCTFail("Expected NetworkError.networkFailure")
        } catch let error as NetworkError {
            guard case .networkFailure = error else {
                XCTFail("Expected NetworkError.networkFailure, got \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
