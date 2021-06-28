//
//  DefaultDownloadServiceTests.swift
//  
//
//  Created by Orest Patlyka on 29.03.2021.
//

import XCTest
import Network

final class DefaultDownloadServiceTests: XCTestCase {
    func test_downloadWithURL_sessionManagerDownloadWithThisURL() {
        let url: URL = .dummy
        let sessionManager = SpyDownloadSessionManager()
        let sut = makeSUT(sessionManager: sessionManager)
        
        sut.download(url: url, completion: { _ in })
        
        XCTAssertEqual(sessionManager.spyDownloadURL, url)
    }
    
    func test_download_receiveDownloadTask() throws {
        let task = DummyDownloadTask()
        let sut = makeSUT(sessionManager: StubDownloadSessionManager(task: task))
        
        let receivedTask = sut.download(url: .dummy, completion: { _ in })
        
        let receivedDummyTask = try XCTUnwrap(receivedTask as? DummyDownloadTask)
        XCTAssertEqual(receivedDummyTask, task)
    }
    
    func test_downloadError_urlErrorFailure() {
        let error = URLError(.cancelled)
        let sut = makeSUT(sessionManager: StubDownloadSessionManager(error: error))
        
        assertResult(.failure(error), service: sut)
    }
    
    func test_downloadedFileNil_badResponseFailure() {
        let sut = makeSUT(sessionManager: StubDownloadSessionManager(url: nil))
        
        assertResult(.failure(.init(.badServerResponse)),
                     service: sut)
    }
    
    func test_download_successCompletion() {
        let fileURL: URL = .dummy
        let sut = makeSUT(sessionManager: StubDownloadSessionManager(url: fileURL))
        
        assertResult(.success(fileURL), service: sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        sessionManager: DownloadSessionManager = SpyDownloadSessionManager()
    ) -> DefaultDownloadService {
        return DefaultDownloadService(sessionManager: sessionManager)
    }
    
    private func assertResult(
        _ expectedResult: DownloadService.DownloadResult,
        service: DefaultDownloadService
    ) {
        var receivedResult: DownloadService.DownloadResult?
        let exp = expectation(description: "completion")
        
        service.download(url: .dummy) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedResult, expectedResult)
    }
}

private final class SpyDownloadSessionManager: DownloadSessionManager {
    var spyDownloadURL: URL?
    
    func download(url: URL, completion: @escaping URLSessionDownloadTaskCompletion) -> URLSessionDownloadTask {
        spyDownloadURL = url
        return DummyDownloadTask()
    }
}

private final class StubDownloadSessionManager: DownloadSessionManager {
    private let stubTask: URLSessionDownloadTask
    private let stubError: Error?
    private let stubURL: URL?
    
    init(
        task: URLSessionDownloadTask = DummyDownloadTask(),
        error: Error? = nil,
        url: URL? = nil
    ) {
        self.stubTask = task
        self.stubError = error
        self.stubURL = url
    }
    
    func download(url: URL, completion: @escaping URLSessionDownloadTaskCompletion) -> URLSessionDownloadTask {
        completion(stubURL, nil, stubError)
        return stubTask
    }
}

private final class DummyDownloadTask: URLSessionDownloadTask {
    override init() { }
}
