//
//  DefaultNetworkServiceTests.swift
//  
//
//  Created by Orest Patlyka on 18.02.2021.
//

import XCTest
@testable import SwiftyNetwork

final class DefaultNetworkServiceTests: XCTestCase {
    func test_request_transportServiceRequestInvoked() throws {
        let request: URLRequest = .dummy
        let expectedCancellable = DummyCancellable()
        let (sut, transport) = makeSUT(cancellable: expectedCancellable)
        
        let cancellable = sut.request(request) { _ in }
        let receivedCancellable = try XCTUnwrap(cancellable as? DummyCancellable)
        
        XCTAssertTrue(transport.requestCalledSpy)
        XCTAssertEqual(transport.requestSpy, request)
        XCTAssertEqual(receivedCancellable, expectedCancellable)
    }
    
    func test_requestWithData_successCompletionWithData() {
        let response: NetworkTransportResponse = .dummy
        let expectedResult: NetworkService.CompletionResult =
            .success(response.data)
        let sut = makeSUT(result: .success(response)).network
        
        assertRequest(result: expectedResult, service: sut)
    }
    
    func test_requestWithNotValidStatusCode_failureCompletionWithServerSideError() {
        let response: NetworkTransportResponse = .init(
            data: .init(),
            httpResponse: .make(withStatusCode: 500)
        )
        let expectedResult: NetworkService.CompletionResult =
            .failure(.serverSideFailure(
                statusCode: response.httpResponse.statusCode,
                data: response.data
            ))
        let sut = makeSUT(result: .success(response)).network
        
        assertRequest(result: expectedResult, service: sut)
    }
    
    func test_requestWithTransportError_transportFailureCompletion() {
        let transportError: URLError = .init(.cancelled)
        let expectedResult: NetworkService.CompletionResult =
            .failure(.transportFailure(transportError))
        let sut = makeSUT(result: .failure(transportError)).network
        
        assertRequest(result: expectedResult, service: sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        cancellable: NetworkCancellable = DummyCancellable(),
        result: NetworkTransportService.CompletionResult = .success(.dummy)
    ) -> (network: DefaultNetworkService,
          transport: SpyNetworkTransportService) {
        let transportService = SpyNetworkTransportService(
            requestCancellable: cancellable,
            requestResult: result
        )
        let networkService = DefaultNetworkService(transportService: transportService)
        
        return (networkService, transportService)
    }
    
    private func assertRequest(
        result expectedResult: NetworkService.CompletionResult,
        service: DefaultNetworkService
    ) {
        let exp = expectation(description: "result")
        var receivedResult: NetworkService.CompletionResult?
        
        _ = service.request(.dummy) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedResult, expectedResult)
    }
}

private final class SpyNetworkTransportService: NetworkTransportService {
    var requestCalledSpy = false
    var requestSpy: URLRequest?
    
    private let requestCancellableStub: NetworkCancellable
    private let requestResultStub: CompletionResult
    
    init(requestCancellable: NetworkCancellable,
         requestResult: CompletionResult) {
        requestCancellableStub = requestCancellable
        requestResultStub = requestResult
    }
    
    func request(_ request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        requestCalledSpy = true
        requestSpy = request
        completion(requestResultStub)
        return requestCancellableStub
    }
}

private extension NetworkTransportResponse {
    static var dummy: NetworkTransportResponse {
        return .init(data: .init(), httpResponse: .make(withStatusCode: 200))
    }
}

private extension HTTPURLResponse {
    static func make(withStatusCode statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse.init(statusCode: statusCode) ?? .init()
    }
    
    convenience init?(statusCode: Int) {
        self.init(url: .dummy,
                  statusCode: statusCode,
                  httpVersion: nil,
                  headerFields: nil)
    }
}
