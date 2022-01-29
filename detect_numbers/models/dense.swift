//
//  dense.swift
//  dense
//
//  Created by Vadim Turko on 12/23/21.
//

import Foundation

class Dense {
    var w: Matrix
    let lr: Double
    var cache: (Matrix, Matrix)?
    
    init(inputSize: Int, neurons: Int, lr: Double){
        let norm: Double = 2.0 / sqrt(Double(neurons + inputSize + 1))
        let weights: [[Double]] = (0..<neurons).map {_ in (0...inputSize).map { _ in Double.random01() * norm }}
        self.w = Matrix.init(from: weights)
        self.lr = lr
    }
    
    func forward(x: Matrix) -> Matrix {
        let x_ext: Matrix = x.copy()
        x_ext.appendRow(row: Array(repeating: 1, count: x.columns))
        var result = self.w ~* x_ext
        result = forwardActivation(x: result)
        self.cache = (x_ext, result)
        return result
    }
    
    func backward(dE: Matrix) -> Matrix {
        var dENext: Matrix = (dE.transposed() ~* w).transposed()
        dENext = dENext[0..<dENext.rows - 1]
        
        var derive: Matrix = dE.copy()
        let backwardAct: Matrix? =  backwardActivation(cache!.1)
        if (backwardAct != nil) {
            derive = dE * backwardAct!
        }
        derive = (derive / 1000) ~* cache!.0.transposed()
        w = w - (derive * lr)
        
        return dENext
    }
    
    func forwardActivation(x: Matrix) -> Matrix {
        fatalError("Activation function is not implemented")
    }
    
    func backwardActivation(_ dE: Matrix) -> Matrix? {
        fatalError("Activation function is not implemented")
    }
}

class InnerDense: Dense {
    override
    func forwardActivation(x: Matrix) -> Matrix {
        return x.apply({sigmoid($0)})
    }
    
    override
    func backwardActivation(_ dE: Matrix) -> Matrix? {
        let output: Matrix = cache!.1.apply({sigmoid_derived($0)})
        return dE * output
    }
    
    private func sigmoid(_ i: Double) -> Double {
        return 1 / (1 + exp(-i))
    }
    
    private func sigmoid_derived(_ i: Double) -> Double {
        return i * (1 - i)
    }
}

class LastDense: Dense {
    override
    func forwardActivation(x: Matrix) -> Matrix {
        return x.applyOnColumns({softmax($0)})
    }
    
    override
    func backwardActivation(_ dE: Matrix) -> Matrix? {
        return nil
    }
    
    private func softmax(_ row: Array<Double>) -> Array<Double> {
        let max = row.max()!
        let e = row.map {exp($0 - max)}
        let sum: Double = e.reduce(0, +)
        return e.map {$0 / sum}
    }

}
