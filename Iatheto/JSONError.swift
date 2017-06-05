//
//  JSONError.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

public enum JSONError: Error {
    case unencodableValue(Any)
    case undecodableJSON(JSON)
    case invalidState(Any?)
}

