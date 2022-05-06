//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/3/22.
//

import Foundation
import CommonCrypto
import XCTest

struct Fake {
    static let AES_key = "AES random key"
    static let AES_seed = "AES random seed"
    static func randomGenerator(size: Int) -> Data {
        [
            kCCKeySizeAES256: AES_key,
            kCCBlockSizeAES128: AES_seed
        ][size]!.data(using: .ascii)!
    }
    static func AES_encryption(key: Data, seed: Data, data: Data) throws -> String {
        XCTAssertEqual(String(data: key, encoding: .ascii),
                       AES_key)
        XCTAssertEqual(String(data: seed, encoding: .ascii),
                       AES_seed)
        XCTAssertEqual("ccnumber=4111111111111111&ccexp=10/25&cvv=123".data(using: .utf8)!,
                       data,
                       "should encrypt credit card sting")
        return " AES "
    }
    static func RSA_encrypttion(publicKey: SecKey, data: Data) throws -> String {
        XCTAssertTrue("\(publicKey)".hasPrefix("<SecKeyRef algorithm id: 1, key type: RSAPublicKey, version: 4, block size: 2048 bits, exponent: {hex: 10001, decimal: 65537}, modulus: B39EC70DA408066AF7015381370D134EE15A27FEF305728935B7E1E41E3639DEDCCB6A5FBC50F9CB6DB6D794D636C88186ED87DA4DC9A1657FEFC89CF24811ABCE8A22AB8EA8BE5D77D3CAB283C9AA2DD7C87E897C1C8279CC06B3406D27144C15CA6F4CB13D25B82BCDE081EE9C2EBCF0D63EE02BDFA9228A66E1F912728D70C7152CEA54BCF22CF007C7EF482DC01508D0CFE7B989BF15424748CE07820B73DE4DF2F6873E021796539F6329AAE80D61892050C155CA1C62B0D2EFED7D4BF0EF33902CDC003139F376CC55730429A728ADC69CA59E21EABAB3B131B56D93ADCD4E1F20319AE15FA019C02A4DC55F3FD9AA023FC8999D56B0302493DF77E2CD, addr: 0x"),
                      "should be RSA private key from file, actial: \(publicKey)")
        XCTAssertEqual(String(data: data, encoding: .ascii),
                       AES_key)
        return " RSA "
    }

}
