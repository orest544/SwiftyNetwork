//
//  URLRequest+Dummy.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import Foundation

extension URLRequest {
    static var dummy: URLRequest {
        return .init(url: URL(fileURLWithPath: ""))
    }
}
