//
//  Foo.swift
//  Iatheto
//
//  Created by Gregory Higley on 3/1/16.
//  Copyright © 2016 Gregory Higley. All rights reserved.
//

import Foundation
@testable import Iatheto

struct Foo: JSONCodable, JSONAssignable, Equatable {
    private(set) var name: String = ""
    
    init(name: String) {
        self.name = name
    }

    init() {}
    
    init?(json: JSON, state: Any? = nil) {
        name = json["name"].string!
    }
    
    mutating func assign(json: JSON, state: Any? = nil) throws {
        name = json["name"].string!
    }
    
    static func decode(json: JSON, state: Any? = nil) -> Foo? {
        return self.init(json: json, state: state)
    }
    
    func encode(state: Any?) -> JSON {
        var json = JSON()
        json["name"].string = name
        return json
    }
}

func ==(lhs: Foo, rhs: Foo) -> Bool {
    return lhs.name == rhs.name
}