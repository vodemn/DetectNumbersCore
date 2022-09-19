//
//  Core.swift
//  Core
//
//  Created by Vadim Turko on 12/27/21.
//

import Foundation
import Accelerate

class Core {
    let layers: Array<Dense>
    
    var inputSize: (Int, Int) {
        get {
            let sideSize = Int(sqrt(Double(self.layers.first!.w.columns - 1)))
            return (sideSize, sideSize)
        }
    }
    
    init(weightArrays: [[[Double]]]) {
        var layers: [Dense] = []
        for (index, item) in weightArrays.enumerated() {
            if (index < weightArrays.endIndex - 1) {
                layers.append(InnerDense(w: Matrix(from: item)))
            } else {
                layers.append(LastDense(w: Matrix(from: item)))
            }
        }
        self.layers = layers
    }
    
    /// Returns an array where each item is a probability of item index value
    func detect(input: [Double]) -> [Double] {
        assert(input.endIndex == self.layers.first!.w.columns - 1)
        var result = Matrix(from: input, shape: (input.endIndex, 1))
        for layer in layers {
            result = layer.forward(x: result)
        }
        return result.values
    }
}

