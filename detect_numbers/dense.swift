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
    private let _isLast: Bool
    private var _cache: (Matrix, Matrix)?
    
    init(inputSize: Int, neurons: Int, lr: Double, isLast: Bool){
        let norm: Double = 2.0 / sqrt(Double(neurons + inputSize + 1))
        let weights: [[Double]] = (0..<neurons).map {_ in (0...inputSize).map { _ in Double.random(in: 0...1) * norm }}
        self.w = Matrix.init(from: weights)
        self._isLast = isLast
        self.lr = lr
    }
    
    func forward(x: Matrix) -> Matrix {
        let x_ext: Matrix = x.copy()
        x_ext.appendRow(row: Array(repeating: 1, count: x.columns))
        var result = try! self.w ~* x_ext
        if (self._isLast) {
            result = result.applyOnColumns({softmax($0)})
        } else {
            result = result.apply({sigmoid($0)})
        }
        self._cache = (x_ext, result)
        return result
    }
    
    func backward(dE: Matrix) -> Matrix {
        var dENext: Matrix = (try! dE.transposed() ~* w).transposed()
        dENext = dENext[0..<dENext.rows - 1]
        
        var derive: Matrix = dE.copy()
        if (!_isLast) {
            let output: Matrix = _cache!.1.apply({sigmoid_derived($0)})
            derive = try! dE * output //TODO fix sizes
        }
        derive = try! (derive / 1000) ~* _cache!.0.transposed()
        w = try! w - (derive * lr)
        
        return dENext
    }
}

func sigmoid(_ i: Double) -> Double {
    return 1 / (1 + exp(-i))
}

func sigmoid_derived(_ i: Double) -> Double {
    return i * (1 - i)
}

func softmax(_ row: Array<Double>) -> Array<Double> {
    let max = row.max()!
    let e = row.map {exp($0 - max)}
    let sum: Double = e.reduce(0, +)
    return e.map {$0 / sum}
}
