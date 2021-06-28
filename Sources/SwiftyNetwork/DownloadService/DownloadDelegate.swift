//
//  DownloadDelegate.swift
//  
//
//  Created by Orest Patlyka on 22.06.2021.
//

import Foundation

final class DownloadDelegate: NSObject, URLSessionDownloadDelegate {

    var completion: ((URLSessionTask, URL?, URLResponse?, Error?) -> Void)?
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        completion?(downloadTask, location, downloadTask.response, nil)
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        completion?(task, nil, task.response, error)
    }
}
