//
//  NSError+Dummy.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import Foundation

extension NSError {
    static var dummy: NSError {
        return .init(domain: "", code: 0)
    }
}
