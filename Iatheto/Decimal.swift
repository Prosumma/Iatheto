//
//  Decimal.swift
//  Iatheto
//
//  Created by Gregory Higley on 7/27/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import Foundation

extension Decimal {
    var doubleValue: Double {
        let n = NSDecimalNumber(decimal: self)
        return n.doubleValue
    }
    var floatValue: Float {
        let n = NSDecimalNumber(decimal: self)
        return n.floatValue
    }
}
