//
//  NetworkSessionManager.swift
//  
//
//  Created by Orest Patlyka on 16.02.2021.
//

import Foundation

public typealias URLSessionDataTaskCompletion = (Data?, URLResponse?, Error?) -> Void

public protocol NetworkSessionManager {
    func request(_ request: URLRequest,
                 completion: @escaping URLSessionDataTaskCompletion) -> NetworkCancellable
}

public final class DefaultNetworkSessionManager: NetworkSessionManager {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func request(_ request: URLRequest,
                        completion: @escaping URLSessionDataTaskCompletion) -> NetworkCancellable {
        let task = session.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
}
