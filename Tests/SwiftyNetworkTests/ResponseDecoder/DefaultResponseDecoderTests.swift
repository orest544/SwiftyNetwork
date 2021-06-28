//
//  DefaultResponseDecoderTests.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import XCTest
@testable import SwiftyNetwork

final class DefaultResponseDecoderTests: XCTestCase {
    
    func test_decode_useCodingKeys() throws {
        let sut = DefaultResponseDecoder()
        let jsonData = try """
            {
                "identifier": 1,
                "full_name": "Swift"
            }
            """.jsonData()
        let expectedResponse = DummyDecodable(id: 1, fullName: "Swift")
        
        let response: DummyDecodable = try sut.decode(jsonData)
        
        XCTAssertEqual(response, expectedResponse)
    }
}

private struct DummyDecodable: Decodable, Equatable {
    
    let id: Int
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "identifier"
        case fullName = "full_name"
    }
}
