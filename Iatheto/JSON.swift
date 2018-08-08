//
//  JSON.swift
//  Iatheto
//
//  Created by Gregory Higley on 4/21/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import Foundation

/**
 Encodes and decodes arbitrary JSON while conforming
 to Apple's Codable protocol.
 
 This is a very low-level representation of JSON and
 includes only those data types supported by the spec
 and no others.
 
 - warning: The `Decimal` type, which is used to represent
 numbers, is not guaranteed to preserve the exact value of
 the number as transmitted. This problem is not specific to
 Iatheto, but is rather a limitation of `NSJSONSerialization`,
 which is used by Apple's frameworks to serialize JSON. In
 most cases, however, `Decimal` better preserves numbers than
 `Float` or `Double`.
 */
@dynamicMemberLookup
public enum JSON: Codable, Equatable {
    /// Represents a JSON `null`.
    case null
    /// Represents a JSON Boolean value.
    case bool(Bool)
    /// Represents a JSON string.
    case string(String)
    /// Represents a JSON number.
    case number(Decimal)
    /// Represents an array of JSON values.
    case array([JSON])
    /// Represents a dictionary of JSON values.
    case dictionary([String: JSON])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else {
            self = try attempt(
                { try JSON.string(container.decode(String.self)) },
                { try JSON.number(container.decode(Decimal.self)) },
                { try JSON.bool(container.decode(Bool.self)) },
                { try JSON.array(container.decode([JSON].self)) },
                { try JSON.dictionary(container.decode([String: JSON].self)) }
            )
        }
    }
    
    /// Initialization by parsing the given `Data` as JSON.
    public init(parsing data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(JSON.self, from: data)
    }
    
    /// Initialization by parsing the given `String` as JSON.
    public init(parsing string: String) throws {
        try self.init(parsing: string.data(using: .utf8, allowLossyConversion: false)!)
    }
    
    public subscript(dynamicMember member: String) -> JSON? {
        return self[member]
    }
    
    /**
     Encodes the current instance into JSON returned as `Data`.
     
     - parameter encoder: The `JSONEncoder` with which to do the encoding.
     - returns: A `Data` instance containing JSON.
     - throws: Any errors produced by the encoding process.
     */
    public func encoded(by encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }

    /**
     Encodes the current instance into JSON returned as a `String`.
     
     - parameter encoder: The `JSONEncoder` with which to do the encoding.
     - returns: A `String` instance containing JSON.
     - throws: Any errors produced by the encoding process.
     */
    public func encoded(by encoder: JSONEncoder = JSONEncoder()) throws -> String {
        return try String(data: encoded(by: encoder), encoding: .utf8)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case let .bool(value): try container.encode(value)
        case let .string(value): try container.encode(value)
        case let .number(value): try container.encode(value)
        case let .array(value): try container.encode(value)
        case let .dictionary(value): try container.encode(value)
        }
    }
    
}

