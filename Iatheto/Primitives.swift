//
//  Primitives.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

fileprivate func cast<P, T>(_ value: P) -> T {
    return value as! T
}

fileprivate func cast<P, T>(_ value: P?) -> T? {
    return value as! T?
}

extension NSNull: JSONCodable {
    public func encode(state: Any?) throws -> JSON {
        return .null
    }
    
    public static func decode(json: JSON, state: Any? = nil) throws -> Self? {
        if case .null = json {
            return cast(NSNull())
        } else {
            throw JSONError.undecodableJSON(json)
        }
    }
    
    public static func decode(parsing string: String, state: Any? = nil) throws -> Self? {
        let json = try JSON(parsing: string)
        return try decode(json: json, state: state)
    }
    
    public static func decode(data: Data, state: Any? = nil) throws -> Self? {
        let json = try JSON(data: data)
        return try decode(json: json, state: state)
    }
}

extension NSNumber: JSONCodable {
    public func encode(state: Any?) throws -> JSON {
        return .number(self)
    }
    
    public static func decode(json: JSON, state: Any? = nil) throws -> Self? {
        return try cast(json.numberWithFormatter(JSON.decodingNumberFormatter))
    }
    
    public static func decode(parsing string: String, state: Any? = nil) throws -> NSNumber? {
        let json = try JSON(parsing: string)
        return try decode(json: json, state: state)
    }
    
    public static func decode(data: Data, state: Any? = nil) throws -> NSNumber? {
        let json = try JSON(data: data)
        return try decode(json: json, state: state)
    }
}

extension String: JSONCodable {
    public static func decode(json: JSON, state: Any?) throws -> String? {
        return try json.decode { json in
            switch json {
            case .string(let string): return string
            case .number(let number): return number.stringValue
            default: return nil
            }
        }
    }
    
    public func encode(state: Any?) throws -> JSON {
        return .string(self)
    }
}

extension Int: JSONCodable {
    public static func decode(json: JSON, state: Any?) throws -> Int? {
        return try NSNumber.decode(json: json, state: state)?.intValue
    }
    
    public func encode(state: Any?) throws -> JSON {
        return .number(NSNumber(value: self))
    }
}

extension Double: JSONCodable {
    public static func decode(json: JSON, state: Any?) throws -> Double? {
        return try NSNumber.decode(json: json, state: state)?.doubleValue
    }
    
    public func encode(state: Any?) throws -> JSON {
        return .number(NSNumber(value: self))
    }
}

extension Float: JSONCodable {
    public static func decode(json: JSON, state: Any?) throws -> Float? {
        return try NSNumber.decode(json: json, state: state)?.floatValue
    }
    
    public func encode(state: Any?) throws -> JSON {
        return .number(NSNumber(value: self))
    }
}

extension Bool: JSONCodable {
    public static func decode(json: JSON, state: Any?) throws -> Bool? {
        return try NSNumber.decode(json: json, state: state)?.boolValue
    }
    
    public func encode(state: Any?) throws -> JSON {
        return .number(NSNumber(value: self))
    }
}

extension Date: JSONCodable {
    public static func decode(json: JSON, state: Any?) throws -> Date? {
        return try json.dateWithFormatters(JSON.decodingDateFormatters)
    }
    
    public func encode(state: Any?) throws -> JSON {
        return .string(JSON.encodingDateFormatter.string(from: self))
    }
}
