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
        let envelope1 = Envelope<JSONCodableArray<Foo>>(content: JSONCodableArray([Foo(name: "foo"), Foo(name: "bar")]))
        let json = envelope1.encode()
        print(json)
        let envelope2 = Envelope<JSONCodableArray<Foo>>(json: json)
        XCTAssertNotNil(envelope2)
        XCTAssertEqual(envelope1.content!.array[0], envelope2!.content!.array[0])
    }    
}
