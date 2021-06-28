//
//  DefaultDownloadSessionManagerTests.swift
//  
//
//  Created by Orest Patlyka on 29.03.2021.
//

import Foundation
import XCTest
import Network

final class DefaultDownloadSessionManagerTests: XCTestCase {
    
    func test_downloadWithURL_sessionDownloadTaskWithThisURL() {
        let url: URL = .dummy
        let session = SpySession()
        let sut = makeSUT(session: session)
        
        _ = sut.download(url: url, completion: { _, _, _  in })
        
        XCTAssertEqual(session.spyDownloadTaskURL, url)
    }
    
    func test_download_receiveCompletion() throws {
        let completion = StubSession.CompletionStub(
            url: .dummy,
            response: .init(),
            error: .init(.unknown)
        )
        let task = SpyDownloadTask()
        let session = StubSession(
            completion: completion,
            task: task
        )
        let sut = makeSUT(session: session)
        let exp = expectation(description: "download completion")
        var receivedCompletion: StubSession.CompletionStub?
        
        let receivedTask = sut.download(url: .dummy) {
            receivedCompletion = .init(
                url: $0,
                response: $1,
                error: $2 as? URLError
            )
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedCompletion, completion)
        let receivedSpyTask = try XCTUnwrap(receivedTask as? SpyDownloadTask)
        XCTAssertEqual(receivedSpyTask, task)
    }
    
    func test_download_taskResume() throws {
        let sut = makeSUT(session: StubSession(task: SpyDownloadTask()))
        
        let task = sut.download(url: .dummy, completion: { _, _, _ in })
        
        let receivedTask = try XCTUnwrap(task as? SpyDownloadTask)
        XCTAssertTrue(receivedTask.spyResumeInvoked)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        session: URLSession = SpySession()
    ) -> DefaultDownloadSessionManager {
        return DefaultDownloadSessionManager(session: session)
    }
}

private final class SpyDownloadTask: URLSessionDownloadTask {
    
    var spyResumeInvoked = false
    
    override init() { }
    
    override func resume() {
        spyResumeInvoked = true
    }
}

private final class SpySession: URLSession {
    
    var spyDownloadTaskURL: URL?
    
    override init() { }
    
    override func downloadTask(
        with url: URL,
        completionHandler: @escaping URLSessionDownloadTaskCompletion
    ) -> URLSessionDownloadTask {
        spyDownloadTaskURL = url
        return SpyDownloadTask()
    }
}

private final class StubSession: URLSession {
    
    private let completionStub: CompletionStub?
    private let stubTask: URLSessionDownloadTask
    
    struct CompletionStub: Equatable {
        let url: URL?
        let response: URLResponse?
        let error: URLError?
    }
    
    init(completion: CompletionStub? = nil,
         task: URLSessionDownloadTask) {
        self.completionStub = completion
        self.stubTask = task
    }
    
    override func downloadTask(
        with url: URL,
        completionHandler: @escaping URLSessionDownloadTaskCompletion
    ) -> URLSessionDownloadTask {
        completionHandler(completionStub?.url,
                          completionStub?.response,
                          completionStub?.error)
        return stubTask
    }
}
