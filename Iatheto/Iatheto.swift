//
//  Iatheto.swift
//  Iatheto
//
//  Created by Gregory Higley on 3/25/16.
//  Copyright © 2016 Gregory Higley. All rights reserved.
//

import Foundation

public enum JSONError: ErrorType {
    case UnknownType(AnyObject)
    case UnexpectedType(JSON)
    case UnequalCollections // for JSONAssignable with collections
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
    static func decode(json: JSON, state: Any?) -> Self?
}

/**
 Assignment is the act of changing a value by assigning
 JSON to it.
 
 - note: Unlike decoding, assignment requires the JSON
 to be strictly compatible with the assigned type (as
 defined by that type itself). Otherwise, conforming 
 implementations should throw `JSONError.UnexpectedType`.
 If an invalid `state` parameter is given, implementors
 should fail a runtime assertion.
*/
public protocol JSONAssignable {
    mutating func assign(json: JSON, state: Any?) throws
}

/**
 Encoding is the act of turning something into JSON.
 
 - note: Encoding is assumed always to succeed, since 
 types inherently know how to encode themselves. If
 an invalid `state` parameter is passed, clients should
 either return `JSON.Null` or fail a runtime assertion.
*/
public protocol JSONEncodable {
    func encode(state: Any?) -> JSON
}

public protocol JSONCodable: JSONEncodable, JSONDecodable {}

extension JSONDecodable {
    public static func decode(json: JSON) -> Self? {
        return decode(json, state: nil)
    }
}

extension JSONAssignable {
    public mutating func assign(json: JSON) throws {
        try assign(json, state: nil)
    }
}

extension JSONEncodable {
    public func encode() -> JSON {
        return encode(nil)
    }
    
    public func encode(state: Any?) throws -> NSData {
        let json: JSON = self.encode(state)
        return try json.rawData()
    }
    
    public func encode() throws -> NSData {
        return try encode(nil)
    }
}

/**
 A thunk between `JSONDecodable` and an underlying array.
 */
public struct JSONDecodableArray<Element: JSONDecodable>: JSONDecodable, JSONAssignable {
    public var array: [Element]

    public init() {
        array = [Element]()
    }
    
    public init?(json: JSON, state: Any?) {
        if let array = [Element].decode(json, state: state) {
            self.array = array
        } else {
            return nil
        }
    }
    
    public static func decode(json: JSON, state: Any?) -> JSONDecodableArray? {
        return self.init(json: json, state: state)
    }
    
    public mutating func assign(json: JSON, state: Any?) throws {
        if let array = [Element].decode(json, state: state) {
            self.array = array
        } else {
            throw JSONError.UnexpectedType(json)
        }
    }
}

/**
 A thunk between `JSONDecodable`, `JSONEncodable`, and an underlying array.
 */
public struct JSONCodableArray<Element: JSONCodable>: JSONCodable, JSONAssignable {
    public var array: [Element]
    
    public init() {
        array = [Element]()
    }
    
    public init(_ array: [Element]) {
        self.array = array
    }
    
    public init?(json: JSON, state: Any?) {
        if let array = [Element].decode(json, state: state) {
            self.array = array
        } else {
            return nil
        }
    }
    
    public func encode(state: Any?) -> JSON {
        return array.encode(state)
    }
    
    public static func decode(json: JSON, state: Any?) -> JSONCodableArray? {
        return self.init(json: json, state: state)
    }
    
    public mutating func assign(json: JSON, state: Any?) throws {
        if let array = [Element].decode(json, state: state) {
            self.array = array
        } else {
            throw JSONError.UnexpectedType(json)
        }
    }
}

/**
 A thunk between `JSONEncodable` and an underlying sequence.
 */
public struct JSONEncodableSequence: JSONEncodable {
    private let thunk: Any? -> JSON
    
    public init<S: SequenceType where S.Generator.Element: JSONEncodable>(_ sequence: S) {
        thunk = { state in sequence.encode(state) }
    }
    
    public func encode(state: Any?) -> JSON {
        return thunk(state)
    }
}

