//
//  NetworkService.swift
//  
//
//  Created by Orest Patlyka on 17.02.2021.
//

import Foundation

public protocol NetworkService {
    typealias CompletionResult = Result<Data?, NetworkError>
    typealias CompletionHandler = (CompletionResult) -> Void
    func request(_ request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable
}

public final class DefaultNetworkService: NetworkService {
    private let transportService: NetworkTransportService
    private let logger: NetworkLogger
    
    public init(
        transportService: NetworkTransportService = DefaultNetworkTransportService(),
        logger: NetworkLogger = DefaultNetworkLogger()
    ) {
        self.transportService = transportService
        self.logger = logger
    }
    
    public func request(_ request: URLRequest,
                        completion: @escaping CompletionHandler) -> NetworkCancellable {
        logger.log(request: request)
        return transportService.request(request) { transportResult in
            switch transportResult {
            case .success(let response):
                self.logger.log(
                    response: response.httpResponse,
                    data: response.data,
                    for: request
                )
                if let error = self.validateStatusCode(in: response) {
                    completion(.failure(error))
                    return
                }
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(.transportFailure(error)))
            }
        }
    }
    
    private func validateStatusCode(in response: NetworkTransportResponse) -> NetworkError? {
        let statusCode = response.httpResponse.statusCode
        if withinSuccessRange(statusCode: statusCode) {
            return nil
        }
        return .serverSideFailure(statusCode: statusCode, data: response.data)
    }
    
    private func withinSuccessRange(statusCode: Int) -> Bool {
        return HTTPURLResponse.successStatusCodes.contains(statusCode)
    }
}

private extension HTTPURLResponse {
    static let successStatusCodes = 200...299
}
