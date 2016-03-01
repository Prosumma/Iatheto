//
//  IathetoTests.swift
//  IathetoTests
//
//  Created by Gregory Higley on 3/1/16.
//  Copyright © 2016 Gregory Higley. All rights reserved.
//

import XCTest
@testable import Iatheto

class IathetoTests: XCTestCase {
    
    func testEncodingAndDecoding() {
        let envelope1 = Envelope<JSONEncodableDecodableArray<Foo>>(content: JSONEncodableDecodableArray([Foo(name: "foo")]))
        let json = envelope1.decode()
        print(json)
        do {
            let envelope2 = try Envelope<JSONEncodableDecodableArray<Foo>>(json: json)
            XCTAssertEqual(envelope1.content!.array[0], envelope2.content!.array[0])
        } catch let e {
            XCTAssert(false, String(e))
        }
        
    }
    
}
