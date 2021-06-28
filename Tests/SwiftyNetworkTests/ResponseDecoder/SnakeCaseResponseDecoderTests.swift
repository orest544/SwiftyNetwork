//
//  SnakeCaseResponseDecoderTests.swift
//  
//
//  Created by Orest Patlyka on 18.02.2021.
//

import XCTest
@testable import SwiftyNetwork

final class SnakeCaseResponseDecoderTests: XCTestCase {
    func test_decode_snakeCaseToCamel() throws {
        let sut = SnakeCaseResponseDecoder()
        let jsonData = try """
            {
                "id": 1,
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
}
