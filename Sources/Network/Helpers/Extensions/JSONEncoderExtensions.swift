//
//  JSONEncoderExtensions.swift
//  
//
//  Created by Orest Patlyka on 18.02.2021.
//

import Foundation

extension JSONEncoder {
    static func makeSnakeCaseEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
