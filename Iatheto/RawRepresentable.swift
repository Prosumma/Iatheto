//
//  RawRepresentable.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

extension JSONDecodable where Self: RawRepresentable, Self.RawValue == String {
    public static func decode(json: JSON, state: Any?) throws -> Self? {
        return try json.decodeString { self.init(rawValue: $0) }
    }
}

extension JSONDecodable where Self: RawRepresentable, Self.RawValue == Int {
    public static func decode(json: JSON, state: Any?) throws -> Self? {
        guard let number = try json.numberWithFormatter(JSON.decodingNumberFormatter) else { throw JSONError.undecodableJSON(json) }
        return self.init(rawValue: number.intValue)
    }
}

extension JSONEncodable where Self: RawRepresentable, Self.RawValue: JSONEncodable {
    public func encode(state: Any?) throws -> JSON {
        return try rawValue.encode(state: state)
    }
}

