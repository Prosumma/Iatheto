//
//  JSON.swift
//
//
//  Created by Gregory Higley on 2023-10-21.
//

import Foundation

public enum JSON: Equatable, Hashable {
  case null
  case bool(Bool)
  case string(String)
  case number(Decimal)
  case array([JSON])
  case object([String: JSON])
}

public extension JSON {
  var null: Bool {
    get {
      guard case .null = self else { return false }
      return true
    }
    set {
      if newValue { self = .null }
    }
  }

  var string: String? {
    get {
      guard case .string(let value) = self else { return nil }
      return value
    }
    set {
      self = newValue.flatMap(JSON.string) ?? .null
    }
  }

  var bool: Bool? {
    get {
      guard case .bool(let value) = self else { return nil }
      return value
    }
    set {
      self = newValue.flatMap(JSON.bool) ?? .null
    }
  }

  var decimal: Decimal? {
    get {
      guard case .number(let value) = self else { return nil }
      return value
    }
    set {
      self = newValue.flatMap(JSON.number) ?? .null
    }
  }

  var int: Int? {
    get { decimal?.int }
    set { int64 = newValue.flatMap(Int64.init) }
  }

  var int64: Int64? {
    get { decimal?.int64 }
    set { decimal = newValue.flatMap(Decimal.init) }
  }

  var float: Float? {
    get { decimal?.float }
    set { double = newValue.flatMap(Double.init) }
  }

  var double: Double? {
    get { decimal?.double }
    set { decimal = newValue.flatMap { Decimal($0) } }
  }

  var array: [JSON]? {
    get {
      guard case .array(let value) = self else { return nil }
      return value
    }
    set {
      self = newValue.flatMap(JSON.array) ?? .null
    }
  }

  var object: [String: JSON]? {
    get {
      guard case .object(let value) = self else { return nil }
      return value
    }
    set {
      self = newValue.flatMap(JSON.object) ?? .null
    }
  }

  subscript(index: Int) -> JSON? {
    get { array?[index] }
    set { array?[index] = newValue ?? .null }
  }

  subscript(key: String) -> JSON? {
    get { object?[key] }
    set { object?[key] = newValue }
  }
}

extension JSON: CustomStringConvertible {
  public var description: String {
    let encoder = JSONEncoder()
    // Encoding cannot fail
    let data = try! encoder.encode(self)
    // And it always produces valid UTF-8
    return String(data: data, encoding: .utf8)!
  }
}

extension JSON: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = .null
  }
}

extension JSON: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: BooleanLiteralType) {
    self = .bool(value)
  }
}

extension JSON: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .string(value)
  }
}

extension JSON: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: JSON...) {
    self = .array(elements)
  }
}

extension JSON: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, JSON)...) {
    let object = Dictionary(uniqueKeysWithValues: elements)
    self = .object(object)
  }
}

extension JSON: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self = .number(Decimal(integerLiteral: value))
  }
}

extension JSON: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    self = .number(Decimal(floatLiteral: value))
  }
}

extension JSON: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let decoding = Decoding.null ||
                             Decoding(JSON.string) ||
                             Decoding(JSON.number) ||
                             Decoding(JSON.bool) ||
                             Decoding(JSON.array) ||
                             Decoding(JSON.object)
      self = try decoding(container)
  }
}

extension JSON: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .null:
      try container.encodeNil()
    case .bool(let bool):
      try container.encode(bool)
    case let .string(string):
      try container.encode(string)
    case let .number(decimal):
      try container.encode(decimal)
    case let .array(array):
      try container.encode(array)
    case let .object(object):
      try container.encode(object)
    }
  }
}

/// A type-erased combinator for attempting to decode JSON nodes.
struct Decoding {
  private let decode: (SingleValueDecodingContainer) throws -> JSON

  init<T: Decodable>(_ toJSON: @escaping (T) -> JSON) {
    decode = { container in
      try toJSON(container.decode(T.self))
    }
  }

  init(_ decode: @escaping (SingleValueDecodingContainer) throws -> JSON) {
    self.decode = decode
  }

  func callAsFunction(_ container: SingleValueDecodingContainer) throws -> JSON {
    try decode(container)
  }
}

extension Decoding {
  static var null: Decoding {
    .init { container throws in
      if container.decodeNil() {
        return .null
      } else {
        throw DecodingError.typeMismatch(
          JSON.self,
          .init(codingPath: container.codingPath, debugDescription: "Tried to decode null but it failed.")
        )
      }
    }
  }
}

func || (lhs: Decoding, rhs: Decoding) -> Decoding {
  .init { container throws in
    do {
      return try lhs(container)
    } catch {
      return try rhs(container)
    }
  }
}
