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
    
    init(inputSize: Int, outputSize: Int, neurons: Int, lr: Double) {
        self.layers = [
            InnerDense(inputSize: inputSize, neurons: neurons, lr: lr),
            LastDense(inputSize: neurons, neurons: outputSize, lr: lr),
        ]
    }
    
    func train(inputs: Matrix, targets: Matrix, epochs: Int) {
        var errors: [Double] = []
        let start = CFAbsoluteTimeGetCurrent()
        for _ in 0..<epochs {
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
        }
        print("Trained in \(CFAbsoluteTimeGetCurrent() - start) seconds")
        (errors as NSArray).write(to: getFileUrl(filename: "Generated/Errors.csv"), atomically: true)
        
        saveDensesToFile()
    }
    
    func test(inputs: Matrix, targets: Matrix) {
        var result = inputs
        for layer in layers {
            result = layer.forward(x: result)
        }
        
        
        let digits: [Int] = targets.maxInColumns()
        let predicted_digits: [Int] = result.maxInColumns()
        let diff = zip(digits, predicted_digits).reduce(0) { partialResult, d in
            partialResult + (d.0 == d.1 ? 1 : 0)
        }
        
        let percentage = Double(diff * 100) / Double(targets.columns)
        print(percentage)
        
    }
    
    private func logloss(_ targets: Matrix, _ result: Matrix) -> Double {
        let error: Double = (targets * result.apply({log($0)})).values.reduce(0, +)
        return -(error / Double(result.columns))
    }
    
    private func logloss_derivative(_ targets: Matrix, _ result: Matrix) -> Matrix {
        return result - targets
    }
}

