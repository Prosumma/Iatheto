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
    
    func testUnequatableJSONNumbers() {
        let n1: JSON = 33
        let n2: JSON = 944.36
        XCTAssertNotEqual(n1, n2)
    }
    
    func testEquatableJSONStrings() {
        let s1: JSON = "JSON"
        let s2: JSON = "JSON"
        XCTAssertEqual(s1, s2)
    }
    
    func testUnequatableJSONStrings() {
        let s1: JSON = "JSON"
        let s2: JSON = "XML"
        XCTAssertNotEqual(s1, s2)
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
    
    func testUnequatableJSONArrays() {
        let a1: JSON = [7, "JSON"]
        let a2: JSON = [99, "XML"]
        XCTAssertNotEqual(a1, a2)
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
    
    func testUnequatableJSONDictionaries() {
        let d1: JSON = ["array": [9, 11, 14, "JSON"]]
        let d2: JSON = ["dictionary": ["value": "xml"]]
        XCTAssertNotEqual(d1, d2)
    }
    
    func testEquatableJSONNulls() {
        let null1 = JSON.null
        let null2: JSON = nil
        XCTAssertEqual(null1, null2)
    }
    
    func testUnequatableJSON() {
        let j1: JSON = 48
        let j2: JSON = ["dictionary": ["value": [9, 8, 7]]]
        XCTAssertNotEqual(j1, j2)
    }
}
