//
//  EndpointTests.swift
//  
//
//  Created by Orest Patlyka on 18.02.2021.
//

import XCTest
@testable import SwiftyNetwork

final class EndpointTests: XCTestCase {
    func test_endpoint_initialState() {
        let sut = makeSUT()
        
        XCTAssertTrue(hasInitialState(sut))
    }
    
    // MARK: - URL
    
    func test_endpoint_createURL() throws {
        let path: String = .dummyPath
        let sut = makeSUT(path: path)
        let config: NetworkConfig = .dummy
        let expectedURLString =
            "\(config.server.scheme.rawValue)://\(config.server.host)\(path)"
        
        let createdUrl = sut.url(with: config)
        let url = try XCTUnwrap(createdUrl)
        
        XCTAssertEqual(url.absoluteString, expectedURLString)
    }
    
    func test_endpointWithQueries_createURLWithQueryPairs() throws {
        let queries = DummyQueries(firstInt: 1, secondString: "text")
        let queriesJSONData = try """
            {
                "first_int": 1,
                "second_string": "text"
            }
            """.jsonData()
        let encoder = SpyRequestEncoder(encodedData: queriesJSONData)
        let sut = makeSUT(queries: queries, queryEncoder: encoder)
        let firstQuery = "first_int=\(queries.firstInt)"
        let secondQuery = "second_string=\(queries.secondString)"
    
        let createdUrl = sut.url(with: .dummy)
        let url = try XCTUnwrap(createdUrl)

        XCTAssertTrue(encoder.encodeCalledSpy)
        XCTAssertEqual(encoder.encodeModelSpy as? DummyQueries, queries)
        XCTAssertTrue(url.absoluteString.contains(firstQuery))
        XCTAssertTrue(url.absoluteString.contains(secondQuery))
    }
    
    func test_endpointWithBadPath_createdURLIsNil() {
        let sut = makeSUT(path: "without a single forward slash")
        
        let url = sut.url(with: .dummy)
        
        XCTAssertNil(url)
    }
    
    func test_endpointWithBadQueries_urlHasNoQueriesSymbols() throws {
        let queries = DummyQueries()
        let encoder = SpyRequestEncoder(encodingError: NSError.dummy)
        let sut = makeSUT(queries: queries, queryEncoder: encoder)
        let querySymbols = ["?", "&", "="]
        
        let createdUrl = sut.url(with: .dummy)
        let url = try XCTUnwrap(createdUrl)
        
        XCTAssertTrue(encoder.encodeCalledSpy)
        querySymbols.forEach { querySymbol in
            XCTAssertFalse(url.absoluteString.contains(querySymbol))
        }
    }
    
    // MARK: - Request
    
    func test_endpointRequest_withURL() throws {
        let config: NetworkConfig = .dummy
        let sut = makeSUT()
        let urlString =
            "\(config.server.scheme.rawValue)://\(config.server.host)"
        let expectedUrl = try XCTUnwrap(URL(string: urlString))
        
        let request = sut.request(with: .dummy)
        
        XCTAssertEqual(request?.url, expectedUrl)
    }
    
    func test_endpointWithBadPath_requestIsNil() {
        let sut = makeSUT(path: "without a single forward slash")
        
        let request = sut.request(with: .dummy)
        
        XCTAssertNil(request)
    }
    
    func test_endpointRequest_setHTTPMethod() {
        let method: HTTPMethod = .post
        let sut = makeSUT(method: method)
        
        let request = sut.request(with: .dummy)
        
        XCTAssertEqual(request?.httpMethod, method.rawValue)
    }
    
    func test_endpointRequest_setHeaders() {
        let config: NetworkConfig = .dummy
        let headers = ["auth": "token"]
        let sut = makeSUT(headers: headers)
        let allHeaders =
            headers.merging(config.headers) { (_, new) in new }
        
        let request = sut.request(with: .dummy)
        
        XCTAssertEqual(request?.allHTTPHeaderFields, allHeaders)
    }
    
    func test_endpointRequest_encodeAndSetBody() throws {
        let body = DummyBody(name: "Username")
        let bodyJSONData = try """
            {
                "name": "Username"
            }
            """.jsonData()
        let encoder = SpyRequestEncoder(encodedData: bodyJSONData)
        let sut = makeSUT(body: body,
                          bodyEncoder: encoder)
        
        let request = sut.request(with: .dummy)
        
        XCTAssertTrue(encoder.encodeCalledSpy)
        XCTAssertEqual(encoder.encodeModelSpy as? DummyBody, body)
        XCTAssertEqual(request?.httpBody, bodyJSONData)
    }
    
    func test_endpointRequestWithBadBody_requestBodyIsNil() throws {
        let body = DummyBody()
        let encoder = SpyRequestEncoder(encodingError: NSError.dummy)
        let sut = makeSUT(body: body, bodyEncoder: encoder)
        
        let createdRequest = sut.request(with: .dummy)
        let request = try XCTUnwrap(createdRequest)
        
        XCTAssertTrue(encoder.encodeCalledSpy)
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        path: String = "",
        queries: Encodable? = nil,
        method: HTTPMethod = .get,
        headers: [String: String] = .init(),
        body: Encodable? = nil,
        queryEncoder: RequestEncoder = SpyRequestEncoder(),
        bodyEncoder: RequestEncoder = SpyRequestEncoder(),
        responseDecoder: ResponseDecoder = SpyResponseDecoder()
    ) -> Endpoint<Void> {
        let endpoint: Endpoint<Void> = .init(
            path: path,
            queries: queries,
            method: method,
            headers: headers,
            body: body,
            queryEncoder: queryEncoder,
            bodyEncoder: bodyEncoder,
            responseDecoder: responseDecoder
        )
        return endpoint
    }
    
    private func hasInitialState(_ endpoint: Endpoint<Void>) -> Bool {
        return endpoint.path == ""
            && endpoint.queries == nil
            && endpoint.method == .get
            && endpoint.headers == [:]
            && endpoint.body == nil
            && endpoint.queryEncoder is SpyRequestEncoder
            && endpoint.bodyEncoder is SpyRequestEncoder
            && endpoint.responseDecoder is SpyResponseDecoder
    }
}

private struct DummyQueries: Encodable, Equatable {
    var firstInt = 1
    var secondString = "text"
}

private struct DummyBody: Encodable, Equatable {
    var name = "Username"
}

private extension String {
    static var dummyPath: String {
        return "/path/dummy"
    }
}
