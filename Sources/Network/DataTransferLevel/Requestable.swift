//
//  Requestable.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import Foundation

public protocol Requestable {
    var path: String { get }
    var queries: Encodable? { get }
    var queryEncoder: RequestEncoder { get }
    
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Encodable? { get }
    var bodyEncoder: RequestEncoder { get }
    
    func url(with config: NetworkConfig) -> URL?
    func request(with config: NetworkConfig) -> URLRequest?
}

extension Requestable {
    public func url(with config: NetworkConfig) -> URL? {
        var components = URLComponents()
        components.scheme = config.server.scheme.rawValue
        components.host = config.server.host
        components.path = path
        if let queries = queries {
            components.setQueries(queries, encoder: queryEncoder)
        }
        return components.url
    }

    public func request(with config: NetworkConfig) -> URLRequest? {
        guard let url = url(with: config) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setHeaders(config.headers)
        request.setHeaders(headers)
        request.httpBody = body?.toData(using: bodyEncoder)
        return request
    }
}

// MARK: - Helpers

private extension URLRequest {
    mutating func setHeaders(_ headers: [String: String]) {
        headers.forEach {
            setValue($0.value, forHTTPHeaderField: $0.key)
        }
    }
}

private extension URLComponents {
    mutating func setQueries(_ queries: Encodable, encoder: RequestEncoder) {
        guard let queriesDict = queries.toDictionary(using: encoder) else {
            return
        }
        queryItems = queriesDict.map {
            URLQueryItem(name: $0.key, value: "\($0.value)")
        }
    }
}

private extension Encodable {
    func toDictionary(using encoder: RequestEncoder) -> [String: Any]? {
        let json = try? JSONSerialization.jsonObject(
            with: encoder.encode(self)
        )
        return json as? [String: Any]
    }
}

private extension Encodable {
    func toData(using encoder: RequestEncoder) -> Data? {
        return try? encoder.encode(self)
    }
}
