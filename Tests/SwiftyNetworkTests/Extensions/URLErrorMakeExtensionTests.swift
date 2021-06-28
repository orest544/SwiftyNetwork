//
//  URLErrorMakeExtensionTests.swift
//  
//
//  Created by Orest Patlyka on 29.03.2021.
//

import XCTest
@testable import Network

final class URLErrorMakeExtensionTests: XCTestCase {
    func test_makeTypeErasedURLError_madeURLError() throws {
        let error: Error = URLError(.cancelled)
        let sut = makeSUT(error: error)
        
        let expectedError = try XCTUnwrap(error as? URLError)
        XCTAssertEqual(sut, expectedError)
    }
    
    func test_makeWithWrongType_madeUnknownURLError() {
        let sut = makeSUT(error: NSError())
        let expectedError = URLError(.unknown)
        
        XCTAssertEqual(sut, expectedError)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(error: Error) -> URLError {
        return .make(with: error)
    }
}
