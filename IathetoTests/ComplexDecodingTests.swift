//
//  ComplexDecodingTests.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/6/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import XCTest
@testable import Iatheto

class ComplexDecodingTests: XCTestCase {
    
    func testDecodeComplexType() {
        do {
            let complex: Complex! = try Complex.decode(parsing: "{\"string\": \"complex\", \"int\": 77}", state: nil)
            XCTAssertNotNil(complex)
            XCTAssertEqual(complex.string, "complex")
            XCTAssertEqual(complex.int, 77)
            XCTAssertEqual(complex.float, 0)
        } catch let e {
            XCTFail(String(describing: e))
        }
    }
    
}
