//
//  BackgroundDownloadSessionManager.swift
//  
//
//  Created by Orest Patlyka on 22.06.2021.
//

import Foundation

public final class BackgroundDownloadSessionManager: DownloadSessionManager {
    
    private let session: URLSession
    private var completionHandlers: [URLSessionTask: URLSessionDownloadTaskCompletion] = .init()
    
    public init(identifier: String) {
        let backgroundConfig = URLSessionConfiguration.background(withIdentifier: identifier)
        let downloadDelegate = DownloadDelegate()
        self.session = .init(configuration: backgroundConfig, delegate: downloadDelegate, delegateQueue: nil)
        configureDownloadCompletion(downloadDelegate)
    }
    
    private func configureDownloadCompletion(_ downloadDelegate: DownloadDelegate) {
        downloadDelegate.completion = { [weak self] task, location, response, error in
            self?.completionHandlers[task]?(location, response, error)
            self?.completionHandlers.removeValue(forKey: task)
        }
    }
    
    public func download(url: URL, completion: @escaping URLSessionDownloadTaskCompletion) -> URLSessionDownloadTask {
        let task = session.downloadTask(with: url)
        completionHandlers[task] = completion
        task.resume()
        return task
    }
}
