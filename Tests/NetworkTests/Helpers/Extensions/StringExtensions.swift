//
//  StringExtensions.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import Foundation
import XCTest

extension String {
    func jsonData() throws -> Data {
        return try XCTUnwrap(data(using: .utf8))
    }
}
