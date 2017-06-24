//
//  JSONArray.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

public struct JSONArray: Equatable {
    fileprivate var array: [JSON]
    
    public init() {
        array = [JSON]()
    }
    
    public init<S: Sequence>(_ sequence: S) where S.Iterator.Element == JSON {
        array = [JSON](sequence)
    }
}

extension JSONArray: Sequence {
    
    public func makeIterator() -> IndexingIterator<[JSON]> {
        return array.makeIterator()
    }
    
}

extension JSONArray: Collection {
    
    public var startIndex: Int {
        return array.startIndex
    }
    
    public var endIndex: Int {
        return array.endIndex
    }
    
    public subscript(position: Int) -> JSON {
        get {
            return array.indices.contains(position) ? array[position] : .null
        }
        set {
            if position < 0 { array[position] = newValue } // This will throw an exception, which is what we want
            while position > array.count - 1 { array.append(.null) }
            array[position] = newValue
        }
    }
    
    public func index(after i: Int) -> Int {
        return array.index(after: i)
    }
    
    public func map(_ transform: (JSON) throws -> JSON) rethrows -> JSONArray {
        return try JSONArray(array.map(transform))
    }
    
    public func filter(_ predicate: (JSON) throws -> Bool) rethrows -> JSONArray {
        return try JSONArray(array.filter(predicate))
    }
}

extension JSONArray: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: JSON...) {
        array = elements
    }
    
}

public func ==(lhs: JSONArray, rhs: JSONArray) -> Bool {
    return lhs.array == rhs.array
}
