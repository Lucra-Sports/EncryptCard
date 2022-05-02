//
//  aesEncryptTest.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import XCTest
import CommonCrypto

class aesEncryptTest: XCTestCase {
    func testEncrypt() {
        let operation = CCOperation(kCCEncrypt)
        let keyData = String(repeating: "A", count: 32)
        let inputData = "adlsfjhasdlkfjhasldkjfhasdlkfjhsadkfjhasfjhdasklfjh"
        let ivData = String(repeating: "A", count: kCCBlockSizeAES128)
        let padLength = kCCBlockSizeAES128
        var result = Data(repeating: .zero, count: inputData.count + padLength)
        var resultLength: size_t = 0
        let error = result.withUnsafeMutableBytes { buffer  in
            CCCrypt(
                operation,
                CCAlgorithm(kCCAlgorithmAES128),
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
        print(result.base64EncodedString())
    }
}
