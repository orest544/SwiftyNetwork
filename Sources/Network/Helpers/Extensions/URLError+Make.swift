//
//  URLError+Make.swift
//  
//
//  Created by Orest Patlyka on 16.03.2021.
//

import Foundation

extension URLError {
    static func make(with error: Error) -> URLError {
        let urlError = error as? URLError
        return urlError ?? .init(.unknown)
    }
}
