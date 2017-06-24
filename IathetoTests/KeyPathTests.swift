//
//  KeyPathTests.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/4/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import XCTest
@testable import Iatheto

class KeyPathTests: XCTestCase {

    func testDeepKeyPath() {
        let string = "{\"content\": [7, 44, {\"elem\": [\"extra\", 0, 99]}]}"
        do {
            let json = try JSON(parsing: string)
            let extra = json["content" +> .last +> "elem" +> 0].string!
            XCTAssertEqual(extra, "extra")
            let i = json["content" +> 0]
            XCTAssertEqual(i, 7)
        } catch let e {
            XCTFail(String(describing: e))
        }
    }
    
    func testDeepBadKeyPath() {
        let string = "{\"content\": [7, 44, {\"elem\": [\"extra\", 0, 99]}]}"
        do {
            let json = try JSON(parsing: string)
            let extra = json[17 +> .last +> "foo"]
            XCTAssertEqual(extra, JSON.null)
        } catch let e {
            XCTFail(String(describing: e))
        }
    }
    
    func testDeepKeyPathAssignment() {
        var json: JSON = [:]
        let baseKeyPath = .last +> "awesome"
        let crazyKeyPath = baseKeyPath +> 4
        let coolKeyPath = baseKeyPath +> 7
        json[crazyKeyPath] = "crazy"
        print(json)
        XCTAssertEqual(json[crazyKeyPath], "crazy")
        print(json)
        json[coolKeyPath] = "cool"
        print(json)
        XCTAssertEqual(json[coolKeyPath], "cool")
        XCTAssertEqual(json[crazyKeyPath], "crazy")        
    }
    
}
