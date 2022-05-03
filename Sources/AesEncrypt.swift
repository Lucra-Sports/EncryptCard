//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import Foundation
import CommonCrypto

func aesEncrypt(key: Data, seed: Data, string: String) throws -> String {
    let padLength = kCCBlockSizeAES128
    var result = Data(repeating: .zero, count: string.count + padLength)
    var resultLength: size_t = 0
    let error = result.withUnsafeMutableBytes { buffer  in
        CCCrypt(
            CCOperation(kCCEncrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            key.bytes, key.count,
            seed.bytes,
            string.bytes, string.count,
            buffer.baseAddress!, buffer.count,
            &resultLength
        )
    }
    guard error == kCCSuccess else {
        throw NSError(domain: NSOSStatusErrorDomain, code: Int(error))
    }
    return result[0..<resultLength].base64EncodedString()
}

