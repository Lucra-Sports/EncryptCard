//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/3/22.
//

import Foundation

enum FunctionType {
    typealias RSA = (_ publicKey: SecKey, _ data: Data) throws -> String
    typealias AES = (_ key: Data, _ seed: Data, _ data: Data) throws -> String
    typealias SecureRandom = (_ size: Int) -> Data
}
