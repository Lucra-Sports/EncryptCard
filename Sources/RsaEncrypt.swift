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
