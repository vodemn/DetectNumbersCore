//
//  core.swift
//  core
//
//  Created by Vadim Turko on 12/27/21.
//

import Foundation

class Core {
    let layers: Array<Dense>
    
    init(inputSize: Int, outputSize: Int, neurons: Int, lr: Double) {
        self.layers = [
            Dense(inputSize: inputSize, neurons: neurons, lr: lr, isLast: false),
            Dense(inputSize: neurons, neurons: outputSize, lr: lr, isLast: true),
        ]
    }
    
    func train(inputs: Matrix, targets: Matrix, epochs: Int) {
        var errors: [Double] = []
        for i in 0..<epochs {
            let start = CFAbsoluteTimeGetCurrent()
            var result = inputs
            for layer in layers {
                result = layer.forward(x: result)
            }
            
            let loss: Double = logloss(targets, result)
            errors.append(loss)
            
            var dE: Matrix = logloss_derivative(targets, result)
            for layer in layers.reversed() {
                dE = layer.backward(dE: dE)
            }
            print("Epoch \(i) took \(CFAbsoluteTimeGetCurrent() - start) seconds")
        }
        (errors as NSArray).write(
            to: URL(fileURLWithPath: "/Users/vadim.turko/Documents/Projects/detect_numbers/errors.csv"),
            atomically: true)
    }
    
    private func logloss(_ targets: Matrix, _ result: Matrix) -> Double {
        assert(targets.shape == result.shape)
        let error: Double = (try! targets * result.apply({log($0)})).values.reduce(0, +)
        return -(error / Double(result.columns))
    }
    
    private func logloss_derivative(_ targets: Matrix, _ result: Matrix) -> Matrix {
        assert(targets.shape == result.shape)
        return try! result - targets
    }
}

