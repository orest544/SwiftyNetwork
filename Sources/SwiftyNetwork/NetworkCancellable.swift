//
//  NetworkCancellable.swift
//  
//
//  Created by Orest Patlyka on 16.02.2021.
//

import Foundation

public protocol NetworkCancellable {
    func cancel()
}

extension URLSessionTask: NetworkCancellable { }
