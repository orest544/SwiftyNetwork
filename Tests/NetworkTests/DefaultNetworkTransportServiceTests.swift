//
//  DefaultNetworkTransportServiceTests.swift
//  
//
//  Created by Orest Patlyka on 17.02.2021.
//

import XCTest
@testable import Network

final class DefaultNetworkTransportServiceTests: XCTestCase {
    
    func test_request_sessionRequestInvoked() throws {
        let expectedCancellable = DummyCancellable()
        let request: URLRequest = .dummy
        let (sut, session) = makeSUT(cancellable: expectedCancellable)
        
        let cancellable = sut.request(request) { _ in }
        let receivedCancellable = try XCTUnwrap(cancellable as? DummyCancellable)
        
        XCTAssertTrue(session.requestCalledSpy)
        XCTAssertEqual(session.requestSpy, request)
        XCTAssertEqual(receivedCancellable, expectedCancellable)
    }
    
    func test_requestWithError_failureCompletion() {
        let error = URLError(.cancelled)
        let sut = makeSUT(error: error).service
        
        assertRequest(result: .failure(.init(.cancelled)),
                      service: sut)
    }
    
    func test_requestWithNilResponse_failureCompletionWithBadResponseError() {
        let sut = makeSUT(response: nil).service
        
        assertRequest(result: .failure(.init(.badServerResponse)),
                      service: sut)
    }
    
    func test_request_successCompletion() {
        let response: NetworkTransportResponse = .init(
            data: .init(),
            httpResponse: .init()
        )
        let sut = makeSUT(response: response.httpResponse,
                          data: response.data).service
        
        assertRequest(result: .success(response), service: sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        cancellable: NetworkCancellable = DummyCancellable(),
        error: Error? = nil,
        response: URLResponse? = nil,
        data: Data? = nil
    ) -> (service: DefaultNetworkTransportService, session: SpyNetworkSessionManager) {
        let sessionManager = SpyNetworkSessionManager(
            requestCancellable: cancellable,
            completionData: data,
            completionResponse: response,
            completionError: error
        )
        let service = DefaultNetworkTransportService(sessionManager: sessionManager)
        return (service, sessionManager)
    }
    
    private func assertRequest(
        result expectedResult: NetworkTransportService.CompletionResult,
        service: DefaultNetworkTransportService
    ) {
        let exp = expectation(description: "result")
        var receivedResult: NetworkTransportService.CompletionResult?
        
        _ = service.request(.dummy) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedResult, expectedResult)
    }
}

private final class SpyNetworkSessionManager: NetworkSessionManager {
    
    var requestCalledSpy = false
    var requestSpy: URLRequest?

    private let requestCancellableStub: NetworkCancellable
    private let completionResponseStub: URLResponse?
    private let completionDataStub: Data?
    private let completionErrorStub: Error?
    
    init(requestCancellable: NetworkCancellable,
         completionData: Data?,
         completionResponse: URLResponse?,
         completionError: Error?) {
        requestCancellableStub = requestCancellable
        completionErrorStub = completionError
        completionResponseStub = completionResponse
        completionDataStub = completionData
    }
    
    func request(_ request: URLRequest,
                 completion: @escaping URLSessionDataTaskCompletion) -> NetworkCancellable {
        requestCalledSpy = true
        requestSpy = request
        completion(completionDataStub, completionResponseStub, completionErrorStub)
        return requestCancellableStub
    }
}
