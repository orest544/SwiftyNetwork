//
//  SnakeCaseRequestEncoderTests.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import XCTest
@testable import Network

final class SnakeCaseRequestEncoderTests: XCTestCase {
    func test_encode_camelToSnakeCase() throws {
        let sut = SnakeCaseRequestEncoder()
        let encodable = DummyEncodable(id: 1, fullName: "Swift")
        let expectedJSONData = try """
            {"id":1,"full_name":"Swift"}
            """.jsonData()
        
        let encodedData = try sut.encode(encodable)
        
        XCTAssertEqual(encodedData, expectedJSONData)
    }
}

private struct DummyEncodable: Encodable, Equatable {
    let id: Int
    let fullName: String
}
