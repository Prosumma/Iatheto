//
//  Iatheto.swift
//  Iatheto
//
//  Created by Gregory Higley on 3/25/16.
//  Copyright © 2016 Gregory Higley. All rights reserved.
//

import Foundation

public enum JSONError: Error {
    case unencodableValue(Any)
    case undecodableJSON(JSON)
    case invalidState(Any?)
}

/**
 Decoding is the act of turning something from JSON
 into a "concrete" type.
 
 - note: Decoding is "loosely typed". In other words, if the
 underlying JSON does not support being decoded into the given
 type, `nil` is returned. If an invalid `state` parameter is
 passed, implementors should either return `nil` or fail a
 runtime assertion.
*/
public protocol JSONDecodable {
    static func decode(_ json: JSON, state: Any?) throws -> Self?
}

/**
 Encoding is the act of turning something into JSON.
 
 - note: Encoding is assumed always to succeed, since 
 types inherently know how to encode themselves. If
 an invalid `state` parameter is passed, clients should
 either return `JSON.Null` or fail a runtime assertion.
*/
public protocol JSONEncodable {
    func encode(_ state: Any?) -> JSON
}

public protocol JSONCodable: JSONEncodable, JSONDecodable {}

extension JSONDecodable {
    public static func decode(_ json: JSON) throws -> Self? {
        return try decode(json, state: nil)
    }
}

extension JSONEncodable {
    public func encode() -> JSON {
        return encode(nil)
    }
    
    public func encode(_ state: Any?) throws -> Data {
        let json: JSON = self.encode(state)
        return try json.rawData()
    }
    
    public func encode() throws -> Data {
        return try encode(nil)
    }
}

extension Optional where Wrapped: JSONEncodable {
    public func encode(_ state: Any? = nil) -> JSON {
        return self?.encode(state) ?? .null
    }
}

extension Optional where Wrapped: JSONDecodable {
    public static func decode(_ json: JSON, state: Any? = nil) throws -> Wrapped? {
        return try Wrapped.decode(json, state: state)
    }
}

extension Sequence where Iterator.Element: JSONEncodable {
    public func encode(_ state: Any? = nil) -> JSON {
        return .array(map { $0.encode(state) })
    }
}

extension Sequence where Iterator.Element: JSONDecodable {
    public static func decode(_ json: JSON, state: Any? = nil) throws -> [Iterator.Element]? {
        if case .array(let array) = json {
            var elements = Array<Iterator.Element>()
            for json in array {
                if let element = try Iterator.Element.decode(json, state: state) {
                    elements.append(element)
                }
            }
            return elements
        } else if case .null = json {
            return nil
        } else {
            throw JSONError.undecodableJSON(json)
        }
    }
}

extension Sequence where Iterator.Element == JSON {
    public func decode<T: JSONDecodable>(_ state: Any? = nil) throws -> [T] {
        var elements = [T]()
        for json in self {
            if let element = try T.decode(json, state: state) {
                elements.append(element)
            }
        }
        return elements
    }
}

extension Dictionary where Key == String, Value: JSONDecodable {
    public init?(_ json: JSON, state: Any? = nil) throws {
        if case .dictionary(let dictionary) = json {
            self.init()
            for (key, json) in dictionary {
                if let value = try Value.decode(json, state: state) {
                    self[key] = value
                }
            }
        } else if case .null = json {
            return nil
        } else {
            throw JSONError.undecodableJSON(json)
        }
    }
    
    public static func decode(_ json: JSON, state: Any? = nil) throws -> Dictionary<Key, Value>? {
        return try self.init(json, state: state)
    }
}

extension Dictionary where Key == String, Value: JSONEncodable {
    public func encode(_ state: Any? = nil) -> JSON {
        var json = JSON()
        for (key, value) in self {
            json[key] = value.encode(state)
        }
        return json
    }
}

extension Dictionary where Value == JSON {
    public func decode<T: JSONDecodable>(_ state: Any? = nil) throws -> [Key: T] {
        var dictionary = [Key: T]()
        for (key, json) in self {
            dictionary[key] = try T.decode(json, state: state)
        }
        return dictionary
    }
}

extension Set where Element: JSONDecodable {
    public static func decode(_ json: JSON, state: Any? = nil) throws -> Set? {
        if case .array(let array) = json {
            var elements = Array<Iterator.Element>()
            for json in array {
                if let element = try Iterator.Element.decode(json, state: state) {
                    elements.append(element)
                }
            }
            return self.init(elements)
        } else if case .null = json {
            return nil
        } else {
            throw JSONError.undecodableJSON(json)
        }
    }
}

extension NSNull: JSONEncodable {
    public func encode(_ state: Any?) -> JSON {
        return .null
    }
    
