//
//  NetworkTransportResponse.swift
//  
//
//  Created by Orest Patlyka on 03.03.2021.
//

import Foundation

public struct NetworkTransportResponse: Equatable {
    let data: Data?
    let httpResponse: HTTPURLResponse
}
