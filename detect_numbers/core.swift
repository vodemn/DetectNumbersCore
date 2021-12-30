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
            print(i)
            var result = inputs
            for layer in layers {
                result = layer.forward(x: result)
            }
            
            let loss: Double = logloss(result, targets)
            errors.append(loss)
            
            var dE: Matrix = logloss_derivative(result, targets)
            for layer in layers.reversed() {
                dE = layer.backward(dE: dE)
            }
        }
        (errors as NSArray).write(
            to: URL(fileURLWithPath: "/Users/vadim.turko/Documents/Projects/detect_numbers/errors.csv"),
            atomically: true)
    }
    
    /*
     func test(inputs: Matrix, targets: Matrix) -> Double {
     var result = inputs
     for layer in layers {
     result = layer.forward(x: result)
     }
     }
     */
    
    private func logloss(_ result: Matrix, _ targets: Matrix) -> Double {
        assert(targets.shape == result.shape)
        let error: Double = zip(result.values, targets.values)
            .reduce(0, {r, dataset in zip(dataset.0, dataset.1)
                .reduce(0.0, {r, data in r + data.1 * log(data.0)})})
        return -(error / Double(result.columns))
    }
    
    private func logloss_derivative(_ result: Matrix, _ targets: Matrix) -> Matrix {
        assert(targets.shape == result.shape)
        return try! result + targets
    }
}

