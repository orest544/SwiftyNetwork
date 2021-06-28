//
//  Endpoint.swift
//
//
//  Created by Orest Patlyka on 17.02.2021.
//

import Foundation

public protocol ResponseRequestable: Requestable {
    associatedtype Response
    
    var responseDecoder: ResponseDecoder { get }
}

public final class Endpoint<R>: ResponseRequestable {
    
    public typealias Response = R
    
    public let path: String
    public let queries: Encodable?
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Encodable?
    
    public let queryEncoder: RequestEncoder
    public let bodyEncoder: RequestEncoder
    public let responseDecoder: ResponseDecoder
    
    public init(
        path: String,
        queries: Encodable? = nil,
        method: HTTPMethod,
        headers: [String: String] = .init(),
        body: Encodable? = nil,
        queryEncoder: RequestEncoder = SnakeCaseRequestEncoder(),
        bodyEncoder: RequestEncoder = SnakeCaseRequestEncoder(),
        responseDecoder: ResponseDecoder = SnakeCaseResponseDecoder()
    ) {
        self.path = path
        self.queries = queries
        self.method = method
        self.headers = headers
        self.body = body
        self.queryEncoder = queryEncoder
        self.bodyEncoder = bodyEncoder
        self.responseDecoder = responseDecoder
    }
}
