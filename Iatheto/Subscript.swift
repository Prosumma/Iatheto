//
//  Subscript.swift
//  Iatheto
//
//  Created by Gregory Higley on 4/22/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import Foundation

public protocol Subscript {
    
}

extension String: Subscript {}
extension Int: Subscript {}

public extension JSON {
    
    subscript(_ key: String) -> JSON? {
        return dictionary?[key]
    }
    
    subscript(_ index: Int) -> JSON? {
        return array?[index]
    }
    
    subscript(_ subscripts: [Subscript]) -> JSON? {
        if subscripts.count == 0 { return nil }
        var json: JSON? = self
        for sub in subscripts {
            switch sub {
            case let key as String: json = json?[key]
            case let index as Int: json = json?[index]
            default: fatalError("Unknown subscript \(sub).")
            }
            if json == nil { return nil }
        }
        return json
    }
    
    subscript(_ subscripts: Subscript...) -> JSON? {
        return self[subscripts]
    }
    
}