/**
 This type serves as a thunk between `JSONDecodable` and `Dictionary`.
*/
public struct JSONDecodableDictionary<Value: JSONDecodable>: JSONDecodable, JSONAssignable {
    public var dictionary: [String: Value]
    
    public init() {
        dictionary = [:]
    }
    
    public init?(json: JSON, state: Any?) {
        if let dictionary = [String: Value](json: json, state: state) {
            self.dictionary = dictionary
        } else {
            return nil
        }
    }
    
    public static func decode(json: JSON, state: Any?) -> JSONDecodableDictionary? {
        return self.init(json: json, state: state)
    }
    
    public mutating func assign(json: JSON, state: Any?) throws {
        if let dictionary = [String: Value](json: json, state: state) {
            self.dictionary = dictionary
        } else {
            throw JSONError.UnexpectedType(json)
        }
    }
}

/**
 This type serves as a thunk between `JSONDecodable` and `JSONEncodable` on the one hand, and `Dictionary` on the other.
*/
public struct JSONCodableDictionary<Value: JSONCodable>: JSONCodable, JSONAssignable {
    public var dictionary: [String: Value]
    
    public init() {
        dictionary = [:]
    }
    
    public init(_ dictionary: [String: Value]) {
        self.dictionary = dictionary
    }
    
    public init?(json: JSON, state: Any? = nil) {
        if let dictionary = [String: Value](json: json, state: state) {
            self.dictionary = dictionary
        } else {
            return nil
        }
    }
    
    public mutating func assign(json: JSON, state: Any?) throws {
        if let dictionary = [String: Value](json: json, state: state) {
            self.dictionary = dictionary
        } else {
            throw JSONError.UnexpectedType(json)
        }
    }
    
    public static func decode(json: JSON, state: Any?) -> JSONCodableDictionary? {
        return self.init(json: json, state: state)
    }

    public func encode(state: Any?) -> JSON {
        return dictionary.encode(state)
    }
}

/**
 This type serves as a thunk between `JSONEncodable` and `Dictionary`.
*/
public struct JSONEncodableDictionary<Value: JSONEncodable>: JSONEncodable {
    public var dictionary: [String: Value]

    public init(_ dictionary: [String: Value]) {
        self.dictionary = dictionary
    }

    public func encode(state: Any?) -> JSON {
        return dictionary.encode(state)
    }
}

extension Optional where Wrapped: JSONEncodable {
    public func encode(state: Any? = nil) -> JSON {
        return self?.encode(state) ?? .Null
    }
}

extension Optional where Wrapped: JSONDecodable {
    public static func decode(json: JSON, state: Any? = nil) -> Wrapped? {
        return Wrapped.decode(json, state: state)
    }
}

extension Optional where Wrapped: JSONAssignable {
    public mutating func assign(json: JSON, state: Any? = nil) throws {
        try self?.assign(json, state: state)
    }
}

extension SequenceType where Generator.Element: JSONEncodable {
    public func encode(state: Any? = nil) -> JSON {
        return .Array(map { $0.encode(state) })
    }
}

extension SequenceType where Generator.Element: JSONDecodable {
    public static func decode(json: JSON, state: Any? = nil) -> [Generator.Element]? {
        if case .Array(let array) = json {
            var elements = Array<Generator.Element>()
            for json in array {
                if let element = Generator.Element.decode(json, state: state) {
                    elements.append(element)
                }
            }
            return elements
        } else {
            return nil
        }
    }
}

extension SequenceType where Generator.Element == JSON {
    public func decode<T: JSONDecodable>(state: Any? = nil) -> [T]? {
        var elements = [T]()
        for json in self {
            if let element = T.decode(json, state: state) {
                elements.append(element)
            }
        }
        return elements
    }
}

extension CollectionType where Self: MutableCollectionType, Generator.Element: JSONAssignable, Index == Int, Index.Distance == Int {
    public mutating func assign(json: JSON, state: Any? = nil) throws {
        guard case .Array(let array) = json else {
            throw JSONError.UnexpectedType(json)
        }
        if count != array.count {
            throw JSONError.UnequalCollections
        }
        for i in 0..<count {
            try self[i].assign(array[i], state: state)
        }
    }
}

