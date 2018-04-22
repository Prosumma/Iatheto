//
//  Dictionary.swift
//  Iatheto
//
//  Created by Gregory Higley on 4/22/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import Foundation

extension Sequence {
    
    func dictionary<Key, Value>() -> Dictionary<Key, Value> where Element == Dictionary<Key, Value>.Element {
        var dictionary = Dictionary<Key, Value>()
        for elem in self {
            dictionary[elem.key] = elem.value
        }
        return dictionary
    }
    
    func dictionary<Key, Value>() -> Dictionary<Key, Value> where Element == (Key, Value) {
        var dictionary = Dictionary<Key, Value>()
        for elem in self {
            dictionary[elem.0] = elem.1
        }
        return dictionary
    }
    
}