    public static func decode(_ json: JSON, state: Any? = nil) throws -> NSNull? {
        if case .null = json {
            return NSNull()
        } else {
            throw JSONError.undecodableJSON(json)
        }
    }
}

extension String: JSONCodable {
    public init?(_ json: JSON, state: Any?) throws {
        guard let string = json.string else {
            return nil
        }
        self = string
    }
    
    public static func decode(_ json: JSON, state: Any?) throws -> String? {
        return try self.init(json, state: state)
    }
    
    public func encode(_ state: Any?) -> JSON {
        return .string(self)
    }
}

extension NSNumber: JSONEncodable {
    public func encode(_ state: Any?) -> JSON {
        return .number(self)
    }
}

extension Int: JSONCodable {
    public init?(_ json: JSON, state: Any?) throws {
        guard let int = json.int else {
            return nil
        }
        self = int
    }
    
    public static func decode(_ json: JSON, state: Any?) throws -> Int? {
        return try self.init(json, state: state)
    }
    
    public func encode(_ state: Any?) -> JSON {
        return .number(NSNumber(value: self as Int))
    }
}

extension Double: JSONCodable {
    public init?(_ json: JSON, state: Any?) throws {
        guard let double = json.double else {
            return nil
        }
        self = double
    }
    
    public static func decode(_ json: JSON, state: Any?) throws -> Double? {
        return try self.init(json, state: state)
    }
    
    public func encode(_ state: Any?) -> JSON {
        return .number(NSNumber(value: self as Double))
    }
}

extension Float: JSONCodable {
    public init?(_ json: JSON, state: Any?) throws {
        guard let float = json.float else {
            return nil
        }
        self = float
    }
    
    public static func decode(_ json: JSON, state: Any?) throws -> Float? {
        return try self.init(json, state: state)
    }
    
    public func encode(_ state: Any?) -> JSON {
        return .number(NSNumber(value: self as Float))
    }
}

