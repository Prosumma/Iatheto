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
}

public protocol JSONEncodable {
    init(json: JSON) throws
}

public protocol JSONDecodable {
    func decode() -> JSON
}

/**
 A thunk between `JSONEncodable` and an underlying array.
 */
public struct JSONEncodableArray<Element: JSONEncodable>: JSONEncodable {
    public var array: [Element]
    
    public init(json: JSON) throws {
        array = try [Element](json: json)
    }
}

/**
 A thunk between `JSONEncodable`, `JSONDecodable`, and an underlying array.
 */
public struct JSONEncodableDecodableArray<Element: JSONEncodable where Element: JSONDecodable>: JSONEncodable, JSONDecodable {
    public var array: [Element]
    
    public init(_ array: [Element]) {
        self.array = array
    }
    
    public init(json: JSON) throws {
        array = try [Element](json: json)
    }
    
    public func decode() -> JSON {
        return array.decode()
    }
}

/**
 A thunk between `JSONDecodable` and an underlying sequence.
 */
public struct JSONDecodableSequence: JSONDecodable {
    private let thunk: () -> JSON
    
    public init<S: SequenceType where S.Generator.Element: JSONDecodable>(_ sequence: S) {
        thunk = { sequence.decode() }
    }
    
    public func decode() -> JSON {
        return thunk()
    }
}

extension Array where Element: JSONEncodable {
    public init(json: JSON) throws {
        guard case .Array(let array) = json else {
            throw JSONError.UnexpectedType(json)
        }
        let elements = try array.map { try Element(json: $0) }
        self.init(elements)
    }
}

/**
 This type serves as a thunk between `JSONEncodable` and `Dictionary`.
*/
public struct JSONEncodableDictionary<Value: JSONEncodable>: JSONEncodable {
    public var dictionary: [String: Value]
    
    public init(json: JSON) throws {
        dictionary = try [String: Value](json: json)
    }
}

/**
 This type serves as a thunk between `JSONEncodable` and `JSONDecodable` on the one hand, and `Dictionary` on the other.
*/
public struct JSONEncodableDecodableDictionary<Value: JSONEncodable where Value: JSONDecodable>: JSONEncodable, JSONDecodable {
    public var dictionary: [String: Value]
    
    public init(_ dictionary: [String: Value]) {
        self.dictionary = dictionary
    }
    
    public init(json: JSON) throws {
        dictionary = try [String: Value](json: json)
    }

    public func decode() -> JSON {
        return dictionary.decode()
    }
}

/**
 This type serves as a thunk between `JSONDecodable` and `Dictionary`.
*/
public struct JSONDecodableDictionary<Value: JSONDecodable>: JSONDecodable {
    public var dictionary: [String: Value]

    public init(_ dictionary: [String: Value]) {
        self.dictionary = dictionary
    }

    public func decode() -> JSON {
        return dictionary.decode()
    }
}

extension Dictionary where Value: JSONEncodable {
    public init(json: JSON) throws {
        guard case .Dictionary(let dictionary) = json else {
            throw JSONError.UnexpectedType(json)
        }
        self.init()
        for (key, json) in dictionary {
            self[key as! Key] = try Value(json: json)
        }
    }
}

extension Dictionary where Value: JSONDecodable {
    public func decode() -> JSON {
        var json = JSON()
        for (key, value) in self {
            json[String(key)] = value.decode()
        }
        return json
    }
}

extension SequenceType where Generator.Element: JSONDecodable {
    public func decode() -> JSON {
        return .Array(map { $0.decode() })
    }
}

public indirect enum JSON: CustomStringConvertible, CustomDebugStringConvertible {
    public typealias JSONDictionary = Swift.Dictionary<Swift.String, JSON>
    public typealias JSONArray = Swift.Array<JSON>
    
    case Null
    case String(Swift.String)
    case Number(NSNumber)
    case Array(JSONArray)
    case Dictionary(JSONDictionary)
    
    public init() {
        self = .Dictionary([:])
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
    
    public var stringValue: Swift.String {
        get {
            if case .String(let string) = self {
                return string
            } else {
                return ""
            }
        }
        set {
            self = .String(newValue)
        }
    }
    
    public var number: NSNumber? {
        get {
            if case .Number(let number) = self {
                return number
            } else {
                return nil
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
    
    public var numberValue: NSNumber {
        get {
            if case .Number(let number) = self {
                return number
            } else {
                return 0
            }
        }
        set {
            self = .Number(newValue)
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
    
    public var arrayValue: JSONArray {
        get {
            if case .Array(let array) = self {
                return array
            } else {
                return JSONArray()
            }
        }
        set {
            self = .Array(newValue)
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
    
    public var dictionaryValue: JSONDictionary {
        get {
            if case .Dictionary(let dictionary) = self {
                return dictionary
            } else {
                return JSONDictionary()
            }
        }
        set {
            self = .Dictionary(newValue)
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
    
    public var boolValue: Bool {
        get {
            return numberValue.boolValue
        }
        set {
            numberValue = NSNumber(bool: newValue)
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
    
    public var intValue: Int {
        get {
            return numberValue.integerValue
        }
        set {
            numberValue = NSNumber(integer: newValue)
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
    
    public var doubleValue: Double {
        get {
            return numberValue.doubleValue
        }
        set {
            numberValue = NSNumber(double: newValue)
        }
    }
    
    public var float: Float? {
        get {
            return number?.floatValue
        }
        set {
            if let float = newValue {
                numberValue = NSNumber(float: float)
            } else {
                self = .Null
            }
        }
    }
    
    public var floatValue: Float {
        get {
            return numberValue.floatValue
        }
        set {
            numberValue = NSNumber(float: newValue)
        }
    }
    
    public var null: Bool {
        get {
            if case .Null = self {
                return true
            } else {
                return false
            }
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
            arrayValue[index] = newValue
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
            dictionaryValue[key] = newValue
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

