//
//  Attributes.swift
//  Iatheto
//
//  Created by Gregory Higley on 4/22/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import Foundation

public extension JSON {
    
    init(value: [JSON]) {
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
    
    init(value: [String: JSON]) {
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
    
    init(value: Int) {
        self = .int(Int64(value))
    }
    
    var int: Int? {
        get {
            if case let .int(value) = self {
                return Int(value)
            } else {
                return nil
            }
        }
        set {
            if let int = newValue {
                self = .int(Int64(int))
            } else {
                self = .null
            }
        }
    }
    
    init(value: Int64) {
        self = .int(value)
    }
    
    var int64: Int64? {
        get {
            if case let .int(value) = self {
                return value
            } else {
                return nil
            }
        }
        set {
            if let int64 = newValue {
                self = .int(int64)
            } else {
                self = .null
            }
        }
    }
    
    init(value: Float) {
        self = .float(Decimal(Double(value)))
    }
    
    var float: Float? {
        get {
            if case let .float(value) = self {
                return value.floatValue
            } else {
                return nil
            }
        }
        set {
            if let float = newValue {
                self = .float(Decimal(Double(float)))
            } else {
                self = .null
            }
        }
    }
    
    init(value: Decimal) {
        self = .float(value)
    }
    
    var decimal: Decimal? {
        get {
            if case let .float(value) = self {
                return value
            } else {
                return nil
            }
        }
        set {
            if let decimal = newValue {
                self = .float(decimal)
            } else {
                self = .null
            }
        }
    }
    
    init(value: Double) {
        self = .float(Decimal(value))
    }
    
    var double: Double? {
        get {
            if case let .float(value) = self {
                return value.doubleValue
            } else {
                return nil
            }
        }
        set {
            if let double = newValue {
                self = .float(Decimal(double))
            } else {
                self = .null
            }
        }
    }
    
    init(value: String) {
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
