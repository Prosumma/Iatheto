//
//  EquatableTests.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/4/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import XCTest
@testable import Iatheto

class EquatableTests: XCTestCase {
    
    func testEquatableJSONNumbers() {
        let n1: JSON = 33
        let n2: JSON = 33.0
        XCTAssertEqual(n1, n2)
    }
    
    func testEquatableJSONStrings() {
        let s1: JSON = "JSON"
        let s2: JSON = "JSON"
        XCTAssertEqual(s1, s2)
    }
    
    func testEquatableJSONArrays() {
        do {
            let a1 = try JSON(parsing: "[7, \"JSON\"]  ")
            let a2 = try JSON(parsing: "   [7,\"JSON\"]")
            XCTAssertEqual(a1, a2)
        } catch let e {
            XCTFail(String(describing: e))
        }
    }
    
    func testEquatableJSONDictionaries() {
        let literal = "{\"array\": [9, 11, 14], \"string\": \"JSON\"}"
        do {
            let d1 = try JSON(parsing: literal)
            let d2 = try JSON(parsing: literal)
            XCTAssertEqual(d1, d2)
        } catch let e {
            XCTFail(String(describing: e))
        }
    }
    
    func testEquatableJSONNulls() {
        let null1 = JSON.null
        let null2: JSON = nil
        XCTAssertEqual(null1, null2)
    }
    
}
