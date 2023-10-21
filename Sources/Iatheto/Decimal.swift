//
//  Decimal.swift
//  Iatheto
//
//  Created by Gregory Higley on 2018-07-27.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import Foundation

extension Decimal {
  func to<Value>(_ keyPath: KeyPath<NSDecimalNumber, Value>) -> Value {
      return NSDecimalNumber(decimal: self)[keyPath: keyPath]
  }
  
  var double: Double {
      return to(\.doubleValue)
  }
  
  var float: Float {
      return to(\.floatValue)
  }
  
  var int: Int {
      return to(\.intValue)
  }
  
  var int64: Int64 {
      return to(\.int64Value)
  }
}

