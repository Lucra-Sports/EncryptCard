//
//  RsaEncryptTest.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import XCTest
@testable import EncryptCard
import CommonCrypto

class RsaEncryptTest: XCTestCase {
    func testReturnsBlockSizeForEmptyData() throws {
        let key = try sampleKey()
        let result = try RSA(publicKey: key).encrypt(data: Data())
        XCTAssertEqual(SecKeyGetBlockSize(key), result.count)
    }
    
    func testRsaEncryptRandomization() throws {
        let inputData = Data()
        let rsa = try RSA(publicKey: sampleKey())
        let first = try rsa.encrypt(data: inputData)
        let second = try rsa.encrypt(data: inputData)
        XCTAssertNotEqual(first, second, "even when given same key and input data, output is different")
        try XCTAssertEqual(sampleKey(), sampleKey(), "loaded from same certificates keys are equal")
    }
    func testThrowForInvalidKey() throws {
        let attributes = [
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: 2048,
        ] as CFDictionary
        let key = try XCTUnwrap(SecKeyCreateRandomKey(attributes, nil))
        XCTAssertThrowsError(try RSA(publicKey: key).encrypt(data: Data())) { error in
            let errorDescription = description(error: error)
            XCTAssertTrue(errorDescription
                .hasPrefix("algid:encrypt:RSA:PKCS1: algorithm not supported by the key"),
                          "wrong description: \(errorDescription)"
            )
        }
    }
    func testSampleKeyCanNotDecrypt() throws {
        let key = try sampleKey()
        let data = try RSA(publicKey: key).encrypt(data: Data())
        var error: Unmanaged<CFError>?
        XCTAssertNil(SecKeyCreateDecryptedData(key, .rsaEncryptionPKCS1, data as CFData, &error))
        let failed = try XCTUnwrap(error).takeRetainedValue()
        XCTAssertEqual(description(error: failed), "RSAdecrypt wrong input (err -27)")

    }
    func testSampleKeyIsPublic() throws {
        let key = try sampleKey()
        let attributes = try XCTUnwrap(SecKeyCopyAttributes(key)) as NSDictionary
        XCTAssertTrue(SecKeyIsAlgorithmSupported(key, .decrypt, .rsaEncryptionPKCS1))
        let publicKey = try XCTUnwrap(SecKeyCopyPublicKey(key))
        XCTAssertTrue(SecKeyIsAlgorithmSupported(publicKey, .decrypt, .rsaEncryptionPKCS1))
        let publicKeyAttributes = try XCTUnwrap(SecKeyCopyAttributes(publicKey)) as NSDictionary
        XCTAssertEqual(attributes, publicKeyAttributes)
    }
    func testMaxDataLength() throws {
        let key = try sampleKey()
        let pkcs1Padding = 11
        XCTAssertEqual(SecPadding.PKCS1.rawValue, 1)
        let blockSize = SecKeyGetBlockSize(key)
        XCTAssertEqual(blockSize, 256)
        let maxLength = blockSize - pkcs1Padding
        XCTAssertEqual(maxLength, 245)
        var maxLengthData = Data(repeating: 0, count: maxLength)
        XCTAssertNoThrow(try RSA(publicKey: key).encrypt(data: maxLengthData))
        maxLengthData.append(0)
        XCTAssertThrowsError(try RSA(publicKey: sampleKey()).encrypt(data: maxLengthData)) { error in
            XCTAssertEqual(description(error: error), "RSAencrypt wrong input size (err -23)")
        }
    }
    func sampleKey() throws -> SecKey {
        let certificateUrl = Bundle.module.url(forResource: "keys/example-certificate.cer",
                                               withExtension: nil)!
        
        let data = try Data(contentsOf: certificateUrl)
        let certificate = try XCTUnwrap(SecCertificateCreateWithData(kCFAllocatorDefault, data as CFData))
        return try XCTUnwrap(SecCertificateCopyKey(certificate))
    }
    func description(error: Error) -> String {
        let nsError = error as NSError
        XCTAssertEqual(nsError.domain, NSOSStatusErrorDomain)
        XCTAssertEqual(nsError.code, Int(errSecParam))
        XCTAssertEqual(SecCopyErrorMessageString(OSStatus(nsError.code), nil) as String?,
                       "One or more parameters passed to a function were not valid.")
        let description = nsError.userInfo["NSDescription"] as! String
        return description
    }
}
