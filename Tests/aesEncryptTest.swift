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
