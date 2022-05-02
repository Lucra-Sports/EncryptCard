//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import Foundation

func rsaEncrypt(publicKey: SecKey, data: Data) throws -> String {
    var error: Unmanaged<CFError>?
    if let result = SecKeyCreateEncryptedData(
        publicKey,
        .rsaEncryptionPKCS1,
        data as CFData,
        &error) {
        return (result as Data).base64EncodedString()
    } else {
        if let error = error?.takeRetainedValue() {
            throw error as Swift.Error
        }
        throw EncryptCard.Error.failedToEncrypt
    }
}
