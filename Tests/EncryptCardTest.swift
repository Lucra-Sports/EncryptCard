//
//  EncryptTest.swift
//  
//
//  Created by Paul Zabelin on 4/30/22.
//

import XCTest
@testable import EncryptCard
import CommonCrypto

class EncryptCardTest: XCTestCase {
    var keyUrl = Bundle.module.url(forResource: "keys/example-payment-gateway-key.txt",
                                   withExtension: nil)!
    func encryptor() throws -> EncryptCard {
        try EncryptCard(
            key: try String(contentsOf: keyUrl)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    let prefix = "GWSC|1|14340".utf8.base64
    
    func testEncryptReturnsDifferentStringsEachTime() throws {
        let encryptor = try encryptor()
        let card = CreditCard(cardNumber: "3541963594572595", expirationDate: "12/20", cvv: "999")
        let encrypted1 = try encryptor.encrypt(creditCard: card)
        let encrypted2 = try encryptor.encrypt(creditCard: card)
        [encrypted1, encrypted2].forEach {
            XCTAssertTrue($0.hasPrefix(prefix), $0)
            XCTAssertEqual($0.count, 596)
        }
        XCTAssertNotEqual(encrypted1, encrypted2)
    }
    
    func testEncryptCreditCard() throws {
        let encryptor = try encryptor()
        encryptor.createPrivateEncryptor = Fake.createAES
        encryptor.publicEncryptor = Fake.RSA
        let card = CreditCard(cardNumber: "4111111111111111", expirationDate: "10/25", cvv: "123")
        let encrypted = try encryptor.encrypt(creditCard: card)
        let data = try XCTUnwrap(Data(base64Encoded: encrypted))
        let decoded = try XCTUnwrap(String(data: data, encoding: .ascii))
        
        let components = decoded.components(separatedBy: "|")
        XCTAssertEqual(6, components.count)
        XCTAssertEqual("GWSC", components[0], "format specifier")
        XCTAssertEqual("1", components[1], "version")
        XCTAssertEqual("14340", components[2], "key id")
        XCTAssertEqual(Fake.RSA.encrypted.base64, components[3])
        XCTAssertEqual(Fake.AES.seed.base64, components[4])
        XCTAssertEqual(Fake.AES.encrypted.base64, components[5])

        XCTAssertEqual(decoded, "GWSC|1|14340|Ug==|Uw==|QQ==",
                       "should be format,version,key id, RSA, base64 encoded seed, AES encrypted data")
    }
    func testSubject() throws {
        XCTAssertEqual(try encryptor().subject, "www.safewebservices.com")
    }

    func testValidKey() throws {
        let encryptor = try encryptor()
        XCTAssertEqual("14340", encryptor.keyId)
        XCTAssertEqual("www.safewebservices.com", encryptor.subject)
        XCTAssertTrue("\(encryptor.publicKey)".contains(
            "SecKeyRef algorithm id: 1, key type: RSAPublicKey, version: 4, block size: 2048 bits"
        ), "should be RSA public key 2048 bits long")
    }
    func testInvalidKey() throws {
        XCTAssertThrowsError(try EncryptCard(key: "invalid"), "should be invalid") { error in
            if case let .invalidKey(message) = error as? EncryptCard.Error {
                XCTAssertEqual(message, "Key is not valid. Should start and end with '***'")
            } else {
                XCTFail("should be invalid key error")
            }
        }
    }
    func testInvalidKeyEncoding() throws {
        XCTAssertThrowsError(try EncryptCard(key: "***123***"), "not base64") { error in
            if case let .invalidKey(message) = error as? EncryptCard.Error {
                XCTAssertEqual(message, "Key is not valid. Should be Base64 encoded")
            } else {
                XCTFail("should be invalid certificate error")
            }
        }
    }
    func testInvalidCertificate() throws {
        XCTAssertThrowsError(try EncryptCard(key: "***QUJD***"), "ABC encoded should be invalid") { error in
            if case .invalidCertificate = error as? EncryptCard.Error {
                return
            } else {
                XCTFail("should be invalid certificate error")
            }
        }
    }
}
