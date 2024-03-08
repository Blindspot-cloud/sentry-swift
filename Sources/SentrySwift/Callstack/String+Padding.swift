//
//  String+Padding.swift
//  CallStackParser
//
//  Created by kojirof on 2018/12/07.
//  Copyright © 2018 Gumob. All rights reserved.
//

import Foundation

internal extension String {
    func leftPadding(toLength: Int, withPad: String = " ") -> String {
        guard toLength > self.count else { return self }
        let padding: String = String(repeating: withPad, count: toLength - self.count)
        return padding + self
    }
}
