//
//  DefaultDataTransferServiceTests.swift
//  
//
//  Created by Orest Patlyka on 18.02.2021.
//

import XCTest
@testable import SwiftyNetwork

final class DefaultDataTransferServiceTests: XCTestCase {
    func test_request_endpointCreateRequestInvoked() throws {
        let config: NetworkConfig = .dummy
        let sut = makeSUT(config: config)
        let endpoint: SpyEndpoint<DummyResponseDTO> = .init()
        
        try performRequest(endpoint: endpoint, service: sut)
        
        XCTAssertTrue(endpoint.requestCalledSpy)
        XCTAssertEqual(endpoint.requestWithNetworkConfigSpy, config)
    }
    
    func test_requestWithBadRequest_failureCompletion() {
        let sut = makeSUT()
        let endpoint: SpyEndpoint<DummyResponseDTO> = .init(request: nil)
        
        assertRequest(result: .failure(.requestCreationFailure),
                      service: sut,
                      endpoint: endpoint)
    }
    
    func test_request_networkServiceRequest() throws {
        let networkService = SpyNetworkService()
        let sut = makeSUT(networkService: networkService)
        let request: URLRequest = .dummy
        let endpoint: SpyEndpoint<DummyResponseDTO> = .init(request: request)
        
        try performRequest(endpoint: endpoint, service: sut)
        
        XCTAssertTrue(networkService.requestCalledSpy)
        XCTAssertEqual(networkService.requestSpy, request)
    }
    
    func test_requestWithNilData_failureDecoding() {
        let networkService = SpyNetworkService(requestResult: .success(nil))
        let sut = makeSUT(networkService: networkService)
        
        assertRequest(result: .failure(.noData),
                      service: sut,
                      endpoint: .init())
    }
    
    func test_request_successfullyDecoded() {
        let sut = makeSUT()
        let response: DummyResponseDTO = .dummy
        let decoder = SpyResponseDecoder(decodedResponse: response)
        let endpoint: SpyEndpoint<DummyResponseDTO> =
            .init(responseDecoder: decoder)
        
        assertRequest(result: .success(response),
                      service: sut,
                      endpoint: endpoint)
    }
    
    func test_request_decoderError() {
        let sut = makeSUT()
        let errorDescription = DataTransferError
            .decodingFailure(description: "").localizedDescription
        let error: DataTransferError =
            .decodingFailure(description: errorDescription)
        let decoder = SpyResponseDecoder(throwError: error)
        let endpoint: SpyEndpoint<DummyResponseDTO> =
            .init(responseDecoder: decoder)
        
        assertRequest(result: .failure(error),
                      service: sut,
                      endpoint: endpoint)
    }
    
    func test_request_receiveCancellable() throws {
        let expectedCancellable = DummyCancellable()
        let networkService = SpyNetworkService(requestCancellable: expectedCancellable)
        let sut = makeSUT(networkService: networkService)
        let endpoint: SpyEndpoint<DummyResponseDTO> = .init()
        
        let cancellable = try performRequest(endpoint: endpoint, service: sut)
    
        XCTAssertEqual(cancellable, expectedCancellable)
    }
    
    func test_requestWithNetworkError_failureCompletion() {
        let networkError: NetworkError =
            .transportFailure(.init(.cancelled))
        let networkService =
            SpyNetworkService(requestResult: .failure(networkError))
        let sut = makeSUT(networkService: networkService)
        let endpoint: SpyEndpoint<DummyResponseDTO> = .init()
        
        assertRequest(result: .failure(.networkFailure(networkError)),
                      service: sut,
                      endpoint: endpoint)
    }
    
    // MARK: - Void request
    
    func test_requestVoid_endpointCreateRequestInvoked() throws {
        let config: NetworkConfig = .dummy
        let sut = makeSUT(config: config)
        let endpoint: SpyEndpoint<Void> = .init()
        
        try performVoidRequest(endpoint: endpoint, service: sut)

        XCTAssertTrue(endpoint.requestCalledSpy)
        XCTAssertEqual(endpoint.requestWithNetworkConfigSpy, config)
    }
    
    func test_requestVoidWithBadRequest_failureCompletion() throws {
        let sut = makeSUT()
        let endpoint: SpyEndpoint<Void> = .init(request: nil)
        
        assertVoidRequest(failureError: .requestCreationFailure,
                          service: sut,
                          endpoint: endpoint)
    }
    
    func test_requestVoid_networkServiceRequest() throws {
        let networkService = SpyNetworkService()
        let sut = makeSUT(networkService: networkService)
        let request: URLRequest = .dummy
        let endpoint: SpyEndpoint<Void> = .init(request: request)
        
        try performVoidRequest(endpoint: endpoint, service: sut)

        XCTAssertTrue(networkService.requestCalledSpy)
        XCTAssertEqual(networkService.requestSpy, request)
    }
    