extension Dictionary where Value: JSONDecodable {
    public init?(json: JSON, state: Any? = nil) {
        if case .Dictionary(let dictionary) = json {
            self.init()
            for (key, json) in dictionary {
                if let value = Value.decode(json, state: state) {
                    self[key as! Key] = value
                }
            }
        } else {
            return nil
        }
    }
}

extension Dictionary where Value: JSONAssignable {
    public mutating func assign(json: JSON, state: Any? = nil) throws {
        guard case .Dictionary(let dictionary) = json else {
            throw JSONError.UnexpectedType(json)
        }
        for key in keys {
            guard let json = dictionary[String(key)] else {
                throw JSONError.UnequalCollections
            }
            try self[key]?.assign(json, state: state)
        }
    }
}

extension Dictionary where Value: JSONEncodable {
    public func encode(state: Any? = nil) -> JSON {
        var json = JSON()
        for (key, value) in self {
            json[String(key)] = value.encode(state)
        }
        return json
    }
}

extension Set where Element: JSONDecodable {
    public static func decode(json: JSON, state: Any? = nil) -> Set? {
        if case .Array(let array) = json {
            var elements = Array<Generator.Element>()
            for json in array {
                if let element = Generator.Element.decode(json, state: state) {
                    elements.append(element)
                }
            }
            return self.init(elements)
        } else {
            return nil
        }
    }
}

extension NSNull: JSONEncodable, JSONAssignable {
    public func assign(json: JSON, state: Any?) throws {
        guard case .Null = json else {
            throw JSONError.UnexpectedType(json)
        }
    }
    
    public func encode(state: Any?) -> JSON {
        return .Null
    }
}

extension String: JSONCodable, JSONAssignable {
    public init?(json: JSON, state: Any?) {
        guard let string = json.string else {
            return nil
        }
        self = string
    }
    
    public mutating func assign(json: JSON, state: Any?) throws {
        guard case .String(let string) = json else {
            throw JSONError.UnexpectedType(json)
        }
        self = string
    }
    
    public static func decode(json: JSON, state: Any?) -> String? {
        return self.init(json: json, state: state)
    }
    
    public func encode(state: Any?) -> JSON {
        return .String(self)
    }
}

extension NSNumber: JSONEncodable {
    public func encode(state: Any?) -> JSON {
        return .Number(self)
    }
}

extension Int: JSONCodable, JSONAssignable {
    public init?(json: JSON, state: Any?) {
        guard let int = json.int else {
            return nil
        }
        self = int
    }
    
    public mutating func assign(json: JSON, state: Any?) throws {
        guard let int = json.int else {
            throw JSONError.UnexpectedType(json)
        }
        self = int
    }
    
    public static func decode(json: JSON, state: Any?) -> Int? {
        return self.init(json: json, state: state)
    }
    
    public func encode(state: Any?) -> JSON {
        return .Number(NSNumber(integer: self))
    }
}

extension Double: JSONCodable, JSONAssignable {
    public init?(json: JSON, state: Any?) {
        guard let double = json.double else {
            return nil
        }
        self = double
    }
    
    public mutating func assign(json: JSON, state: Any?) throws {
        guard let double = json.double else {
            throw JSONError.UnexpectedType(json)
        }
        self = double
    }
    
    public static func decode(json: JSON, state: Any?) -> Double? {
        return self.init(json: json, state: state)
    }
    
    public func encode(state: Any?) -> JSON {
        return .Number(NSNumber(double: self))
    }
}

extension Float: JSONCodable, JSONAssignable {
    public init?(json: JSON, state: Any?) {
        guard let float = json.float else {
            return nil
        }
        self = float
    }
    
    public mutating func assign(json: JSON, state: Any?) throws {
        guard let float = json.float else {
            throw JSONError.UnexpectedType(json)
        }
        self = float
    }
    
    public static func decode(json: JSON, state: Any?) -> Float? {
        return self.init(json: json, state: state)
    }
    
    public func encode(state: Any?) -> JSON {
        return .Number(NSNumber(float: self))
    }
}

