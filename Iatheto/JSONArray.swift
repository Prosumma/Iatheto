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
            while position < array.count - 1 {
                array.append(.null)
            }
            array[position] = newValue
        }
    }
    
    public subscript(keypath: KeyPath) -> JSON {
        get {
            let keypaths = keypath.flatten()
            if keypaths.count == 0 { return .null }
            let p: Int
            switch keypaths[0] {
            case .index(let i): p = i
            case .last: p = count - 1
            default: return .null
            }
            var json = self[p]
            for keypath in keypaths.suffix(from: 1) {
                json = json[keypath]
            }
            return json
        }
        set {
            // TODO
        }
    }
    
    public func index(after i: Int) -> Int {
        return array.index(after: i)
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
