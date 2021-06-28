//
//  DownloadSessionManager.swift
//  
//
//  Created by Orest Patlyka on 16.03.2021.
//

import Foundation

public typealias URLSessionDownloadTaskCompletion = (URL?, URLResponse?, Error?) -> Void

public protocol DownloadSessionManager {
    func download(url: URL, completion: @escaping URLSessionDownloadTaskCompletion) -> URLSessionDownloadTask
}

public final class DefaultDownloadSessionManager: DownloadSessionManager {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func download(url: URL, completion: @escaping URLSessionDownloadTaskCompletion) -> URLSessionDownloadTask {
        let task = session.downloadTask(with: url, completionHandler: completion)
        task.resume()
        return task
    }
}
