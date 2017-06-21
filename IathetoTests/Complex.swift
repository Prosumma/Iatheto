//
//  Complex.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/6/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation
@testable import Iatheto

struct Complex: JSONCodable, Equatable {
    
    let string: String
    let int: Int
    let float: Float
    
    static func decode(json: JSON, state: Any?) throws -> Complex? {
        guard let string = json["string"].string else { return nil }
        guard let int = json["int"].int else { return nil }
        return Complex(string: string, int: int, float: json["float"].float ?? 0)
    }
    
    func encode(state: Any?) throws -> JSON {
        var json: JSON = [:]
        json["string"].string = string
        json["int"].int  = int
        json["float"].float = float
        return json
    }
}

func ==(lhs: Complex, rhs: Complex) -> Bool {
    if lhs.string != rhs.string { return false }
    if lhs.int != rhs.int { return false }
    if lhs.float != rhs.float { return false }
    return true
}
