//
//  Optional.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

extension Optional where Wrapped: JSONEncodable {
    public func encode(state: Any? = nil) throws -> JSON {
        return try self?.encode(state: state) ?? .null
    }
}

extension Optional where Wrapped == JSON {
    public func decode<T: JSONDecodable>(state: Any? = nil) throws -> T? {
        if self == nil { return nil }
        return try T.decode(json: self!, state: state)
    }
}

