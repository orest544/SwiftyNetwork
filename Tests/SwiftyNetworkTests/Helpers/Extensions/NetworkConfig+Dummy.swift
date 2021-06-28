//
//  NetworkConfig+Dummy.swift
//  
//
//  Created by Orest Patlyka on 23.02.2021.
//

import Foundation
import SwiftyNetwork

extension Server {
    static var dummy: Server {
        return .init(scheme: .http, host: "example.com")
    }
}

extension NetworkConfig {
    static var dummy: NetworkConfig {
        return .init(server: .dummy,
                     headers: ["Content-Type": "application/json"])
    }
}
