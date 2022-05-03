//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import Foundation

func rsaEncrypt(publicKey: SecKey, data: Data) throws -> String {
    var error: Unmanaged<CFError>?
    let result = SecKeyCreateEncryptedData(
        publicKey,
        .rsaEncryptionPKCS1,
        data as CFData,
        &error)
    if let failedToEncrypt = error?.takeRetainedValue() {
        throw failedToEncrypt
    }
    return (result! as Data).base64EncodedString()
}

func secureRandom(size: Int) -> Data {
    Data((0..<size).map { _ in UInt8.random(in:UInt8.min...UInt8.max) })
}
