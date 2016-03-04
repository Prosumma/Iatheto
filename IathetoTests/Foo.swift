//
//  Foo.swift
//  Iatheto
//
//  Created by Gregory Higley on 3/1/16.
//  Copyright © 2016 Gregory Higley. All rights reserved.
//

import Foundation
@testable import Iatheto

struct Foo: JSONEncodable, JSONAssignable, JSONDecodable, Equatable {
    private(set) var name: String = ""
    
    init(name: String) {
        self.name = name
    }

    init() {}
    
    init(json: JSON) throws {
        name = json["name"].string!
    }
    
    mutating func setWithJSON(json: JSON) throws {
        name = json["name"].string!
    }
    
    static func encode(json: JSON) throws -> Foo {
        return try self.init(json: json)
    }
    
    func decode() -> JSON {
        var json = JSON()
        json["name"].string = name
        return json
    }
}

func ==(lhs: Foo, rhs: Foo) -> Bool {
    return lhs.name == rhs.name
}