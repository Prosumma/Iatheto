//
//  Attempt.swift
//  Iatheto
//
//  Created by Gregory Higley on 4/22/18.
//  Copyright © 2018 Gregory Higley. All rights reserved.
//

import Foundation

typealias Attempt<R> = () throws -> R

func attempt<R>(_ firstAttempt: Attempt<R>, _ attempts: Attempt<R>...) throws -> R {
    do {
        return try firstAttempt()
    } catch let e {
        guard let lastAttempt = attempts.last else {
            throw e
        }
        for attempt in attempts.dropLast() {
            do {
                return try attempt()
            } catch DecodingError.typeMismatch {
                continue
            }
        }
        return try lastAttempt()
    }
}
