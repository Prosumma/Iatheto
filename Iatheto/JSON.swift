//
//  JSON.swift
//  Iatheto
//
//  Created by Gregory Higley on 4/21/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import Foundation

public enum JSON: Codable {
    case null
    case bool(Bool)
    case string(String)
    case int(Int64)
    case float(Double)
    case array([JSON])
    case dictionary([String: JSON])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else {
            self = try attempt(
                { try JSON.string(container.decode(String.self)) },
                {
                    do {
                        return try JSON.int(container.decode(Int64.self))
                    } catch DecodingError.dataCorrupted(let context) {
                        throw DecodingError.typeMismatch(Int64.self, context)
                    }
                },
                { try JSON.float(container.decode(Double.self)) },
                { try JSON.bool(container.decode(Bool.self)) },
                { try JSON.array(container.decode([JSON].self)) },
                { try JSON.dictionary(container.decode([String: JSON].self)) }
            )
        }
    }
    
    public init(parsing data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(JSON.self, from: data)
    }
    
    public init(parsing string: String) throws {
        try self.init(parsing: string.data(using: .utf8, allowLossyConversion: false)!)
    }
    
    public func encoded() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
    
    public func encoded() throws -> String {
        return try String(data: encoded(), encoding: .utf8)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case let .bool(value): try container.encode(value)
        case let .string(value): try container.encode(value)
        case let .int(value): try container.encode(value)
        case let .float(value): try container.encode(value)
        case let .array(value): try container.encode(value)
        case let .dictionary(value): try container.encode(value)
        }
    }
    
}

