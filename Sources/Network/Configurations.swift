//
//  Configurations.swift
//  
//
//  Created by Orest Patlyka on 16.02.2021.
//

import Foundation

public final class NetworkConfigurations {
    enum PropertyListKeys: String {
        case apiBaseHost = "APIBaseHost"
    }
    
    public lazy var baseHost: String = {
        return read(key: .apiBaseHost)
    }()
    
    private let infoReader: PropertyListReading
    
    public init(infoReader: PropertyListReading = PropertyListReader()) {
        self.infoReader = infoReader
    }
    
    private func read<T>(key: PropertyListKeys) -> T {
        let propertyKey = key.rawValue
        let propertyValue: T? = infoReader.read(key: propertyKey)
        guard let value = propertyValue else {
            fatalError("\(propertyKey) must not be empty in plist")
        }
        return value
    }
}

public protocol PropertyListReading {
    func read<T>(key: String) -> T?
}

public struct PropertyListReader: PropertyListReading {
    public init() { }
    
    public func read<T>(key: String) -> T? {
        return Bundle.main.object(forInfoDictionaryKey: key) as? T
    }
}
