//
//  RsaEncryptTest.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import XCTest
@testable import EncryptCard

class RsaEncryptTest: XCTestCase {
    func testThrowForInvalidKey() throws {
        let attributes = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: 2048,
        ] as CFDictionary
        let key = try XCTUnwrap(SecKeyCreateRandomKey(attributes, nil))
        XCTAssertThrowsError(try rsaEncrypt(publicKey: key, data: Data())) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, NSOSStatusErrorDomain)
            XCTAssertEqual(nsError.code, Int(errSecParam))
            let description = nsError.userInfo["NSDescription"] as! String
            XCTAssertTrue(description.hasPrefix(
                "algid:encrypt:RSA:PKCS1: algorithm not supported by the key")
            )
            XCTAssertEqual(SecCopyErrorMessageString(OSStatus(nsError.code), nil) as String?,
                           "One or more parameters passed to a function were not valid.")
        }
    }
}
