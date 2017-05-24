//
//  Iatheto.swift
//  Iatheto
//
//  Created by Gregory Higley on 3/25/16.
//  Copyright © 2016 Gregory Higley. All rights reserved.
//

import Foundation

fileprivate func cast<P, T>(_ value: P) -> T {
    return value as! T
}

fileprivate func cast<P, T>(_ value: P?) -> T? {
    return value as! T?
}

public enum JSONError: Error {
    case unencodableValue(Any)
    case undecodableJSON(JSON)
    case invalidState(Any?)
}

public indirect enum KeyPath: KeyPathConvertible {
    case key(String)
    case index(Int)
    case last
    case path([KeyPath])
    
    public func flatten() -> [KeyPath] {
        var result = Array<KeyPath>()
        if case .path(let path) = self {
            for elem in path {
                result.append(contentsOf: elem.flatten())
            }
        } else {
            result.append(self)
        }
        return result
    }
    
    public var iathetoKeyPath: KeyPath { return self }
}

extension KeyPath: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .key(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .key(value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .key(value)
    }
}

extension KeyPath: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .index(value)
    }
}

extension String: KeyPathConvertible {
    public var iathetoKeyPath: KeyPath { return .key(self) }
}

extension Int: KeyPathConvertible {
    public var iathetoKeyPath: KeyPath { return .index(self) }
}

protocol KeyPathConvertible {
    var iathetoKeyPath: KeyPath { get }
}

precedencegroup KeyPathPrecedence {
    associativity: right
    higherThan: RangeFormationPrecedence
    lowerThan: AdditionPrecedence
}

infix operator +> : KeyPathPrecedence // This gives us right-association

func +>(lhs: KeyPathConvertible, rhs: KeyPathConvertible) -> KeyPath {
    return .path([lhs.iathetoKeyPath, rhs.iathetoKeyPath])
}

func +>(lhs: KeyPath, rhs: KeyPathConvertible) -> KeyPath {
    return .path([lhs, rhs.iathetoKeyPath])
}

func +>(lhs: KeyPathConvertible, rhs: KeyPath) -> KeyPath {
    return .path([lhs.iathetoKeyPath, rhs])
}

func +>(lhs: KeyPath, rhs: KeyPath) -> KeyPath {
    return .path([lhs, rhs])
}

public protocol JSONDecodable {
    static func decode(json: JSON, state: Any?) throws -> Self?
}

