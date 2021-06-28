//
//  SpyRequestEncoder.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import Foundation
@testable import Network

final class SpyRequestEncoder: RequestEncoder {
    var encodeCalledSpy = false
    var encodeModelSpy: Any?
    
    private let encodedDataStub: Data
    private let encodingErrorStub: Error?
    
    init(encodedData: Data = .init(),
         encodingError: Error? = nil) {
        encodedDataStub = encodedData
        encodingErrorStub = encodingError
    }
    
    func encode<T>(_ model: T) throws -> Data where T: Encodable {
        encodeCalledSpy = true
        encodeModelSpy = model
        if let error = encodingErrorStub {
            throw error
        }
        return encodedDataStub
    }
}
