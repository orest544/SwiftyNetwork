//
//  SpyResponseDecoder.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import Foundation
@testable import SwiftyNetwork

final class SpyResponseDecoder: ResponseDecoder {
    
    var decodeCalledSpy = false
    var decodeDataSpy: Data?
    private let decodedResponseStub: DummyResponseDTO
    private let throwErrorStub: Error?
    
    init(decodedResponse: DummyResponseDTO = .dummy,
         throwError: Error? = nil) {
        decodedResponseStub = decodedResponse
        throwErrorStub = throwError
    }
    
    func decode<T>(_ data: Data) throws -> T {
        decodeCalledSpy = true
        decodeDataSpy = data
        if let error = throwErrorStub {
            throw error
        }
        guard let response = decodedResponseStub as? T else {
            throw NSError.dummy
        }
        return response
    }
}

struct DummyResponseDTO: Decodable, Equatable {
    let id: Int
    
    static var dummy: DummyResponseDTO {
        return .init(id: 1)
    }
}
