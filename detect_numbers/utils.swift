//
//  utils.swift
//  utils
//
//  Created by Vadim Turko on 12/25/21.
//

import Foundation


func loadDataset() -> ((Matrix<Double>, Matrix<Double>), (Matrix<Int>, Matrix<Int>))? {
    let inputsCSV = loadFile("inputs")
    let targetsCSV = loadFile("targets")
    if (inputsCSV != nil && targetsCSV != nil) {
        var parsedInputsCSV: [[Double]] = parseCSV(inputsCSV!, {Double($0) ?? 0})
        var parsedTargetsCSV: [[Int]] = parseCSV(targetsCSV!, {Int(Double($0) ?? 0)})
        if (parsedInputsCSV[0].endIndex != parsedTargetsCSV[0].endIndex) {return nil}
        
        let setsCount = parsedInputsCSV[0].endIndex
        let biggerPart = Int(setsCount * 8 / 10)
        
        parsedInputsCSV = Array(parsedInputsCSV[0..<256])
        let training_inputs = parsedInputsCSV.map {Array($0.prefix(biggerPart))}
        let test_inputs = parsedInputsCSV.map {Array($0[biggerPart..<setsCount])}
        let inputs = (Matrix(from: training_inputs), Matrix(from: test_inputs))
        
        parsedTargetsCSV = parsedTargetsCSV[0].map {intToOneHot($0)}
        let training_targets = Array(parsedTargetsCSV.prefix(biggerPart))
        let test_targets = Array(parsedTargetsCSV[biggerPart..<setsCount])
        let targets = (Matrix(from: training_targets).transposed(), Matrix(from: test_targets).transposed())
        
        return (inputs, targets)
    } else {
        return nil
    }
}

private func intToOneHot(_ value: Int) -> [Int] {
    var out: [Int] = Array(repeating: 0, count: 10)
    out[value] = 1
    return out
}

private func parseCSV<T: Numeric>(_ csv: String, _ convert: (String) -> T) -> [[T]] {
    return csv.components(separatedBy: "\n").map {$0.components(separatedBy: ",").map {convert($0)}}
}

private func loadFile(_ name: String) -> String? {
    do {
        return try String(contentsOfFile: "/Users/vadim.turko/Documents/Projects/detect_numbers/\(name).csv")
    } catch {
        print(error)
        return nil
    }
}
