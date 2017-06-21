//
//  ComplexEncodingTests.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/6/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import XCTest
@testable import Iatheto

class ComplexEncodingTests: XCTestCase {
    
    func testEncodeComplexType() {
        let complex1 = Complex(string: "s", int: 867, float: -32.6)
        do {
            let json = try complex1.encode()
            debugPrint(json)
            let complex2: Complex! = try Complex.decode(json: json)
            XCTAssertEqual(complex1, complex2)
        } catch let e {
            XCTFail(String(describing: e))
        }
    }
    
}
