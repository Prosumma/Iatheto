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
    
    func testBooleanLiteral() {
        let t: JSON = true
        XCTAssertTrue(t.bool!)
    }
    
    func testStringLiteral() {
        let s: JSON = "JSON"
        XCTAssertEqual(s.string!, "JSON")
    }
    
    func testFloatLiteral() {
        let f: JSON = 32.5
        XCTAssertEqual(f.float!, 32.5)
    }    
    
    func testIntegerLiteral() {
        let i: JSON = 48
        XCTAssertEqual(i.int!, 48)
    }
    
    func testNilLiteral() {
        let n: JSON = nil
        XCTAssertEqual(n, nil)
    }
    
    func testArrayLiteral() {
        let a: JSON = [JSON.string("ok"), JSON.null]
        XCTAssertTrue(a.array != nil)
    }
}
