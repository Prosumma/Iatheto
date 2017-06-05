//
//  LiteralTests.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/4/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import XCTest
@testable import Iatheto

class LiteralTests: XCTestCase {
    
    func testLiteralBoolean() {
        let t: JSON = true
        XCTAssertTrue(t.bool!)
    }
    
    func testLiteralString() {
        let s: JSON = "JSON"
        XCTAssertEqual(s.string!, "JSON")
    }
    
    func testLiteralFloat() {
        let f: JSON = 32.5
        XCTAssertEqual(f.float!, 32.5)
    }    
    
    func testLiteralInteger() {
        let i: JSON = 48
        XCTAssertEqual(i.int!, 48)
    }
}
