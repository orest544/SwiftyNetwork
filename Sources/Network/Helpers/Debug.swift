//
//  Debug.swift
//  
//
//  Created by Orest Patlyka on 28.06.2021.
//

import Foundation

public func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}
