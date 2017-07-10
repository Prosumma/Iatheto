//
//  Iatheto.swift
//  Iatheto
//
//  Created by Gregory Higley on 3/25/16.
//  Copyright © 2016 Gregory Higley. All rights reserved.
//

import Foundation

public indirect enum JSON: CustomStringConvertible, CustomDebugStringConvertible, JSONCodable, Equatable {
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
    */
    private static func createDateFormatter(_ format: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!
        return dateFormatter
    }

    public static var dateOnlyFormatter = createDateFormatter("yyyy-MM-dd")
    public static var dateAndTimeFormatters = [encodingDateFormatter] + ["yyyy-MM-dd'T'HH:mm:ss.SSS", "yyyy-MM-dd'T'HH:mm:ss'Z'", "yyyy-MM-dd'T'HH:mm:ss"].map{ createDateFormatter($0) }
    public static var decodingDateFormatters = dateAndTimeFormatters + [dateOnlyFormatter]
    public static var encodingDateFormatter = createDateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    
    case null
    case string(String)
    case number(NSNumber)
    case array(JSONArray)
    case dictionary(JSONDictionary)
    
    public init() {
        self = .dictionary([:])
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
    public init(parsing string: String) throws {
        try self.init(data: string.data(using: String.Encoding.utf8)!)
    }
    
    /**
     Initializes `JSON` with any of the primitive values accepted by
     Cocoa's `JSONSerialization`, e.g., `String`, `NSNumber`, `NSDictionary`,
     and so on. `JSON` itself is also supported.
    */
    public init(_ value: Any?) throws {
        guard let value = value else {
            self = .null
            return
        }
        
        if let dictionary = value as? [String: Any] {
            self = try .dictionary(JSONDictionary(dictionary.map{ (key: $0.key, value: try JSON($0.value)) }.dictionary()))
        } else if let array = value as? [Any] {
            self = try .array(JSONArray(array.map { try JSON($0) }))
        } else if let string = value as? String {
            self = .string(string)
        } else if let number = value as? NSNumber {
            self = .number(number)
        } else if value is NSNull {
            self = .null
        } else if value is JSON {
            self = value as! JSON
        } else {
            throw JSONError.unencodableValue(value)
        }
    }
    
    /**
     Try to make a `T` from the given JSON. If this fails,
     `decode` examines the result and if it is `null`, returns `nil`.
     Otherwise, it raises `JSONError.undecodableJSON(self)`.
    */
    public func decode<T>(make: (JSON) throws -> T?) throws -> T? {
        if let result = try make(self) { return result }
        if case .null = self { return nil }
        throw JSONError.undecodableJSON(self)
    }
    
    public func decodeString<T>(make: (String) throws -> T?) throws -> T? {
        return try decode { json in
            if case .string(let string) = json {
                return try make(string)
            }
            return nil
        }
    }
    
    public func decodeNumber<T>(make: (NSNumber) throws -> T?) throws -> T? {
        return try decode { json in
            if case .number(let number) = json {
                return try make(number)
            }
            return nil
        }
    }
    
    public func decodeArray<T>(make: (JSONArray) throws -> T?) throws -> T? {
        return try decode { json in
            if case .array(let array) = json {
                return try make(array)
            }
            return nil
        }
    }
    
    public func decodeDictionary<T>(make: (JSONDictionary) throws -> T?) throws -> T? {
        return try decode { json in
            if case .dictionary(let dictionary) = json {
                return try make(dictionary)
            }
            return nil
        }
    }
    
    public var string: String? {
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
    
    public func dateWithFormatters<S: Sequence>(_ formatters: S) throws -> Date? where S.Iterator.Element == DateFormatter {
        switch self {
        case .string(let string):
            for formatter in formatters {
                if let date = formatter.date(from: string) { return date }
            }
            throw JSONError.undecodableJSON(self)
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
        get { return (try? dateWithFormatters(JSON.decodingDateFormatters))! }
        set { set(date: newValue, withFormatter: JSON.encodingDateFormatter) }
    }
    
    public func numberWithFormatter(_ formatter: NumberFormatter) throws -> NSNumber? {
        switch self {
        case .number(let number): return number
        case .string(let string): return try formatter.number(from: string) ??! JSONError.undecodableJSON(self)
        case .null: return nil
        default: throw JSONError.undecodableJSON(self)
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
            guard let array = array else { return .null }
            return array[index]
        }
        set {
            if array == nil {
                array = []
            }
            array![index] = newValue
        }
    }
    
    public subscript(key: String) -> JSON {
        get {
            guard let dictionary = dictionary else { return .null }
            return dictionary[key]
        }
        set {
            if dictionary == nil {
                dictionary = [:]
            }
            dictionary![key] = newValue
        }
    }
    
    public subscript(keypath: KeyPath) -> JSON {
        get {
            let keypaths = keypath.flatten()
            if keypaths.count == 0 { return .null }
            let first = keypaths[0]
            let result: JSON
            switch self {
            case .array(let array):
                let p: Int
                switch first {
                case .index(let i): p = i
                case .last: if array.count == 0 { return .null } else { p = array.count - 1 }
                default: return .null
                }
                result = array[p]
            case .dictionary(let dictionary):
                if case .key(let key) = first {
                    result = dictionary[key]
                } else {
                    return .null
                }
            default:
                return .null
            }
            let rest = keypaths.suffix(from: 1)
            if rest.count > 0 {
                let keypath = KeyPath(rest)
                return result[keypath]
            }
            return result
        }
        set {
            let keypaths = keypath.flatten()
            switch keypaths.count {
            case 0:
                // This is where we do nothing
                return
            case 1:
                // This is where we do our assignment
                switch keypaths[0] {
                case .index(let i):
                    self[i] = newValue
                case .last:
                    let i: Int
                    if let count = array?.count, count > 0 {
                        i = count - 1
                    } else {
                        i = 0
                    }
                    self[i] = newValue
                case .key(let key):
                    self[key] = newValue
                default:
                    return
                }
            default:
                // This is where we start recursion
                let rest = KeyPath(keypaths.suffix(from: 1))
                switch keypaths[0] {
                case .index(let i):
                    self[i][rest] = newValue
                case .last:
                    let i: Int
                    if let count = array?.count, count > 0 {
                        i = count - 1
                    } else {
                        i = 0
                    }
                    self[i][rest] = newValue
                case .key(let key):
                    self[key][rest] = newValue
                default:
                    return
                }
            }
        }
    }
    
    public func filter(_ keypath: KeyPath, predicate: (JSON) -> Bool) -> JSON {
        if case .array(let array) = self[keypath] {
            return .array(array.filter(predicate))
        }
        return .null
    }
    
    public func map(_ keypath: KeyPath, transform: (JSON) throws -> JSON) rethrows -> JSON {
        if case .array(let array) = self[keypath] {
            return try .array(array.map(transform))
        }
        return .null
    }
    
    public var value: Any {
        switch self {
        case .null: return NSNull()
        case .string(let string): return string
        case .number(let number): return number
        case .array(let array): return array.map { $0.value }
        case .dictionary(let dictionary): return dictionary.map{ (key: $0.key, value: $0.value.value) }.dictionary()
        }
    }
    
    public func rawData(_ options: JSONSerialization.WritingOptions = []) throws -> Data {
        return try JSONSerialization.data(withJSONObject: value, options: options)
    }
    
    public static func decode(json: JSON, state: Any?) throws -> JSON? {
        return json
    }
    
    public func encode(state: Any?) throws -> JSON {
        return self
    }
    
    public var description: String {
        return try! String(data: rawData(.prettyPrinted), encoding: .utf8)!
    }
    
    public var debugDescription: String {
        return description
    }
}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch lhs {
    case .null: if case .null = rhs { return true } else { return false }
    case .array(let array1): if case .array(let array2) = rhs { return array1 == array2 } else { return false }
    case .dictionary(let dictionary1): if case .dictionary(let dictionary2) = rhs { return dictionary1 == dictionary2 } else { return false }
    case .number(let number1): if case .number(let number2) = rhs { return number1 == number2 } else { return false }
    case .string(let string1): if case .string(let string2) = rhs { return string1 == string2 } else { return false }
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
    
    public init(arrayLiteral elements: JSON...) {
        self = .array(JSONArray(elements))
    }
    
}

extension JSON: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var dictionary = [String: JSON]()
        for element in elements {
            dictionary[element.0] = element.1
        }
        self = .dictionary(JSONDictionary(dictionary))
    }
    
}

extension JSON: ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        self = .null
    }
    
}

