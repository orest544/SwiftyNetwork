//
//  DataTransferLogger.swift
//  
//
//  Created by Orest Patlyka on 02.03.2021.
//

import Foundation

public protocol DataTransferLogger {
    func log(decodingError: Error)
}

public final class DefaultDataTransferLogger: DataTransferLogger {
    public init() { }
    
    public func log(decodingError: Error) {
        printIfDebug("decoding error: \(decodingError)")
    }
}
