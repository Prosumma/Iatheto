//
//  JSONError.swift
//  Iatheto
//
//  Created by Gregory Higley on 6/5/17.
//  Copyright © 2017 Gregory Higley. All rights reserved.
//

import Foundation

public enum JSONError: Error {
    /**
     Thrown when a type cannot be encoded as JSON.
    */
    case unencodableValue(Any)
    /**
     JSON is undecodable when it cannot be decoded
     into the requested type. This is typically thrown
     by `decode` and its overloads.
    */
    case undecodableJSON(JSON)
    /**
     Thrown when the state parameter of `decode` and `encode`
     is unexpected.
     
     - note: Iatheto will never throw this error, but implementors
     are encouraged to do so when the `state` parameter is not what
     is expected by the method.
    */
    case unexpectedState(Any?)
}

