//
//  aesEncryptTest.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import XCTest
import CommonCrypto

class aesEncryptTest: XCTestCase {
    func testSecureRandom() {
        let count = 10
        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        XCTAssertEqual(status, errSecSuccess)
        let average = UInt8(bytes.map(Int.init).reduce(0, +) / count)
        XCTAssertEqual(average, UInt8.max / 2, accuracy: UInt8.max / 4)
    }
    func testAesEncrypt() {
        let keyData = String(repeating: "K", count: kCCKeySizeAES256)
        let ivData = String(repeating: "I", count: kCCBlockSizeAES128)
        let inputData = String(repeating: "D", count: 20)
        let padLength = kCCBlockSizeAES128
        var result = Data(repeating: .zero, count: inputData.count + padLength)
        var resultLength: size_t = 0
        let error = result.withUnsafeMutableBytes { buffer  in
            CCCrypt(
                CCOperation(kCCEncrypt),
                CCAlgorithm(kCCAlgorithmAES),
                CCOptions(kCCOptionPKCS7Padding),
                keyData.bytes, keyData.count,
                ivData.bytes,
                inputData.bytes, inputData.count,
                buffer.baseAddress!, buffer.count,
                &resultLength
            )
        }
        XCTAssertEqual(error, CCCryptorStatus(kCCSuccess))
        XCTAssertLessThanOrEqual(resultLength, result.count)
        XCTAssertEqual(result.base64EncodedString(), "MN6IsJr+G6WkLXPNEHGBa/mgy6x+ZTHemZ71JBMkooUAAAAA")
    }
}
