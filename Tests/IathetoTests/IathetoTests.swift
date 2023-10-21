import XCTest
@testable import Iatheto

final class IathetoTests: XCTestCase {
    func testExample() throws {
      let json1: JSON = ["ok": [3, nil]]
      let encoder = JSONEncoder()
      let jsonData = try encoder.encode(json1)
      print(String(data: jsonData, encoding: .utf8)!)
      let decoder = JSONDecoder()
      var json2 = try decoder.decode(JSON.self, from: jsonData)
      XCTAssertEqual(json1, json2)
      json2["ok"]?[1] = "Yeah"
      print(json2)
    }
}
