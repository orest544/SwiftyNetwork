import XCTest
@testable import SwiftyNetwork

final class ConfigurationsTests: XCTestCase {
    func test_baseHost_getBaseURL() {
        let expectedHost = "example.com"
        let sut = makeSUT(readBaseHost: expectedHost)
        
        let baseHost = sut.baseHost
        
        XCTAssertEqual(baseHost, expectedHost)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(readBaseHost baseHost: String) -> NetworkConfigurations {
        let propertyReader = StubPropertyListReader(readValue: baseHost)
        let configuration = NetworkConfigurations(infoReader: propertyReader)
        return configuration
    }
}

private struct StubPropertyListReader: PropertyListReading {
    private let readValueStub: String
    
    init(readValue: String) {
        readValueStub = readValue
    }
    
    func read<T>(key: String) -> T? {
        return readValueStub as? T
    }
}
