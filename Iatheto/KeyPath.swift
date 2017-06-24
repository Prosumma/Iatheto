//
//  KeyPath.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

/**
 A `KeyPath` is a convenient way to subscript `JSON`. Instead of
 saying `json[3]["x"]`, one can say `json[3 +> "x"]`, where `+>`
 is a custom operator for constructing a `KeyPath`. In addition to
 the usual positional subscripts, `.last` is supported, whose meaning
 should be obvious.
 */
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
    
    public init(_ elems: KeyPathConvertible...) {
        self = .path(KeyPath.path(elems.map{ $0.iathetoKeyPath }).flatten())
    }
    
    public init<S: Sequence>(_ elems: S) where S.Iterator.Element: KeyPathConvertible {
        self = .path(KeyPath.path(elems.map{ $0.iathetoKeyPath }).flatten())
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

extension KeyPath: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: KeyPathConvertible...) {
        let elems = KeyPath.path(elements.map{ $0.iathetoKeyPath }).flatten()
        self = .path(elems)
    }
}

public protocol KeyPathConvertible {
    var iathetoKeyPath: KeyPath { get }
}

extension String: KeyPathConvertible {
    public var iathetoKeyPath: KeyPath { return .key(self) }
}

extension Int: KeyPathConvertible {
    public var iathetoKeyPath: KeyPath { return .index(self) }
}

precedencegroup KeyPathPrecedence {
    associativity: right
    higherThan: RangeFormationPrecedence
    lowerThan: AdditionPrecedence
}

infix operator +> : KeyPathPrecedence // This gives us right-association

func +>(lhs: KeyPathConvertible, rhs: KeyPathConvertible) -> KeyPath {
    return KeyPath(lhs, rhs)
}

func +>(lhs: KeyPath, rhs: KeyPathConvertible) -> KeyPath {
    return KeyPath(lhs, rhs)
}

func +>(lhs: KeyPathConvertible, rhs: KeyPath) -> KeyPath {
    return KeyPath(lhs, rhs)
}

func +>(lhs: KeyPath, rhs: KeyPath) -> KeyPath {
    return KeyPath(lhs, rhs)
}

