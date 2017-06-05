//
//  JSONDictionary.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

public struct JSONDictionary: Equatable {
    fileprivate var dictionary: [String: JSON]
    
    public init() {
        dictionary = [String: JSON]()
    }
    
    public init(_ dictionary: [String: JSON]) {
        self.dictionary = dictionary
    }
}

extension JSONDictionary: Sequence {
    
    public func makeIterator() -> DictionaryIterator<String, JSON> {
        return dictionary.makeIterator()
    }
    
}

extension JSONDictionary: Collection {
    
    public var startIndex: Dictionary<String, JSON>.Index {
        return dictionary.startIndex
    }
    
    public var endIndex: Dictionary<String, JSON>.Index {
        return dictionary.endIndex
    }
    
    public subscript(position: Dictionary<String, JSON>.Index) -> Dictionary<String, JSON>.Element {
        return dictionary[position]
    }
    
    public func index(after i: Dictionary<String, JSON>.Index) -> Dictionary<String, JSON>.Index {
        return dictionary.index(after: i)
    }
    
    public subscript(key: String) -> JSON {
        get {
            return dictionary[key] ?? .null
        }
        set {
            dictionary[key] = newValue
        }
    }
    
}

extension JSONDictionary: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, JSON)...) {
        dictionary = [String: JSON]()
        for (key, json) in elements {
            dictionary[key] = json
        }
    }
    
}

public func ==(lhs: JSONDictionary, rhs: JSONDictionary) -> Bool {
    return lhs.dictionary == rhs.dictionary
}

