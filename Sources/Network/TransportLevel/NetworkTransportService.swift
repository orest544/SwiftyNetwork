//
//  NetworkTransportService.swift
//  
//
//  Created by Orest Patlyka on 16.02.2021.
//

import Foundation

public protocol NetworkTransportService {
    typealias CompletionResult = Result<NetworkTransportResponse, URLError>
    typealias CompletionHandler = (CompletionResult) -> Void
    func request(_ request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable
}

public final class DefaultNetworkTransportService: NetworkTransportService {
    private let sessionManager: NetworkSessionManager
    
    public init(sessionManager: NetworkSessionManager = DefaultNetworkSessionManager()) {
        self.sessionManager = sessionManager
    }
    
    public func request(_ request: URLRequest,
                        completion: @escaping CompletionHandler) -> NetworkCancellable {
        let responseHandler: URLSessionDataTaskCompletion = { data, response, error in
            if let error = error {
                completion(.failure(.make(with: error)))
                return
            }
            
            guard let httpResponse = response?.httpResponse else {
                completion(.failure(.init(.badServerResponse)))
                return
            }
            
            let response: NetworkTransportResponse = .init(
                data: data,
                httpResponse: httpResponse
            )
            completion(.success(response))
        }
        
        let sessionDataTask = sessionManager.request(request, completion: responseHandler)
        return sessionDataTask
    }
}

private extension URLResponse {
    var httpResponse: HTTPURLResponse? {
        return self as? HTTPURLResponse
    }
}
