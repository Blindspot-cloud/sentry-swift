//
//  Sampler.swift
//
//
//  Created by Max Müller on 03.02.2024.
//

import Foundation


struct Sampler {
    
    static func sample(threshhold: Float) -> Bool {
        let randomNumber = Float.random(in: 0.0...1.0)
        
        return randomNumber <= threshhold
    }
    
}
