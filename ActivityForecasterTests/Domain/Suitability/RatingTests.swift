//
//  RatingTests.swift
//  ActivityForecasterTests
//

import XCTest
@testable import ActivityForecaster

final class RatingTests: XCTestCase {

    func testRatingScoreBoundaries() {
        // Required test boundary scores: 0, 24, 25, 49, 50, 74, 75, 89, 90, 100
        XCTAssertEqual(Rating.from(score: 0), .veryPoor)
        XCTAssertEqual(Rating.from(score: 24), .veryPoor)

        XCTAssertEqual(Rating.from(score: 25), .poor)
        XCTAssertEqual(Rating.from(score: 49), .poor)

        XCTAssertEqual(Rating.from(score: 50), .fair)
        XCTAssertEqual(Rating.from(score: 74), .fair)

        XCTAssertEqual(Rating.from(score: 75), .good)
        XCTAssertEqual(Rating.from(score: 89), .good)

        XCTAssertEqual(Rating.from(score: 90), .excellent)
        XCTAssertEqual(Rating.from(score: 100), .excellent)
    }

    func testOutofRangeScoreClamping() {
        XCTAssertEqual(Rating.from(score: -50), .veryPoor)
        XCTAssertEqual(Rating.from(score: 150), .excellent)
    }

    func testRatingComparison() {
        XCTAssertTrue(Rating.veryPoor < Rating.poor)
        XCTAssertTrue(Rating.poor < Rating.fair)
        XCTAssertTrue(Rating.fair < Rating.good)
        XCTAssertTrue(Rating.good < Rating.excellent)
    }
}
