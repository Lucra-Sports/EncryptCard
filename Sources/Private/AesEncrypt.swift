//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/2/22.
//

import Foundation
import CommonCrypto

func aesEncrypt(key: Data, seed: Data, data: Data) throws -> String {
    let padLength = kCCBlockSizeAES128
    var resultLength: size_t = 0
    var result = Data(repeating: .zero, count: data.count + padLength)
    let error = result.withUnsafeMutableBytes { buffer  in
        seed.withUnsafeBytes { seedBytes in
            key.withUnsafeBytes { keyBytes in
                data.withUnsafeBytes { stringBuffer in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionPKCS7Padding),
                        keyBytes.baseAddress, key.count,
                        seedBytes.baseAddress,
                        stringBuffer.baseAddress, data.count,
                        buffer.baseAddress, buffer.count,
                        &resultLength
                    )
                }
            }
        }
    }
    guard error == kCCSuccess else {
        throw NSError(domain: NSOSStatusErrorDomain, code: Int(error))
    }
    return result[0..<resultLength].base64EncodedString()
}