public indirect enum JSON: CustomStringConvertible, CustomDebugStringConvertible, JSONCodable {
    public typealias JSONDictionary = Swift.Dictionary<Swift.String, JSON>
    public typealias JSONArray = Swift.Array<JSON>
    
    /**
     Used for converting JSON strings into numbers.
    */
    public static var encodingNumberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        return numberFormatter
    }()
    
    /**
     Used for converting numbers into JSON strings.
    */
    public static var decodingNumberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        return numberFormatter
    }()
    
    /**
     Used for converting JSON strings into dates.
    */
    public static var encodingDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }()
    
    /**
     Used for converting dates into JSON strings.
    */
    public static var decodingDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }()
    
    case null
    case string(String)
    case number(NSNumber)
    case array(JSONArray)
    case dictionary(JSONDictionary)
    
    public init() {
        self = .dictionary([:])
    }
    
    public init?(json: JSON, state: Any? = nil) {
        self = json
    }
    
    public init<S: Sequence>(sequence: S) where S.Iterator.Element == JSON {
        self = .array(JSONArray(sequence))
    }
    
    public init(data: Data) throws {
        self = try JSON(JSONSerialization.jsonObject(with: data, options: []))
    }
    
    /**
     Initializes `JSON` with a string containing well-formed JSON.
    */
    public init(string: Swift.String) throws {
        try self.init(data: string.data(using: Swift.String.Encoding.utf8)!)
    }
    
    public init(_ value: Any?) throws {
        guard let value = value else {
            self = .null
            return
        }
        
        if let dictionary = value as? [Swift.String: Any] {
            var json = JSONDictionary()
            for (key, value) in dictionary {
                json[key] = try JSON(value)
            }
            self = .dictionary(json)
        } else if let array = value as? [Any] {
            self = .array(try array.map { try JSON($0) })
        } else if let string = value as? Swift.String {
            self = .string(string)
        } else if let number = value as? NSNumber {
            self = .number(number)
        } else if value is NSNull {
            self = .null
        } else {
            throw JSONError.unencodableValue(value)
        }
    }
    
    public var string: Swift.String? {
        get {
            if case .string(let string) = self {
                return string
            } else {
                return nil
            }
        }
        set {
            if let string = newValue {
                self = .string(string)
            } else {
                self = .null
            }
        }
    }
    
    public func dateWithFormatter(_ formatter: DateFormatter) throws -> Date? {
        switch self {
        case .string(let string):
            guard let date = formatter.date(from: string) else { throw JSONError.undecodableJSON(self) }
            return date
        case .null:
            return nil
        default:
            throw JSONError.undecodableJSON(self)
        }
    }
    
    public mutating func set(date: Date?, withFormatter formatter: DateFormatter) {
        guard let date = date else {
            self = .null
            return
        }
        self = .string(formatter.string(from: date))
    }
    
    public var date: Date? {
        get {
            return (try? dateWithFormatter(JSON.decodingDateFormatter))!
        }
        set {
            set(date: newValue, withFormatter: JSON.decodingDateFormatter)
        }
    }
    
    public func numberWithFormatter(_ formatter: NumberFormatter) throws -> NSNumber? {
        switch self {
        case .number(let number):
            return number
        case .string(let string):
            guard let number = formatter.number(from: string) else { throw JSONError.undecodableJSON(self) }
            return number
        case .null:
            return nil
        default:
            throw JSONError.undecodableJSON(self)
        }
    }
    
    public var number: NSNumber? {
        get {
            switch self {
            case .number(let number): return number
            case .string(let string): return JSON.encodingNumberFormatter.number(from: string)
            default: return nil
            }
        }
        set {
            if let number = newValue {
                self = .number(number)
            } else {
                self = .null
            }
        }
    }
    
    public var array: JSONArray? {
        get {
            if case .array(let array) = self {
                return array
            } else {
                return nil
            }
        }
        set {
            if let array = newValue {
                self = .array(array)
            } else {
                self = .null
            }
        }
    }
    
    public var dictionary: JSONDictionary? {
        get {
            if case .dictionary(let dictionary) = self {
                return dictionary
            } else {
                return nil
            }
        }
        set {
            if let dictionary = newValue {
                self = .dictionary(dictionary)
            } else {
                self = .null
            }
        }
    }
    
    public var bool: Bool? {
        get {
            return number?.boolValue
        }
        set {
            if let bool = newValue {
                number = NSNumber(value: bool)
            } else {
                self = .null
            }
        }
    }
    
    public var int: Int? {
        get {
            return number?.intValue
        }
        set {
            if let int = newValue {
                number = NSNumber(value: int)
            } else {
                self = .null
            }
        }
    }
    
    public var double: Double? {
        get {
            return number?.doubleValue
        }
        set {
            if let double = newValue {
                number = NSNumber(value: double)
            } else {
                self = .null
            }
        }
    }
    
    public var float: Float? {
        get {
            return number?.floatValue
        }
        set {
            if let float = newValue {
                number = NSNumber(value: float)
            } else {
                self = .null
            }
        }
    }
    
    public var null: NSNull? {
        get {
            guard case .null = self else {
                return nil
            }
            return NSNull()
        }
        set {
            self = .null
        }
    }
    
    public var isNull: Bool {
        return null != nil
    }
    
    public subscript(index: Int) -> JSON {
        get {
            if case .array(let array) = self {
                return array[index]
            } else {
                return JSON.null
            }
        }
        set {
            array![index] = newValue
        }
    }
    
    public subscript(key: Swift.String) -> JSON {
        get {
            if case .dictionary(let dictionary) = self {
                return dictionary[key] ?? JSON.null
            } else {
                return JSON.null
            }
        }
        set {
            dictionary![key] = newValue
        }
    }
    
    fileprivate var value: Any {
        switch self {
        case .null:
            return NSNull()
        case .string(let string):
            return string
        case .number(let number):
            return number
        case .array(let array):
            return array.map { $0.value }
        case .dictionary(let dictionary):
            var object = Swift.Dictionary<Swift.String, Any>()
            for (key, json) in dictionary {
                object[key] = json.value
            }
            return object
        }
    }
    
    public func rawData(_ options: JSONSerialization.WritingOptions = []) throws -> Data {
        return try JSONSerialization.data(withJSONObject: value, options: options)
    }
    
    public static func decode(_ json: JSON, state: Any?) throws -> JSON? {
        return self.init(json: json, state: state)
    }
    
    public func encode(_ state: Any?) -> JSON {
        return self
    }
    
    public var description: Swift.String {
        do {
            return try Swift.String(data: rawData(.prettyPrinted), encoding: Swift.String.Encoding.utf8)!
        } catch _ {
            return ""
        }
    }
    
    public var debugDescription: Swift.String {
        return description
    }
    
}

extension JSON: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        try! self.init(value as Any?)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        try! self.init(value as Any?)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        try! self.init(value as Any?)
    }
    
}

extension JSON: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        try! self.init(value as Any?)
    }
    
}

extension JSON: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: FloatLiteralType) {
        try! self.init(value as Any?)
    }
    
}

extension JSON: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        try! self.init(value as Any?)
    }
    
}

extension JSON: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Any...) {
        try! self.init(elements as Any?)
    }
    
}

extension JSON: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (Swift.String, Any)...) {
        var dictionary = JSONDictionary()
        for element in elements {
            dictionary[element.0] = try! JSON(element.1)
        }
        self = .dictionary(dictionary)
    }
    
}

extension JSON: ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        self = .null
    }
    
}

