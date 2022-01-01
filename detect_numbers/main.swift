//
//  main.swift
//  detect_numbers
//
//  Created by Vadim Turko on 12/23/21.
//

import Foundation


let dataset: ((Matrix, Matrix), (Matrix, Matrix))? = loadDataset()
if (dataset != nil) {
    let a = Matrix.init(from: Array(repeating: (0...dataset!.0.0.rows)
                                        .map { _ in Double((
                                            .random(in: 0...255)) / (64 + dataset!.0.0.rows + 1)) }, count: 64))
    let x_ext = dataset!.0.0.copy()
    try! x_ext.appendRow(row: Array(repeating: 1, count: dataset!.0.0.columns))
    //let result = try! a ~* x_ext
    let result_element = try! a * a
    //let network: Core = Core(inputSize: dataset!.0.0.rows, outputSize: dataset!.1.0.rows, neurons: 64, lr: 0.3)
    //network.train(inputs: dataset!.0.0, targets: dataset!.1.0, epochs: 10)
}

