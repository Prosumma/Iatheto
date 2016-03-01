//
//  Foo.swift
//  Iatheto
//
//  Created by Gregory Higley on 3/1/16.
//  Copyright © 2016 Gregory Higley. All rights reserved.
//

import Foundation
@testable import Iatheto

struct Foo: JSONEncodable, JSONDecodable, Equatable {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(json: JSON) throws {
        name = json["name"].string!
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