//
//  JSONDecoder.swift
//  
//
//  Created by Orest Patlyka on 18.02.2021.
//

import Foundation

extension JSONDecoder {
    static func makeSnakeCaseDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
