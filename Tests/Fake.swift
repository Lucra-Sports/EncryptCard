//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/3/22.
//

import Foundation
import CommonCrypto
import XCTest
@testable import EncryptCard

struct FakeAES: PrivateEncryptor {
    var key: Data = "AES random key that will be RSA encrypted".utf8
    
    let seed: Data = "S".utf8
    
    let encrypted = "A".utf8
    
    func encrypt(data: Data) throws -> Data {
        XCTAssertEqual(String(data: data, encoding: .utf8)!,
                       "ccnumber=4111111111111111&ccexp=10/25&cvv=123",
                       "should be used to encode credit card string")
        return encrypted
    }
}

struct FakeRSA: Encryptor {
    let encrypted = "R".utf8
    
    func encrypt(data: Data) throws -> Data {
        XCTAssertEqual(data, Fake.AES.key, "should encode AES key")
        return encrypted
    }
}

struct Fake {
    static let AES = FakeAES()
    static let createAES = { AES }
    static let RSA = FakeRSA()
}
