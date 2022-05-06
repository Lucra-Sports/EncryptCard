//
//  aesEncryptTest.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import XCTest
import CommonCrypto
@testable import EncryptCard

class AesEncryptTest: XCTestCase {
    func testAesEncryptReturnsStablePaddedResult() throws {
        let keyData = Data(repeating: 0, count: kCCKeySizeAES256)
        let ivData = Data(repeating: 0, count: kCCBlockSizeAES128)
        let input = Data(repeating: 0, count: 20)
        let encrypted: String = try AES(key: keyData, seed: ivData).encrypt(data: input)
        XCTAssertEqual(encrypted, "3JXAeKJAiYmtSKIUkoQgh/qXGJ8YGa1hm/8h+bLBAPA=")
        XCTAssertEqual(encrypted, try AES(key: keyData, seed: ivData).encrypt(data: input))
        let encData = try XCTUnwrap(Data(base64Encoded: encrypted))
        XCTAssertEqual(encData.count % kCCBlockSizeAES128, 0, "should be in blocks")
    }
    func testAesEncryptThrowsForInvalidKeySize() throws {
        let withInvalidKey = AES(key: .init(), seed: .init())
        XCTAssertThrowsError(try withInvalidKey.encrypt(data: .init()), "should be invalid") { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, NSOSStatusErrorDomain)
            XCTAssertEqual(nsError.code, kCCKeySizeError)
        }
    }
}
