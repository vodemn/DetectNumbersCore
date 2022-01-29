//
//  rand_array.swift
//  rand_array
//
//  Created by Vadim Turko on 1/29/22.
//

import Foundation

private var generator: RandomNumberGeneratorWithSeed = RandomNumberGeneratorWithSeed(seed: 0)

struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    init(seed: Int) {
        // Set the random seed
        srand48(seed)
    }
    
    func next() -> UInt64 {
        return withUnsafeBytes(of: drand48()) { bytes in
            bytes.load(as: UInt64.self)
        }
    }
}

extension Double {
    static func random01() -> Double {
        return Double.random(in: 0...1, using: &generator)
    }
}
