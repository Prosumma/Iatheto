//
//  JSONDecodable.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

public protocol JSONDecodable {
    static func decode(json: JSON, state: Any?) throws -> Self?
}

public extension JSONDecodable {
    static func decode(json: JSON) throws -> Self? {
        return try decode(json: json, state: nil)
    }
    
    static func decode(parsing string: String, state: Any? = nil) throws -> Self? {
        let json = try JSON(parsing: string)
        return try decode(json: json, state: state)
    }
    
    static func decode(data: Data, state: Any? = nil) throws -> Self? {
        let json = try JSON(data: data)
        return try decode(json: json, state: state)
    }
}
