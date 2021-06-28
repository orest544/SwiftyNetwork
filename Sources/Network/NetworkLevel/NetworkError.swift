//
//  NetworkError.swift
//  
//
//  Created by Orest Patlyka on 17.02.2021.
//

import Foundation

public enum NetworkError: Error, Equatable {
    case transportFailure(URLError)
    case serverSideFailure(statusCode: Int, data: Data?)
}
