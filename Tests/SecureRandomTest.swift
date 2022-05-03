//
//  SecureRandomTest.swift
//  
//
//  Created by Paul Zabelin on 5/3/22.
//

import XCTest
@testable import EncryptCard

class SecureRandomTest: XCTestCase {
    func testSecureRandom() {
        let count = 10000
        let data = secureRandom(size: count)
        XCTAssertTrue(data.contains(UInt8.max), "should include max")
        XCTAssertTrue(data.contains(UInt8.min), "should include min")
        let average = UInt8(data.map(Int.init).reduce(0, +) / count)
        XCTAssertEqual(average, UInt8.max / 2, accuracy: UInt8.max / 4,
                       "average should be middle value with 0.25 of range accuracy")
    }
}
