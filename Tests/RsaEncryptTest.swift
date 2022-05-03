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
    func testReturnLongStringForEmptyData() throws {
        let certificateUrl = Bundle.module.url(forResource: "keys/example-certificate.cer",
                                               withExtension: nil)!
        
        let data = try Data(contentsOf: certificateUrl)
        let certificate = try XCTUnwrap(SecCertificateCreateWithData(kCFAllocatorDefault, data as CFData))
        let secKey = try XCTUnwrap(SecCertificateCopyKey(certificate))
        let result = try rsaEncrypt(publicKey: secKey, data: Data())
        XCTAssertEqual(344, result.count)
    }
}
