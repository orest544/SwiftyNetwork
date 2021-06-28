//
//  RequestEncoder.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import Foundation

public protocol RequestEncoder {
    func encode<T: Encodable>(_ model: T) throws -> Data
}

public struct DefaultRequestEncoder: RequestEncoder {
    
    public init() { }
    
    private let encoder: JSONEncoder = .init()
    
    public func encode<T>(_ model: T) throws -> Data where T: Encodable {
        return try encoder.encode(model)
    }
}

public struct SnakeCaseRequestEncoder: RequestEncoder {
    
    public init() { }
    
    private let encoder: JSONEncoder = .makeSnakeCaseEncoder()
    
    public func encode<T>(_ model: T) throws -> Data where T: Encodable {
        return try encoder.encode(model)
    }
}
