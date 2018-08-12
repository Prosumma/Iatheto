//
//  Attributes.swift
//  Iatheto
//
//  Created by Gregory Higley on 4/22/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import Foundation

public extension JSON {
    
    init(_ value: [JSON]) {
        self = .array(value)
    }
    
    var array: [JSON]? {
        get {
            if case let .array(value) = self {
                return value
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
    
    init(_ value: Bool) {
        self = .bool(value)
    }
    
    var bool: Bool? {
        get {
            if case let .bool(value) = self {
                return value
            } else {
                return nil
            }
        }
        set {
            if let bool = newValue {
                self = .bool(bool)
            } else {
                self = .null
            }
        }
    }
    
    init(_ value: [String: JSON]) {
        self = .dictionary(value)
    }
    
    var dictionary: [String: JSON]? {
        get {
            if case let .dictionary(value) = self {
                return value
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
    
    init(_ value: Int) {
        self = .number(Decimal(value))
    }
    
    var int: Int? {
        get {
            if case let .number(value) = self {
                return value.intValue
            } else {
                return nil
            }
        }
        set {
            if let int = newValue {
                self = .number(Decimal(int))
            } else {
                self = .null
            }
        }
    }
    
    init(_ value: Int64) {
        self = .number(Decimal(value))
    }
    
    var int64: Int64? {
        get {
            if case let .number(value) = self {
                return value.int64Value
            } else {
                return nil
            }
        }
        set {
            if let int64 = newValue {
                self = .number(Decimal(int64))
            } else {
                self = .null
            }
        }
    }
    
    init(_ value: Float) {
        self = .number(Decimal(Double(value)))
    }
    
    var float: Float? {
        get {
            if case let .number(value) = self {
                return value.floatValue
            } else {
                return nil
            }
        }
        set {
            if let float = newValue {
                self = .number(Decimal(Double(float)))
            } else {
                self = .null
            }
        }
    }
    
    init(_ value: Decimal) {
        self = .number(value)
    }
    
    var decimal: Decimal? {
        get {
            if case let .number(value) = self {
                return value
            } else {
                return nil
            }
        }
        set {
            if let decimal = newValue {
                self = .number(decimal)
            } else {
                self = .null
            }
        }
    }
    
    init(_ value: Double) {
        self = .number(Decimal(value))
    }
    
    var double: Double? {
        get {
            if case let .number(value) = self {
                return value.doubleValue
            } else {
                return nil
            }
        }
        set {
            if let double = newValue {
                self = .number(Decimal(double))
            } else {
                self = .null
            }
        }
    }
    
    var isNull: Bool {
        if case .null = self {
            return true
        }
        return false
    }
    
    init(_ value: NSNumber) {
        self = .number(value.decimalValue)
    }
    
    var number: NSNumber? {
        get {
            if case let .number(value) = self {
                return NSDecimalNumber(decimal: value)
            } else {
                return nil
            }
        }
        set {
            if let decimal = newValue {
                self = .number(decimal.decimalValue)
            } else {
                self = .null
            }
        }
    }
    
    init(_ value: String) {
        self = .string(value)
    }
    
    var string: String? {
        get {
            if case let .string(value) = self {
                return value
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
}
