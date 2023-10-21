import XCTest
@testable import Iatheto

final class IathetoTests: XCTestCase {
  let sjson = """
    {
      "null": null,
      "bool": true,
      "string": "string",
      "integer": 789,
      "float": 43.4,
      "scientific": 7e-3,
      "array": [null, "string", 9, 4.2e+3, {}]
    }
    """
  lazy var djson = { sjson.data(using: .utf8)! }()
  let decoder = JSONDecoder()
  let encoder = JSONEncoder()
  lazy var json = { try! decoder.decode(JSON.self, from: djson) }()
  
  func testDecoding() throws {
    XCTAssertTrue(json["null"]?.null ?? false)
    XCTAssertEqual(json["null"], .null)
    XCTAssertEqual(json["string"], "string")
    XCTAssertEqual(json["string"]?.string, "string")
    XCTAssertEqual(json["integer"], 789)
    XCTAssertEqual(json["integer"]?.int, 789)
    XCTAssertEqual(json["integer"]?.int64, 789)
    XCTAssertEqual(json["float"], 43.4)
    XCTAssertEqual(json["float"]?.float, 43.4)
    XCTAssertEqual(json["scientific"]!.double!, 0.007, accuracy: 0.0001)
    XCTAssertEqual(json["array"]?[3], 4200)
  }
  
  func testEncoding() throws {
    // Given
    let data = try encoder.encode(json)
    
    // When
    let decoded = try decoder.decode(JSON.self, from: data)
    
    // Then
    XCTAssertEqual(json, decoded)
  }
  
  func testAssignNull() {
    // Given
    var json: JSON = "json"
    
    // When
    json.null = true
    
    // Then
    XCTAssertTrue(json.null)
  }
 
  func testAssignments() {
    assign(\.string, "string")
    assign(\.bool, true)
    assign(\.int, 13)
    assign(\.float, 13.1)
    assign(\.array, [nil, 5])
    assign(\.object, ["foo": "bar", "bool": false, "o": [:], "a": []])
  }
  
  func testSubscriptSetters() {
    // Given
    var json: JSON = ["a": [0]]
    
    // When
    json["a"]?[0] = "3"
    
    // Then
    XCTAssertEqual(json["a"]?[0], "3")
    
    // When
    json["a"]?[0] = nil
    
    // Then
    XCTAssertEqual(json["a"]?[0], .null)
  }
  
  func testCustomStringConvertible() {
    // Given
    let json: JSON = ["foo": "bar"]
    
    // When
    let description = String(describing: json)
    
    // Then
    XCTAssertEqual(description, "{\"foo\":\"bar\"}")
  }
  
  func testNull() {
    // Given
    let json: JSON = "json"
    
    // Then
    XCTAssertFalse(json.null)
  }
  
  private func assign<T>(_ keyPath: WritableKeyPath<JSON, T?>, _ value: T) where T: Equatable {
    // Given
    var json: JSON = nil
    
    // When
    json[keyPath: keyPath] = value
    
    // Then
    XCTAssertEqual(json[keyPath: keyPath], value)
    
    // When
    json[keyPath: keyPath] = nil
    
    // Then
    XCTAssertTrue(json.null)
  }
}
