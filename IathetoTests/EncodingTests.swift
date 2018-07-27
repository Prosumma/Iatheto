//
//  EncodingTests.swift
//  Iatheto
//
//  Created by Gregory Higley on 4/22/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import XCTest
import Iatheto

class EncodingTests: XCTestCase {
    
    func testEncoding() throws {
        let json: JSON = [1, 2, 3, nil, ["Amounts": [7, 9.8334]]]
        try print(json.encoded() as String)
    }
        
}
