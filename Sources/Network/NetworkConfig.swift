//
//  NetworkConfig.swift
//  
//
//  Created by Orest Patlyka on 17.02.2021.
//

import Foundation

public struct NetworkConfig: Equatable {
    public let server: Server
    public let headers: [String: String]
    
    public init(server: Server,
                headers: [String: String] = .init()) {
        self.server = server
        self.headers = headers
    }
}