extension JSONDecodable {
    public static func decode(json: JSON) throws -> Self? {
        return try decode(json: json, state: nil)
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

/**
 Encoding is the act of turning something into JSON.
 
 - note: Encoding is assumed always to succeed, since 
 types inherently know how to encode themselves. If
 an invalid `state` parameter is passed, clients should
 either return `JSON.Null` or fail a runtime assertion.
*/
public protocol JSONEncodable {
    func encode(state: Any?) throws -> JSON
}

public protocol JSONCodable: JSONEncodable, JSONDecodable {}

extension JSONEncodable {
    public func encode() throws -> JSON {
        return try encode(state: nil)
    }
    
    public func encode(state: Any? = nil, options: JSONSerialization.WritingOptions = []) throws -> Data {
        return try encode(state: state).rawData()
    }
    
    public func encode(state: Any? = nil, options: JSONSerialization.WritingOptions = []) throws -> String? {
        return try String(data: encode(state: state, options: options), encoding: .utf8)
    }
}

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

extension Sequence where Iterator.Element: JSONEncodable {
    public func encode(state: Any? = nil) throws -> JSON {
        return try .array(map { try $0.encode(state: state) })
    }
}

extension Array where Element: JSONDecodable {
    public static func decode(json: JSON, state: Any? = nil) throws -> [Element]? {
        return try json.decodeArray{ array in try array.flatMap{ try Element.decode(json: $0, state: state) } }
    }
    
    public static func decode(parsing string: String, state: Any? = nil) throws -> [Element]? {
        let json = try JSON(parsing: string)
        return try decode(json: json, state: state)
    }
    
    public static func decode(data: Data, state: Any? = nil) throws -> [Element]? {
        let json = try JSON(data: data)
        return try decode(json: json, state: state)
    }
    
    public static func decode(json: JSON, state: Any? = nil) throws -> [Element?]? {
        return try json.decodeArray { array in
            try array.map{ try Iterator.Element.decode(json: $0, state: state) }
        }
    }
    
    public static func decode(parsing string: String, state: Any? = nil) throws -> [Element?]? {
        let json = try JSON(parsing: string)
        return try decode(json: json, state: state)
    }
    
    public static func decode(data: Data, state: Any? = nil) throws -> [Element?]? {
        let json = try JSON(data: data)
        return try decode(json: json, state: state)
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

extension Dictionary where Key == String, Value: JSONDecodable {
    public static func decode(json: JSON, state: Any? = nil) throws -> Dictionary<Key, Value>? {
        return try json.decodeDictionary { dictionary in
            return try dictionary.flatMap {
                guard let value = try Value.decode(json: $0.1, state: state) else { return nil }
                return (key: $0.0, value: value)
            }.dictionary()
        }
    }
    
    public static func decode(parsing string: String, state: Any? = nil) throws -> Dictionary<Key, Value>? {
        let json = try JSON(parsing: string)
        return try decode(json: json, state: state)
    }
    
    public static func decode(data: Data, state: Any? = nil) throws -> Dictionary<Key, Value>? {
        let json = try JSON(data: data)
        return try decode(json: json, state: state)
    }
    
    public static func decode(json: JSON, state: Any? = nil) throws -> Dictionary<Key, Value?>? {
        return try json.decodeDictionary { dictionary in
            try dictionary.map{ (key: $0.0, value: try Value.decode(json: $0.1, state: state)) }.dictionary()
        }
    }
    
    public static func decode(parsing string: String, state: Any? = nil) throws -> Dictionary<Key, Value?>? {
        let json = try JSON(parsing: string)
        return try decode(json: json, state: state)
    }
    
    public static func decode(data: Data, state: Any? = nil) throws -> Dictionary<Key, Value?>? {
        let json = try JSON(data: data)
        return try decode(json: json, state: state)
    }
}

extension Dictionary where Key == String, Value: JSONEncodable {
    public func encode(state: Any? = nil) throws -> JSON {
        var json = JSON()
        for (key, value) in self {
            json[key] = try value.encode(state: state)
        }
        return json
    }
}

extension Dictionary where Value == JSON {
    public func decode<T: JSONDecodable>(state: Any? = nil) throws -> [Key: T] {
        return try flatMap {
            guard let value = try T.decode(json: $0.1, state: state) else { return nil }
            return (key: $0.0, value: value)
        }.dictionary()
    }
    
    public func decode<T: JSONDecodable>(state: Any? = nil) throws -> [Key: T?] {
        return try map { (key: $0.0, value: try T.decode(json: $0.1, state: state)) }.dictionary()
    }
}

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

public indirect enum JSON: CustomStringConvertible, CustomDebugStringConvertible, JSONCodable {
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
    
    private static func createDateFormatter(_ format: String, locale: Locale = Locale(identifier: "en_US_POSIX"), timeZone: TimeZone = TimeZone(identifier: "UTC")!) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = locale
        dateFormatter.timeZone = timeZone
        return dateFormatter
    }
    
    public static var encodingDateFormatter = createDateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    public static var dateOnlyFormatter = createDateFormatter("yyyy-MM-dd")
    public static var dateAndTimeFormatters = [encodingDateFormatter] + ["yyyy-MM-dd'T'HH:mm:ss.SSS", "yyyy-MM-dd'T'HH:mm:ss'Z'", "yyyy-MM-dd'T'HH:mm:ss"].map{ createDateFormatter($0) }
    public static var decodingDateFormatters = dateAndTimeFormatters + [dateOnlyFormatter]
    
    case null
    case string(String)
    case number(NSNumber)
    case array([JSON])
    case dictionary(JSONDictionary)
    
    public init() {
        self = .dictionary([:])
    }
    
    public init<S: Sequence>(sequence: S) where S.Iterator.Element == JSON {
        self = .array([JSON](sequence))
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
    
    public init(_ value: Any?) throws {
        guard let value = value else {
            self = .null
            return
        }
        
        if let dictionary = value as? [String: Any] {
            var json = [String: JSON]()
            for (key, value) in dictionary {
                json[key] = try JSON(value)
            }
            self = .dictionary(JSONDictionary(dictionary: json))
        } else if let array = value as? [Any] {
            self = .array(try array.map { try JSON($0) })
        } else if let string = value as? String {
            self = .string(string)
        } else if let number = value as? NSNumber {
            self = .number(number)
        } else if value is NSNull {
            self = .null
        } else {
            throw JSONError.unencodableValue(value)
        }
    }
    
    public func decode<T>(make: (JSON) throws -> T?) throws -> T? {
        if let result = try make(self) { return result }
        switch self {
        case .null: return nil
        default: throw JSONError.undecodableJSON(self)
        }
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
    
    public func decodeArray<T>(make: ([JSON]) throws -> T?) throws -> T? {
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
                if let date = formatter.date(from: string) {
                    return date
                }
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
        get {
            return (try? dateWithFormatters(JSON.decodingDateFormatters))!
        }
        set {
            set(date: newValue, withFormatter: JSON.encodingDateFormatter)
        }
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
    
    public var array: [JSON]? {
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
            return array![index]
        }
        set {
            array![index] = newValue
        }
    }
    
    // HT: Mike Ash
    public subscript(safe index: Int) -> JSON {
        get {
            return index < array!.count ? array![index] : .null
        }
    }
    
    public subscript(key: String) -> JSON {
        get {
            return dictionary![key]
        }
        set {
            dictionary![key] = newValue
        }
    }
    
    public subscript(keyPath: KeyPath) -> JSON {
        get {
            var result: JSON = self
            for elem in keyPath.flatten() {
                switch elem {
                case .index(let index): result = result[index]
                case .key(let key): result = result[key]
                case .last: result = result[result.array!.count - 1]
                case .path: fatalError("KeyPath was not flattened before use.")
                }
            }
            return result
        }
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
        return try! String(data: rawData(.prettyPrinted), encoding: String.Encoding.utf8)!
    }
    
    public var debugDescription: String {
        return description
    }
}

public struct JSONDictionary: Sequence, ExpressibleByDictionaryLiteral {
    fileprivate var dictionary = [String: JSON]()
    
    public init(dictionary: [String: JSON]) {
        self.dictionary = dictionary
    }
    
    public init(dictionaryLiteral elements: (String, JSON)...) {
        dictionary = [:]
        for element in elements {
            dictionary[element.0] = element.1
        }
    }
    
    public func makeIterator() -> DictionaryIterator<String, JSON> {
        return dictionary.makeIterator()
    }
    
    public subscript(key: String) -> JSON {
        get {
            return dictionary[key] ?? .null
        }
        set {
            dictionary[key] = newValue
        }
    }
    
    public subscript(keyPath: KeyPath) -> JSON {
        let keyPaths = keyPath.flatten()
        let first = keyPaths[0]
        if case .key(let key) = first {
            var json = self[key]
            for elem in keyPaths.suffix(from: 1) {
                json = json[elem]
            }
            return json
        } else {
            fatalError("Only .key KeyPath is supported for JSONDictionary.")
        }
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
        self = .array(elements)
    }
    
}

extension JSON: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var dictionary = [String: JSON]()
        for element in elements {
            dictionary[element.0] = element.1
        }
        self = .dictionary(JSONDictionary(dictionary: dictionary))
    }
    
}

extension JSON: ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        self = .null
    }
    
}

extension Array {
    /**
     Reconstruct a dictionary after it's been reduced to an array of key-value pairs by `filter` and the like.
     
     ```
     var dictionary = [1: "ok", 2: "crazy", 99: "abnormal"]
     dictionary = dictionary.filter{ $0.value == "ok" }.dictionary()
     ```
     */
    func dictionary<K: Hashable, V>() -> [K: V] where Element == Dictionary<K, V>.Element {
        var dictionary = [K: V]()
        for element in self {
            dictionary[element.key] = element.value
        }
        return dictionary
    }
    
}

infix operator ??! : NilCoalescingPrecedence

func ??!<T>(lhs: T?, rhs: Error) throws -> T {
    guard let lhs = lhs else { throw rhs }
    return lhs
}
