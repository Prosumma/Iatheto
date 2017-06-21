//
//  Array.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

public extension Array where Element: JSONDecodable {
    /**
     Decode `json` into an array of `Element`. Any `null` values
     are removed from the resulting array.
    */
    static func decode(json: JSON, state: Any? = nil) throws -> [Element]? {
        return try json.decodeArray{ array in try array.flatMap{ try Element.decode(json: $0, state: state) } }
    }
    
    /**
     Parses the passed-in string as JSON and returns an array of `Element`, or `nil`
     if not successful.
    */
    static func decode(parsing string: String, state: Any? = nil) throws -> [Element]? {
        let json = try JSON(parsing: string)
        return try decode(json: json, state: state)
    }
    
    static func decode(data: Data, state: Any? = nil) throws -> [Element]? {
        let json = try JSON(data: data)
        return try decode(json: json, state: state)
    }
    
    static func decode(json: JSON, state: Any? = nil) throws -> [Element?]? {
        return try json.decodeArray { array in
            try array.map{ try Iterator.Element.decode(json: $0, state: state) }
        }
    }
    
    static func decode(parsing string: String, state: Any? = nil) throws -> [Element?]? {
        let json = try JSON(parsing: string)
        return try decode(json: json, state: state)
    }
    
    static func decode(data: Data, state: Any? = nil) throws -> [Element?]? {
        let json = try JSON(data: data)
        return try decode(json: json, state: state)
    }
}

extension Array {
    /**
     Reconstruct a dictionary after it's been reduced to an array of key-value pairs by `filter` and the like.
     
     ```
     var dictionary = [1: "ok", 2: "crazy", 99: "abnormal"]
     dictionary = dictionary.filter{ $0.value == "ok" }.dictionary()
     ```
     */
    func dictionary<K: Hashable, V>() -> [K: V] where Element == Dictionary<K, V>.Element {
        var dictionary = [K: V]()
        for element in self {
            dictionary[element.key] = element.value
        }
        return dictionary
    }
    
}

