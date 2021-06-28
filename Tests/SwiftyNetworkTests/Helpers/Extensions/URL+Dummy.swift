//
//  URL+Dummy.swift
//  
//
//  Created by Orest Patlyka on 29.03.2021.
//

import Foundation

extension URL {
    static var dummy: URL {
        return .init(fileURLWithPath: "")
    }
}
