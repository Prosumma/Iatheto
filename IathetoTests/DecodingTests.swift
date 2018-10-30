//
//  DecodingTests.swift
//  Iatheto
//
//  Created by Gregory Higley on 4/22/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import XCTest
import Iatheto

class DecodingTests: XCTestCase {
    
    func testDecoding() throws {
        let bundle = Bundle(for: DecodingTests.self)
        guard let url = bundle.url(forResource: "json", withExtension: "json") else {
            return XCTFail()
        }
        let data = try Data(contentsOf: url)
        do {
            let json = try JSON(parsing: data)
            debugPrint(json)
        } catch let e {
            debugPrint(e)
            throw e
        }
    }
    
}
