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
 
    func testDecodingString() {
        do {
            let json = try JSON(string: "[27, \"string\"]")
            let strings: [String]? = try [String].decode(json: json)
            XCTAssertNotNil(strings)
            print(strings!)
        } catch _ {
            XCTFail()
        }
    }
    
    func testDecodingNumber() {
        do {
            let json = try JSON(string: "[27, \"889.3\"]")
            let numbers: [NSNumber]? = try [NSNumber].decode(json: json)
            XCTAssertNotNil(numbers)
            print(numbers!)
        } catch _ {
            XCTFail()
        }
    }
    
    func testDecodingInts() {
        do {
            let json = try JSON(string: "[27, \"889.3\", \"19.9\", 304]")
            let ints: [Int]? = try [Int].decode(json: json)
            XCTAssertNotNil(ints)
            print(ints!)
        } catch _ {
            XCTFail()
        }
    }
    
    func testDecodingInvalidFloatThrows() {
        XCTAssertThrowsError(try [String: Float].decode(string: "{\"an actual float\": 17.3, \"not a float\": [27]}"))
    }
    
    struct Watusi: JSONDecodable {
        let float: Float
        let ints: [Int?]
        
        public static func decode(json: JSON?, state: Any?) throws -> Watusi? {
            guard let json = json else { return nil }
            switch json {
            case .dictionary(let dictionary): return try Watusi(float: Float.decode(json: dictionary["float"]) ?? 0, ints: [Int].decode(json: dictionary["ints"]) ?? [])
            case .null: return nil
            default: throw JSONError.undecodableJSON(json)
            }
        }
    }
    
    func testDecodeStructWatusi() {
        do {
            guard let watusi = try Watusi.decode(string: "{\"float\": 73, \"ints\": [2,7.0,9,null]}") else {
                XCTFail()
                return
            }
            XCTAssertEqual(watusi.float, 73)
            XCTAssertEqual(watusi.ints.count, 4)
        } catch _ {
            XCTFail()
        }
    }

    class Awesome: JSONDecodable {
        let watusi: Watusi
        let level: Int
        
        required init(watusi: Watusi, level: Int) {
            self.watusi = watusi
            self.level = level
        }
        
        static func decode(json: JSON?, state: Any?) throws -> Self? {
            return try json?.decodeDictionary { dictionary in
                return try self.init(watusi: Watusi.decode(json: dictionary["watusi"])!, level: Int.decode(json: dictionary["level"])!)
            }
        }
    }
    
    func testDecodeClassAwesome() {
        do {
            guard let awesome = try Awesome.decode(string: "{\"watusi\": {\"float\": 69.96, \"ints\": [8,4]}, \"level\": 42}") else {
                XCTFail()
                return
            }
            XCTAssertEqual(awesome.level, 42)
        } catch _ {
            XCTFail()
        }
    }
}
