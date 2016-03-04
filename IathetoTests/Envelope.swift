//
//  Envelope.swift
//  Iatheto
//
//  Created by Gregory Higley on 3/1/16.
//  Copyright © 2016 Gregory Higley. All rights reserved.
//

import Foundation
@testable import Iatheto

struct Envelope<T: JSONEncodable where T: JSONDecodable>: JSONEncodable, JSONDecodable {
    let content: T?
    
    init(content: T?) {
        self.content = content
    }
    
    init(json: JSON) throws {
        let content = json["content"]
        if case .Null = content {
            self.content = nil
            return
        }
        self.content = try T.encode(content)
    }
    
    static func encode(json: JSON) throws -> Envelope {
        return try self.init(json: json)
    }

    func decode() -> JSON {
        var json = JSON()
        if let content = content {
            json["content"] = content.decode()
        }
        return json
    }
}

