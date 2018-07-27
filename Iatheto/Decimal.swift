//
//  Decimal.swift
//  Iatheto
//
//  Created by Gregory Higley on 7/27/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import Foundation

extension Decimal {
    func to<Value>(_ keyPath: KeyPath<NSDecimalNumber, Value>) -> Value {
        return NSDecimalNumber(decimal: self)[keyPath: keyPath]
    }
    
    var doubleValue: Double {
        return to(\.doubleValue)
    }
    
    var floatValue: Float {
        return to(\.floatValue)
    }
    
    var intValue: Int {
        return to(\.intValue)
    }
    
    var int64Value: Int64 {
        return to(\.int64Value)
    }
}
