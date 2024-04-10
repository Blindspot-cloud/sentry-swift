//
//  Thread+Simple.swift
//  CallStackParser
//
//  Created by kojirof on 2018/12/07.
//  Copyright © 2018 Gumob. All rights reserved.
//

import Foundation

internal struct StackSymbol {
    
}

internal extension Thread {
    /**
     An array of string containing parsed class names and method names
     */
    static func simpleCallStackSymbols(drop: Int = 0) -> [(String, String)] {
        let symbols: [(String, String)] = Thread.callStackSymbols
                .dropFirst(drop + 1)
                .map {
                    guard $0.replacingOccurrences(of: "\\s+",
                                                                       with: " ",
                                                                       options: .regularExpression,
                                                                       range: nil)
                                                 .components(separatedBy: " ")[safe: 1] != nil else {
                        return ("", "")
                    }
                    if let symbol: (String, String) = CallStackParser.classAndMethodForStackSymbol($0) {
                        return symbol
                    }
                    if let closure = CallStackParser.closureForStackSymbol($0) {
                        return ("", closure)
                    }
                    return ("", "")
                }
                .filter {
                    !$0.1.isEmpty
                }
        let count: Int = symbols.count
        let digit: Int = String(count).count
        return symbols
    }

    /**
     A formatted string containing parsed class names and method names
     */
    static func simpleCallStackString() -> String {
        return simpleCallStackSymbols().map{ "\($0.0) \($0.1)" }.joined(separator: "\n")
    }
}
