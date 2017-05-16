//
//  Envelope.swift
//  Iatheto
//
//  Created by Gregory Higley on 3/1/16.
//  Copyright © 2016 Gregory Higley. All rights reserved.
//

import Foundation
@testable import Iatheto

struct Envelope<T: JSONCodable>: JSONCodable {
    let content: T?
    
    init(content: T?) {
        self.content = content
    }
    
    init?(json: JSON, state: Any? = nil) {
        let content = json["content"]
        if case .null = content { return nil }
        self.content = T.decode(content)
    }
    
    static func decode(_ json: JSON, state: Any?) -> Envelope? {
        return self.init(json: json, state: state)
    }

    func encode(_ state: Any? = nil) -> JSON {
        var json = JSON()
        if let content = content {
            json["content"] = content.encode()
        }
        return json
    }
}

