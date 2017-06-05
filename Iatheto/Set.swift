//
//  Set.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

extension Set where Element: JSONDecodable, Element: Hashable {
    public static func decode(json: JSON, state: Any? = nil) throws -> Set<Element>? {
        guard let array: [Element] = try [Element].decode(json: json, state: state) else { return nil }
        return Set<Element>(array)
    }
    
    public static func decode(parsing string: String, state: Any? = nil) throws -> Set<Element>? {
        let json = try JSON(parsing: string)
        return try decode(json: json, state: state)
    }
    
    public static func decode(data: Data, state: Any? = nil) throws -> Set<Element>? {
        let json = try JSON(data: data)
        return try decode(json: json, state: state)
    }
}

