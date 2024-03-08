//
//  NSObject+Logging.swift
//  GDXRepo
//
//  Created by Георгий Малюков on 26.05.2018.
//  Copyright © 2018 Georgiy Malyukov. All rights reserved.
//

import Foundation

internal extension NSObject {

    var typenameFull: String {
        return String(describing: type(of: self))
    }

    var typename: String {
        return typenameFull.replacingOccurrences(of: "^[^\\.]+\\.", with: "", options: .regularExpression, range: nil)
    }

    func d(_ string: String) {
        let dt = Date().description
        for symbol in Thread.callStackSymbols[1...] {
            if let parsed = CallStackParser.classAndMethodForStackSymbol(symbol) {
                print("\(dt) [\(parsed.0)] \(parsed.1) \(string)")
                return
            }
        }
        print("\(dt) [\(typename)] \(string)")
    }

}
