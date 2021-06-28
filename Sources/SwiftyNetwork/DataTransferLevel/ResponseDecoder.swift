//
//  ResponseDecoder.swift
//  
//
//  Created by Orest Patlyka on 18.02.2021.
//

import Foundation

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

public struct DefaultResponseDecoder: ResponseDecoder {
    public init() { }
    
    private let decoder: JSONDecoder = .init()
    
    public func decode<T>(_ data: Data) throws -> T where T: Decodable {
        return try decoder.decode(T.self, from: data)
    }
}

public struct SnakeCaseResponseDecoder: ResponseDecoder {
    public init() { }
    
    private let decoder: JSONDecoder = .makeSnakeCaseDecoder()
    
    public func decode<T>(_ data: Data) throws -> T where T: Decodable {
        return try decoder.decode(T.self, from: data)
    }
}