    func test_requestVoid_successCompletion() {
        let sut = makeSUT()
        let endpoint: SpyEndpoint<Void> = .init()
        let exp = expectation(description: "success")

        _ = sut.request(with: endpoint) { result in
            guard case .success = result else {
                XCTFail("result should be successful")
                return
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_requestVoid_failureCompletion() {
        let error: NetworkError =
            .transportFailure(.init(.cancelled))
        let networkService = SpyNetworkService(requestResult: .failure(error))
        let sut = makeSUT(networkService: networkService)
        let endpoint: SpyEndpoint<Void> = .init()
        
        assertVoidRequest(failureError: .networkFailure(error),
                          service: sut,
                          endpoint: endpoint)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        config: NetworkConfig = .dummy,
        networkService: NetworkService = SpyNetworkService()
    ) -> DefaultDataTransferService {
        return DefaultDataTransferService(
            config: config,
            networkService: networkService
        )
    }
    
    private func assertRequest(
        result expectedResult: DefaultDataTransferService.CompletionResult<DummyResponseDTO>,
        service: DefaultDataTransferService,
        endpoint: SpyEndpoint<DummyResponseDTO>
    ) {
        let exp = expectation(description: "request result")
        var receivedResult: DefaultDataTransferService
            .CompletionResult<DummyResponseDTO>?
        
        _ = service.request(with: endpoint) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    private func assertVoidRequest(
        failureError expectedError: DataTransferError,
        service: DefaultDataTransferService,
        endpoint: SpyEndpoint<Void>
    ) {
        let exp = expectation(description: "failure")
        var receivedError: DataTransferError?
        
        _ = service.request(with: endpoint) { result in
            guard case .failure(let error) = result else {
                XCTFail("result should be failure")
                return
            }
            receivedError = error
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedError, expectedError)
    }
    
    @discardableResult
    private func performRequest(
        endpoint: SpyEndpoint<DummyResponseDTO>,
        service: DefaultDataTransferService
    ) throws -> DummyCancellable {
        let exp = expectation(description: "request")
        let cancellable = service.request(with: endpoint) { _ in exp.fulfill() }
        waitForExpectations(timeout: 1)
        return try XCTUnwrap(cancellable as? DummyCancellable)
    }
    
    @discardableResult
    private func performVoidRequest(
        endpoint: SpyEndpoint<Void>,
        service: DefaultDataTransferService
    ) throws -> DummyCancellable {
        let exp = expectation(description: "request")
        let cancellable = service.request(with: endpoint) { _ in exp.fulfill() }
        waitForExpectations(timeout: 1)
        return try XCTUnwrap(cancellable as? DummyCancellable)
    }
}

private final class SpyNetworkService: NetworkService {
    var requestCalledSpy = false
    var requestSpy: URLRequest?
    
    private let requestCancellableStub: NetworkCancellable
    private let requestResultStub: CompletionResult
    
    init(requestCancellable: NetworkCancellable = DummyCancellable(),
         requestResult: CompletionResult = .success(.init())) {
        requestCancellableStub = requestCancellable
        requestResultStub = requestResult
    }
    
    func request(_ request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable {
        requestCalledSpy = true
        requestSpy = request
        completion(requestResultStub)
        return requestCancellableStub
    }
}

private final class SpyEndpoint<R>: ResponseRequestable {
    typealias Response = R
    let path: String
    let queries: Encodable?
    let method: HTTPMethod
    let headers: [String: String]
    let body: Encodable?
    let queryEncoder: RequestEncoder
    let bodyEncoder: RequestEncoder
    let responseDecoder: ResponseDecoder
    
    var requestCalledSpy = false
    var requestWithNetworkConfigSpy: NetworkConfig?
    private let requestStub: URLRequest?
    
    init(
        path: String = "",
        queries: Encodable? = nil,
        method: HTTPMethod = .get,
        headers: [String: String] = .init(),
        body: Encodable? = nil,
        queryEncoder: RequestEncoder = SpyRequestEncoder(),
        bodyEncoder: RequestEncoder = SpyRequestEncoder(),
        responseDecoder: ResponseDecoder = SpyResponseDecoder(),
        request: URLRequest? = .dummy
    ) {
        self.path = path
        self.queries = queries
        self.method = method
        self.headers = headers
        self.body = body
        self.queryEncoder = queryEncoder
        self.bodyEncoder = bodyEncoder
        self.responseDecoder = responseDecoder
        requestStub = request
    }
    
    func request(with config: NetworkConfig) -> URLRequest? {
        requestCalledSpy = true
        requestWithNetworkConfigSpy = config
        return requestStub
    }
}
