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
        let count = 10
        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        XCTAssertEqual(status, errSecSuccess)
        let average = UInt8(bytes.map(Int.init).reduce(0, +) / count)
        XCTAssertEqual(average, UInt8.max / 2, accuracy: UInt8.max / 4)
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
}
