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
    var keyUrl = Bundle.module.url(forResource: "example-payment-gateway-key.txt",
                                   withExtension: nil)!
    func encryptor() throws -> EncryptCard {
        try EncryptCard(
            key: try String(contentsOf: keyUrl)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    static let fakeAES_key = "AES random key"
    static let fakeAES_seed = "AES random seed"
    func fakeRandomGenerator(size: Int) -> Data {
        [
            kCCKeySizeAES256: Self.fakeAES_key,
            kCCBlockSizeAES128: Self.fakeAES_seed
        ][size]!.data(using: .ascii)!
    }
    func fakeAES_encryption(key: Data, seed: Data, inputString: String) throws -> String {
        XCTAssertEqual(String(data: key, encoding: .ascii),
                       Self.fakeAES_key)
        XCTAssertEqual(String(data: seed, encoding: .ascii),
                       Self.fakeAES_seed)
        XCTAssertEqual("ccnumber=4111111111111111&ccexp=10/25&cvv=123", inputString,
                       "should encrypt credit card sting")
        return " AES "
    }
    func fakeRSA_encrypttion(publicKey: SecKey, data: Data) throws -> String {
        XCTAssertTrue("\(publicKey)".hasPrefix("<SecKeyRef algorithm id: 1, key type: RSAPublicKey, version: 4, block size: 2048 bits, exponent: {hex: 10001, decimal: 65537}, modulus: B39EC70DA408066AF7015381370D134EE15A27FEF305728935B7E1E41E3639DEDCCB6A5FBC50F9CB6DB6D794D636C88186ED87DA4DC9A1657FEFC89CF24811ABCE8A22AB8EA8BE5D77D3CAB283C9AA2DD7C87E897C1C8279CC06B3406D27144C15CA6F4CB13D25B82BCDE081EE9C2EBCF0D63EE02BDFA9228A66E1F912728D70C7152CEA54BCF22CF007C7EF482DC01508D0CFE7B989BF15424748CE07820B73DE4DF2F6873E021796539F6329AAE80D61892050C155CA1C62B0D2EFED7D4BF0EF33902CDC003139F376CC55730429A728ADC69CA59E21EABAB3B131B56D93ADCD4E1F20319AE15FA019C02A4DC55F3FD9AA023FC8999D56B0302493DF77E2CD, addr: 0x"),
                      "should be RSA private key from file, actial: \(publicKey)")
        XCTAssertEqual(String(data: data, encoding: .ascii),
                       Self.fakeAES_key)
        return " RSA "
    }
    func testEncryptCreditCard() throws {
        let encryptor = try encryptor()
        encryptor.randomFunction = fakeRandomGenerator
        encryptor.aesEncryptFunction = fakeAES_encryption
        encryptor.rsaEncryptFunction = fakeRSA_encrypttion
        let card = CreditCard(cardNumber: "4111111111111111", expirationDate: "10/25", cvv: "123")
        let encrypted = try encryptor.encrypt(creditCard: card)
        let data = try XCTUnwrap(Data(base64Encoded: encrypted))
        let decoded = try XCTUnwrap(String(data: data, encoding: .ascii))
        XCTAssertEqual(decoded, "GWSC|1|14340| RSA |QUVTIHJhbmRvbSBzZWVk| AES ",
                       "should be format,version,key id, RSA, base64 encoded seed, AES encrypted data")
        
        let components = decoded.components(separatedBy: "|")
        XCTAssertEqual(6, components.count)
        XCTAssertEqual("GWSC", components[0], "format specifier")
        XCTAssertEqual("1", components[1], "version")
        XCTAssertEqual("14340", components[2], "key id")
        XCTAssertEqual(" RSA ", components[3], "RSA encrypted string")
        let seedData = try XCTUnwrap(Data(base64Encoded: components[4]))
        XCTAssertEqual(String(data: seedData, encoding: .ascii),
                       Self.fakeAES_seed)
        XCTAssertEqual(" AES ", components[5], "AES encrypted string")
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
    func testInvalidCertificate() throws {
        XCTAssertThrowsError(try EncryptCard(key: "***123***"), "should be invalid") { error in
            if case .invalidCertificate = error as? EncryptCard.Error {
                return
            } else {
                XCTFail("should be invalid certificate error")
            }
        }
    }
}
