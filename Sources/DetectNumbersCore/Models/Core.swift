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
    
    init(inputSize: Int, outputSize: Int, neurons: Int) {
        self.layers = [
            InnerDense(inputSize: inputSize, neurons: neurons),
            LastDense(inputSize: neurons, neurons: outputSize),
        ]
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
    
    internal func train(inputs: Matrix, targets: Matrix, epochs: Int, lr: Double) {
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
                dE = layer.backward(dE: dE, lr: lr)
            }
        }
        print("Trained in \(CFAbsoluteTimeGetCurrent() - start) seconds")
        (errors as NSArray).write(to: getFileURL(filename: "Generated/Errors.csv"), atomically: true)
        
        saveDensesToFile()
    }
    
    internal func test(inputs: Matrix, targets: Matrix) -> Double {
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
        return percentage
        
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
    
    private func logloss(_ targets: Matrix, _ result: Matrix) -> Double {
        let error: Double = (targets * result.apply({log($0)})).values.reduce(0, +)
        return -(error / Double(result.columns))
    }
    
    private func logloss_derivative(_ targets: Matrix, _ result: Matrix) -> Matrix {
        return result - targets
    }
}

