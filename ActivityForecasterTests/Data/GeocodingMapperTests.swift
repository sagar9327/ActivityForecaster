//
//  GeocodingMapperTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class GeocodingMapperTests: XCTestCase {

    func testMapGeocodingResponseToLocations() {
        let item1 = GeocodingResponse.LocationResponse(
            id: 1,
            name: "Tokyo",
            latitude: 35.6895,
            longitude: 139.6917,
            country: "Japan",
            admin1: "Tokyo"
        )
        let item2 = GeocodingResponse.LocationResponse(
            id: 2,
            name: "Paris",
            latitude: 48.8566,
            longitude: 2.3522,
            country: "France",
            admin1: "Île-de-France"
        )
        let response = GeocodingResponse(results: [item1, item2])

        let locations = GeocodingMapper.map(response)

        XCTAssertEqual(locations.count, 2)
        XCTAssertEqual(locations[0].name, "Tokyo")
        XCTAssertEqual(locations[0].country, "Japan")
        XCTAssertEqual(locations[0].administrativeArea, "Tokyo")
        XCTAssertEqual(locations[0].latitude, 35.6895, accuracy: 0.0001)
        XCTAssertEqual(locations[0].longitude, 139.6917, accuracy: 0.0001)

        XCTAssertEqual(locations[1].name, "Paris")
        XCTAssertEqual(locations[1].country, "France")
    }

    func testMapGeocodingResponseWithNilOptionalFields() {
        let item = GeocodingResponse.LocationResponse(
            id: 99,
            name: "Unknown Island",
            latitude: 0.0,
            longitude: 0.0,
            country: nil,
            admin1: nil
        )
        let response = GeocodingResponse(results: [item])

        let locations = GeocodingMapper.map(response)

        XCTAssertEqual(locations.count, 1)
        XCTAssertEqual(locations[0].name, "Unknown Island")
        XCTAssertNil(locations[0].country)
        XCTAssertNil(locations[0].administrativeArea)
    }

    func testMapNilResponseToEmptyLocations() {
        let response = GeocodingResponse(results: nil)
        let locations = GeocodingMapper.map(response)
        XCTAssertTrue(locations.isEmpty)
    }
}
