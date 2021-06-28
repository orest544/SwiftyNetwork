//
//  DownloadService.swift
//  
//
//  Created by Orest Patlyka on 16.03.2021.
//

import Foundation

public protocol DownloadService {
    typealias DownloadResult = Result<URL, URLError>
    
    @discardableResult
    func download(url: URL, completion: @escaping (DownloadResult) -> Void) -> URLSessionDownloadTask
}

public final class DefaultDownloadService: DownloadService {
    private let sessionManager: DownloadSessionManager
    
    public init(sessionManager: DownloadSessionManager = DefaultDownloadSessionManager()) {
        self.sessionManager = sessionManager
    }
    
    @discardableResult
    public func download(url: URL, completion: @escaping (DownloadResult) -> Void) -> URLSessionDownloadTask {
        return sessionManager.download(url: url) { (downloadedFileURL, _, error) in
            if let error = error {
                completion(.failure(.make(with: error)))
                return
            }
            
            guard let downloadedFileURL = downloadedFileURL else {
                completion(.failure(.init(.badServerResponse)))
                return
            }
            
            completion(.success(downloadedFileURL))
        }
    }
}
