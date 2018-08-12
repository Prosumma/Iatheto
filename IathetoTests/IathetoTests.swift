//
//  IathetoTests.swift
//  Iatheto
//
//  Created by Gregory Higley on 8/10/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import XCTest
@testable import Iatheto

class IathetoTests: XCTestCase {
    
    func testEquality() {
        let json1: JSON = 3.44
        let json2: JSON = 3.44
        XCTAssertEqual(json1, json2)
    }
    
}
