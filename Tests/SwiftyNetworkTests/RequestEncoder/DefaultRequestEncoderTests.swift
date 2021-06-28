//
//  DefaultRequestEncoderTests.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import XCTest
@testable import Network

final class DefaultRequestEncoderTests: XCTestCase {
    func test_encode_useCodingKeys() throws {
        let sut = DefaultRequestEncoder()
        let encodable = DummyEncodable(id: 1, fullName: "Swift")
        let expectedJSONData = try """
            {"full_name":"Swift","identifier":1}
            """.jsonData()
        
        let encodedData = try sut.encode(encodable)
        
        XCTAssertEqual(encodedData, expectedJSONData)
    }
}

private struct DummyEncodable: Encodable, Equatable {
    let id: Int
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "identifier"
        case fullName = "full_name"
    }
}
