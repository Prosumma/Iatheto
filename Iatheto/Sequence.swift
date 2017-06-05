//
//  Sequence.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element: JSONEncodable {
    public func encode(state: Any? = nil) throws -> JSON {
        return try .array(JSONArray(map { try $0.encode(state: state) }))
    }
}

extension Sequence where Iterator.Element == JSON {
    public func decode<T: JSONDecodable>(state: Any? = nil) throws -> [T] {
        return try flatMap{ try T.decode(json: $0, state: state) }
    }
    
    public func decode<T: JSONDecodable>(state: Any? = nil) throws -> [T?] {
        return try map{ try T.decode(json: $0, state: state) }
    }
}