public indirect enum JSON: CustomStringConvertible, CustomDebugStringConvertible, JSONCodable, JSONAssignable {
    public typealias JSONDictionary = Swift.Dictionary<Swift.String, JSON>
    public typealias JSONArray = Swift.Array<JSON>
    
    /**
     Used for converting JSON strings into numbers.
    */
    public static var encodingNumberFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return numberFormatter
    }()
    
    /**
     Used for converting JSON strings into dates.
    */
    public static var encodingDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        return dateFormatter
    }()
    
    /**
     Used for converting dates into JSON strings.
    */
    public static var decodingDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        return dateFormatter
    }()
    
    case Null
    case String(Swift.String)
    case Number(NSNumber)
    case Array(JSONArray)
    case Dictionary(JSONDictionary)
    
    public init() {
        self = .Dictionary([:])
    }
    
    public init?(json: JSON, state: Any? = nil) {
        self = json
    }
    
    public init<S: SequenceType where S.Generator.Element == JSON>(sequence: S) {
        self = .Array(JSONArray(sequence))
    }
    
    public init(data: NSData) throws {
        self = try JSON(NSJSONSerialization.JSONObjectWithData(data, options: []))
    }
    
    /**
     Initializes `JSON` with a string containing well-formed JSON.
    */
    public init(string: Swift.String) throws {
        try self.init(data: string.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    public init(_ value: AnyObject?) throws {
        guard let value = value else {
            self = .Null
            return
        }
        
        if let dictionary = value as? [Swift.String: AnyObject] {
            var json = JSONDictionary()
            for (key, value) in dictionary {
                json[key] = try JSON(value)
            }
            self = .Dictionary(json)
        } else if let array = value as? [AnyObject] {
            self = .Array(try array.map { try JSON($0) })
        } else if let string = value as? Swift.String {
            self = .String(string)
        } else if let number = value as? NSNumber {
            self = .Number(number)
        } else if value is NSNull {
            self = .Null
        } else {
            throw JSONError.UnknownType(value)
        }
    }
    
    public mutating func assign(json: JSON, state: Any?) throws {
        self = json
    }
    
    public mutating func merge(json: JSON) throws {
        switch self {
        case .Array(let array):
            var this = array
            if case .Array(let other) = json {
                this.appendContentsOf(other)
                self = .Array(this)
            } else {
                throw JSONError.UnexpectedType(json)
            }
        case .Dictionary(let dictionary):
            var this = dictionary
            if case .Dictionary(let other) = json {
                for (key, value) in other {
                    this[key] = value
                }
                self = .Dictionary(this)
            } else {
                throw JSONError.UnexpectedType(json)
            }
        default:
            throw JSONError.UnexpectedType(self)
        }
    }
    
    public var string: Swift.String? {
        get {
            if case .String(let string) = self {
                return string
            } else {
                return nil
            }
        }
        set {
            if let string = newValue {
                self = .String(string)
            } else {
                self = .Null
            }
        }
    }
    
    public func dateWithFormatter(formatter: NSDateFormatter) -> NSDate? {
        guard let string = self.string else { return nil }
        return formatter.dateFromString(string)
    }
    
    public mutating func setDate(date: NSDate?, withFormatter formatter: NSDateFormatter) {
        guard let date = date else {
            self = .Null
            return
        }
        self = .String(formatter.stringFromDate(date))
    }
    
    public var date: NSDate? {
        get {
            return dateWithFormatter(JSON.encodingDateFormatter)
        }
        set {
            setDate(newValue, withFormatter: JSON.decodingDateFormatter)
        }
    }
    
    public var number: NSNumber? {
        get {
            switch self {
            case .Number(let number): return number
            case .String(let string): return JSON.encodingNumberFormatter.numberFromString(string)
            default: return nil
            }
        }
        set {
            if let number = newValue {
                self = .Number(number)
            } else {
                self = .Null
            }
        }
    }
    
    public var array: JSONArray? {
        get {
            if case .Array(let array) = self {
                return array
            } else {
                return nil
            }
        }
        set {
            if let array = newValue {
                self = .Array(array)
            } else {
                self = .Null
            }
        }
    }
    
    public var dictionary: JSONDictionary? {
        get {
            if case .Dictionary(let dictionary) = self {
                return dictionary
            } else {
                return nil
            }
        }
        set {
            if let dictionary = newValue {
                self = .Dictionary(dictionary)
            } else {
                self = .Null
            }
        }
    }
    
    public var bool: Bool? {
        get {
            return number?.boolValue
        }
        set {
            if let bool = newValue {
                number = NSNumber(bool: bool)
            } else {
                self = .Null
            }
        }
    }
    
    public var int: Int? {
        get {
            return number?.integerValue
        }
        set {
            if let int = newValue {
                number = NSNumber(integer: int)
            } else {
                self = .Null
            }
        }
    }
    
    public var double: Double? {
        get {
            return number?.doubleValue
        }
        set {
            if let double = newValue {
                number = NSNumber(double: double)
            } else {
                self = .Null
            }
        }
    }
    
    public var float: Float? {
        get {
            return number?.floatValue
        }
        set {
            if let float = newValue {
                number = NSNumber(float: float)
            } else {
                self = .Null
            }
        }
    }
    
    public var null: NSNull? {
        get {
            guard case .Null = self else {
                return nil
            }
            return NSNull()
        }
        set {
            self = .Null
        }
    }
    
    public subscript(index: Int) -> JSON {
        get {
            if case .Array(let array) = self {
                return array[index]
            } else {
                return JSON.Null
            }
        }
        set {
            array![index] = newValue
        }
    }
    
    public subscript(key: Swift.String) -> JSON {
        get {
            if case .Dictionary(let dictionary) = self {
                return dictionary[key] ?? JSON.Null
            } else {
                return JSON.Null
            }
        }
        set {
            dictionary![key] = newValue
        }
    }
    
    private var value: AnyObject {
        switch self {
        case .Null:
            return NSNull()
        case .String(let string):
            return string
        case .Number(let number):
            return number
        case .Array(let array):
            return array.map { $0.value }
        case .Dictionary(let dictionary):
            var object = Swift.Dictionary<Swift.String, AnyObject>()
            for (key, json) in dictionary {
                object[key] = json.value
            }
            return object
        }
    }
    
    public func rawData(options: NSJSONWritingOptions = []) throws -> NSData {
        return try NSJSONSerialization.dataWithJSONObject(value, options: options)
    }
    
    public static func decode(json: JSON, state: Any?) -> JSON? {
        return self.init(json: json, state: state)
    }
    
    public func encode(state: Any?) -> JSON {
        return self
    }
    
    public var description: Swift.String {
        do {
            return try Swift.String(data: rawData(.PrettyPrinted), encoding: NSUTF8StringEncoding)!
        } catch _ {
            return ""
        }
    }
    
    public var debugDescription: Swift.String {
        return description
    }
    
}

extension JSON: StringLiteralConvertible {
    
    public init(stringLiteral value: StringLiteralType) {
        try! self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        try! self.init(value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        try! self.init(value)
    }
    
}

extension JSON: IntegerLiteralConvertible {
    
    public init(integerLiteral value: IntegerLiteralType) {
        try! self.init(value)
    }
    
}

extension JSON: FloatLiteralConvertible {
    
    public init(floatLiteral value: FloatLiteralType) {
        try! self.init(value)
    }
    
}

extension JSON: BooleanLiteralConvertible {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        try! self.init(value)
    }
    
}

extension JSON: ArrayLiteralConvertible {
    
    public init(arrayLiteral elements: AnyObject...) {
        try! self.init(elements)
    }
    
}

extension JSON: DictionaryLiteralConvertible {
    
    public init(dictionaryLiteral elements: (Swift.String, AnyObject)...) {
        var dictionary = JSONDictionary()
        for element in elements {
            dictionary[element.0] = try! JSON(element.1)
        }
        self = .Dictionary(dictionary)
    }
    
}

extension JSON: NilLiteralConvertible {
    
    public init(nilLiteral: ()) {
        self = .Null
    }
    
}

