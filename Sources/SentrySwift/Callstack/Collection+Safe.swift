//
//  Collection+Safe.swift
//  CallStackParser
//
//  Created by kojirof on 2018/12/07.
//  Copyright © 2018 Gumob. All rights reserved.
//

import Foundation

internal extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
