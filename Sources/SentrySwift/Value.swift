//
//  Value.swift
//  
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation


public enum Value: Encodable {
    case string(String)
    case number(Int64)
    case boolean(Bool)
    case map([String: Value])
}
