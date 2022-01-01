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
        self.w = Matrix.init(from: Array(repeating: (0...inputSize).map { _ in Double((.random(in: 0...255)) / (neurons + inputSize + 1)) },
                                         count: neurons))
        self._isLast = isLast
        self.lr = lr
    }
    
    func forward(x: Matrix) -> Matrix {
        let x_ext: Matrix = x.copy()
        try! x_ext.appendRow(row: Array(repeating: 1, count: x.columns))
        let result = try! self.w ~* x_ext
        if (self._isLast) {
            result.applyOnRows({softmax($0)})
        } else {
            result.apply({sigmoid($0)})
        }
        self._cache = (x_ext, result)
        return result
    }
    
    func backward(dE: Matrix) -> Matrix {
        var derive: Matrix = dE.copy()
        var dENext: Matrix = (try! dE.transposed() ~* w)
        dENext = dENext.transposed()
        dENext = dENext[0..<dENext.rows - 1]
        
        if (!_isLast) {
            let output: Matrix = _cache!.1.copy()
            output.apply({sigmoid_derived($0)})
            derive = try! dE * output //TODO fix sizes
        }
        derive.apply({$0 / 1000})
        derive = try! derive ~* _cache!.0.transposed()
        derive.apply({$0 * lr})
        w = try! w - derive
        
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
    let sum: Double = row.reduce(0, +)
    return row.map {$0 / sum}
}