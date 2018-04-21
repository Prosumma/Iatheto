//
//  Sequence.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

public extension Sequence where Iterator.Element: JSONEncodable {
    func encode(state: Any? = nil) throws -> JSON {
        return try .array(JSONArray(map { try $0.encode(state: state) }))
    }
}

public extension Sequence where Iterator.Element == JSON {
    func decode<T: JSONDecodable>(state: Any? = nil) throws -> [T] {
        return try compactMap{ try T.decode(json: $0, state: state) }
    }
    
    func decode<T: JSONDecodable>(state: Any? = nil) throws -> [T?] {
        return try map{ try T.decode(json: $0, state: state) }
    }
}
