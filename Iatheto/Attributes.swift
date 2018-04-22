//
//  Attributes.swift
//  Iatheto
//
//  Created by Gregory Higley on 4/22/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import Foundation

public extension JSON {
    
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
    
    var float: Float? {
        get {
            if case let .float(value) = self {
                return Float(value)
            } else {
                return nil
            }
        }
        set {
            if let float = newValue {
                self = .float(Double(float))
            } else {
                self = .null
            }
        }
    }
    
    var double: Double? {
        get {
            if case let .float(value) = self {
                return value
            } else {
                return nil
            }
        }
        set {
            if let double = newValue {
                self = .float(double)
            } else {
                self = .null
            }
        }
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
