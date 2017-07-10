//
//  JSONArray.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

/**
 `JSONArray` is very similar to `Array<JSON>`, except that
 it never fails when a positive index is subscripted, either
 for access or assignment.
 
 If a positive index is outside the bounds of the array,
 `JSONArray` returns `JSON.null`. If an assignment is
 made at a positive index that is outside the bounds of 
 the array, the array is filled with `JSON.null`.
 
 ```
 var array = JSONArray()
 array[3] = "4th item!"
 ```
 
 After `array[3]` is assigned in the example above, `array` is
 equivalent to `[JSON.null, JSON.null, JSON.null, JSON.string("4th item!")]`.
 */
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
            while position > array.count - 1 {
                array.append(.null)
            }
            array[position] = newValue
        }
    }
    
    public subscript(keypath: KeyPath) -> JSON {
        get {
            let keypaths = keypath.flatten()
            switch keypaths.count {
            case 0:
                return .null
            case 1:
                if let p = keypaths[0].position(in: self) {
                    return self[p]
                }
                return .null
            default:
                if let p = keypaths[0].position(in: self) {
                    let rest = KeyPath(keypaths.suffix(from: 1))
                    return self[p][rest]
                }
                return .null
            }
        }
        set {
            let keypaths = keypath.flatten()
            switch keypaths.count {
            case 0:
                return
            case 1:
                if let p = keypaths[0].position(in: self) {
                    array[p] = newValue
                }
            default:
                if let p = keypaths[0].position(in: self) {
                    let rest = KeyPath(keypaths.suffix(from: 1))
                    array[p][rest] = newValue
                }
            }
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
