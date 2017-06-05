//
//  Operators.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

infix operator ??! : NilCoalescingPrecedence

func ??!<T>(lhs: T?, rhs: Error) throws -> T {
    guard let lhs = lhs else { throw rhs }
    return lhs
}
