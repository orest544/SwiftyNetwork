//
//  DummyCancellable.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import Foundation
@testable import Network

struct DummyCancellable: NetworkCancellable, Equatable {
    func cancel() { }
}
