//
//  Dense.swift
//  Dense
//
//  Created by Vadim Turko on 12/23/21.
//

import Foundation
import Accelerate

class Dense {
    var w: Matrix
    var cache: (Matrix, Matrix)?
    
    init(w: Matrix){
        self.w = w
    }
    
    func forward(x: Matrix) -> Matrix {
        let x_ext: Matrix = x.appendRow(row: Array(repeating: 1, count: x.columns))
        var result = self.w ~* x_ext
        result = forwardActivation(x: result)
        self.cache = (x_ext, result)
        return result
    }
    
    func forwardActivation(x: Matrix) -> Matrix {
        fatalError("Activation function is not implemented")
    }
}

class InnerDense: Dense {
    override
    func forwardActivation(x: Matrix) -> Matrix {
        return x.apply({sigmoid($0)})
    }

    private func sigmoid(_ i: Double) -> Double {
        return 1 / (1 + exp(-i))
    }
}

class LastDense: Dense {
    override
    func forwardActivation(x: Matrix) -> Matrix {
        return x.applyOnColumns({softmax($0)})
    }
    
    private func softmax(_ row: Array<Double>) -> Array<Double> {
        let max = row.max()!
        let e = row.map {exp($0 - max)}
        let sum: Double = vDSP.sum(e)
        return e.map {$0 / sum}
    }
}
