//
//  File.swift
//  
//
//  Created by Paul Zabelin on 5/3/22.
//

import Foundation

func secureRandom(size: Int) -> Data {
    Data((0..<size).map { _ in UInt8.random(in:UInt8.min...UInt8.max) })
}
