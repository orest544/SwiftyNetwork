//
//  DataTransferService.swift
//  
//
//  Created by Orest Patlyka on 17.02.2021.
//

import Foundation

public enum DataTransferError: Error, Equatable {
    case requestCreationFailure
    case noData
    case decodingFailure(description: String)
    case networkFailure(NetworkError)
}

public protocol DataTransferService {
    typealias CompletionResult<T> = Result<T, DataTransferError>
    typealias CompletionHandler<T> = (CompletionResult<T>) -> Void
    
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void
}

public final class DefaultDataTransferService: DataTransferService {
    
    private let config: NetworkConfig
    private let networkService: NetworkService
    private let logger: DataTransferLogger
    
    public init(config: NetworkConfig,
                networkService: NetworkService = DefaultNetworkService(),
                logger: DataTransferLogger = DefaultDataTransferLogger()) {
        self.config = config
        self.networkService = networkService
        self.logger = logger
    }
    
    public func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T {
        guard let request = endpoint.request(with: config) else {
            completion(.failure(.requestCreationFailure))
            return nil
        }
        return networkService.request(request) { result in
            switch result {
            case .success(let data):
                let decodedResult: CompletionResult<T> =
                    self.decode(data: data, decoder: endpoint.responseDecoder)
                completion(decodedResult)
            case .failure(let error):
                completion(.failure(.networkFailure(error)))
            }
        }
    }
    
    public func request<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void {
        guard let request = endpoint.request(with: config) else {
            completion(.failure(.requestCreationFailure))
            return nil
        }
        return networkService.request(request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(.networkFailure(error)))
            }
        }
    }

    private func decode<T: Decodable>(
        data: Data?,
        decoder: ResponseDecoder
    ) -> CompletionResult<T> {
        do {
            guard let data = data else {
                return .failure(.noData)
            }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            logger.log(decodingError: error)
            return .failure(.decodingFailure(description: error.localizedDescription))
        }
    }
}
