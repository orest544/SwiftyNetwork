//
//  DummyCancellable.swift
//  
//
//  Created by Orest Patlyka on 22.02.2021.
//

import Foundation
@testable import SwiftyNetwork

struct DummyCancellable: NetworkCancellable, Equatable {
    func cancel() { }
}
