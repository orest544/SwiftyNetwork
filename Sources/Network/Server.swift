//
//  Server.swift
//  
//
//  Created by Orest Patlyka on 18.02.2021.
//

import Foundation

public enum ServerScheme: String, Equatable {
    case http
    case https
}

public struct Server: Equatable {
    public let scheme: ServerScheme
    public let host: String
    
    public init(scheme: ServerScheme, host: String) {
        self.scheme = scheme
        self.host = host
    }
}
