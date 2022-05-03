//
//  aesEncryptTest.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import XCTest
import CommonCrypto
@testable import EncryptCard

class aesEncryptTest: XCTestCase {
    func testSecureRandom() {
        let count = 10000
        let data = secureRandom(size: count)
        XCTAssertTrue(data.contains(UInt8.max), "should include max")
        XCTAssertTrue(data.contains(UInt8.min), "should include main")
        let average = UInt8(data.map(Int.init).reduce(0, +) / count)
        XCTAssertEqual(average, UInt8.max / 2, accuracy: UInt8.max / 4,
                       "average should be middle value with 0.25 of range accuracy")
    }
    func testAesEncryptReturnsStablePaddedResult() throws {
        let keyData = Data(repeating: 0, count: kCCKeySizeAES256)
        let ivData = Data(repeating: 0, count: kCCBlockSizeAES128)
        let input = String(repeating: "A", count: 20)
        let encrypted = try aesEncrypt(key: keyData, seed: ivData, string: input)
        XCTAssertEqual(encrypted, "fg51d++cMKa/CyXgYh6CfklCobeQJP2bzEQPAlt4hLk=")
        let encData = try XCTUnwrap(Data(base64Encoded: encrypted))
        XCTAssertEqual(encData.count % kCCBlockSizeAES128, 0, "should be in blocks")
    }
    func testAesEncryptThrowsForInvalidKeySize() throws {
        XCTAssertThrowsError(try aesEncrypt(key: Data(), seed: Data(), string: ""), "should be invalid") { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, NSOSStatusErrorDomain)
            XCTAssertEqual(nsError.code, kCCKeySizeError)
        }
    }
}
