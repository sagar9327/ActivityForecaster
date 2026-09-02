//
//  GeocodingResponseTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class GeocodingResponseTests: XCTestCase {

    func testDecodeGeocodingResponseFromJSON() throws {
        let jsonString = """
        {
          "results": [
            {
              "id": 1279233,
              "name": "Ahmedabad",
              "latitude": 23.02579,
              "longitude": 72.58727,
              "country": "India",
              "admin1": "Gujarat"
            },
            {
              "id": 2643743,
              "name": "London",
              "latitude": 51.50853,
              "longitude": -0.12574,
              "country": "United Kingdom",
              "admin1": "England"
            }
          ]
        }
        """

        let data = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        let response = try decoder.decode(GeocodingResponse.self, from: data)

        XCTAssertNotNil(response.results)
        XCTAssertEqual(response.results?.count, 2)

        let first = try XCTUnwrap(response.results?.first)
        XCTAssertEqual(first.name, "Ahmedabad")
        XCTAssertEqual(first.latitude, 23.02579, accuracy: 0.0001)
        XCTAssertEqual(first.longitude, 72.58727, accuracy: 0.0001)
        XCTAssertEqual(first.country, "India")
        XCTAssertEqual(first.admin1, "Gujarat")
    }

    func testDecodeEmptyGeocodingResponseFromJSON() throws {
        let jsonString = """
        {
          "generationtime_ms": 0.12
        }
        """

        let data = Data(jsonString.utf8)
        let response = try JSONDecoder().decode(GeocodingResponse.self, from: data)

        XCTAssertNil(response.results)
    }
}
