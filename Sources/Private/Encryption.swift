//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/6/22.
//

import Foundation
import CommonCrypto

protocol Encryptor {
    func encrypt(data: Data) throws -> Data
}

extension Encryptor {
    func encrypt(data: Data) throws -> String {
        try encrypt(data: data).base64EncodedString()
    }
    func encrypt(string: String) throws -> String {
        try encrypt(data: string.data(using: .utf8)!)
    }
}

struct RSA {
    let publicKey: SecKey
}

extension RSA: Encryptor {
    func encrypt(data: Data) throws -> Data {
        data
    }
}

protocol PrivateEncryptor: Encryptor {
    var key: Data { get }
    var seed: Data { get }
}
