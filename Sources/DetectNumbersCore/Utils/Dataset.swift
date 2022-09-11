//
//  utils.swift
//  utils
//
//  Created by Vadim Turko on 12/25/21.
//

import Foundation

func loadDataset() -> ((Matrix, Matrix), (Matrix, Matrix))? {
    let inputsCSV = loadFile("inputs")
    let targetsCSV = loadFile("targets")
    if (inputsCSV != nil && targetsCSV != nil) {
        var parsedInputsCSV: [[Double]] = parseCSV(inputsCSV!, {Double($0) ?? 0})
        var parsedTargetsCSV: [[Double]] = parseCSV(targetsCSV!, {Double($0) ?? 0})
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

private func intToOneHot(_ value: Double) -> [Double] {
    var out: [Double] = Array(repeating: 0, count: 10)
    out[Int(value)] = 1
    return out
}

private func parseCSV<T: Numeric>(_ csv: String, _ convert: (String) -> T) -> [[T]] {
    return csv.components(separatedBy: "\n").map {$0.components(separatedBy: ",").map {convert($0)}}
}

private func loadFile(_ name: String) -> String? {
    do {
        let packageURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let fileURL = packageURL.appendingPathComponent("\(name).csv")
        return try String(contentsOf: fileURL)
        //return try String(contentsOfFile: "/Users/vadim.turko/Documents/Projects/detect_numbers/\(name).csv")
    } catch {
        print(error)
        return nil
    }
}
