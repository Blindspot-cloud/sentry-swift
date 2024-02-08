//
//  SentryError.swift
//
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation

enum SentryError: Error {
    case NoResponseBody(status: UInt)
    case InvalidArgumentException(_ msg: String)
}
