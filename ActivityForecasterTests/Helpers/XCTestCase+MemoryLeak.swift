//
//  XCTestCase+MemoryLeak.swift
//  ActivityForecasterTests
//

import XCTest

extension XCTestCase {
    /// Tracks an object instance and fails the test if it is not deallocated at the end of test execution.
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "MEMORY LEAK DETECTED: \(String(describing: instance)) was not deallocated from memory. Check for strong reference cycles!",
                file: file,
                line: line
            )
        }
    }
}
