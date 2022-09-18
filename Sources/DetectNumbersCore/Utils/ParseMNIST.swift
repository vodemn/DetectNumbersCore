//
//  ParseMNIST.swift
//  
//
//  Created by Vadim Turko on 9/18/22.
//
import Foundation

func saveMNIST() {
    let fileURL = getFileURL(filename: "Generated/MNIST.swift")
    try? FileManager.default.removeItem(at: fileURL)
    try! "".write(to: fileURL, atomically: true, encoding: .utf8)
    let fileHandle = FileHandle(forWritingAtPath: fileURL.path)
    
    let trainSet = parseMNISTFile("mnist_train")
    fileHandle!.saveArray(trainSet!.inputs.valuesAsMatrix, name: "trainInputs")
    fileHandle!.saveArray(trainSet!.targets.valuesAsMatrix, name: "trainTargets")
    
    let testSet = parseMNISTFile("mnist_test")
    fileHandle!.saveArray(testSet!.inputs.valuesAsMatrix, name: "testInputs")
    fileHandle!.saveArray(testSet!.targets.valuesAsMatrix, name: "testTargets")

    try? fileHandle?.close()
}

extension FileHandle {
    func saveArray(_ array: [[Double]], name: String) {
        if let data = try? JSONSerialization.data(withJSONObject: array, options: []) {
            self.write("let \(name) = ".data(using: .utf8)!)
            self.write(data)
            self.write("\n".data(using: .utf8)!)
        }
    }
}

func parseMNISTFile(_ filename: String) -> (inputs: Matrix, targets: Matrix)? {
    if let train = loadFile(filename) {
        let lines: [String] = train.components(separatedBy: "\n")
        // First line of MNIST set is header, needed to be removed
        let rows: [[String]] = Array(lines[1..<lines.endIndex]).map { $0.components(separatedBy: ",") }
        
        var inputs: [[Double]] = []
        var targets: [[Double]] = []
        for row in rows {
            inputs.append(Array(row[1..<row.endIndex]).map { Double(Int($0) ?? 0 / 255) })
            targets.append(toOneHot(Int(row.first!)!))
        }
        
        let inputsMatrix = Matrix(from: inputs)
        let targetsMatrix = Matrix(from: targets)
        return (inputsMatrix.transposed(), targetsMatrix.transposed())
    } else {
        return nil
    }
}

private func toOneHot(_ index: Int) -> [Double] {
    var array = [Double](repeating: 0, count: 10)
    array[index] = 1
    return array
}

private func loadFile(_ name: String) -> String? {
    do {
        return try String(contentsOf: getFileURL(filename: "Dataset/\(name).csv"))
    } catch {
        print(error)
        return nil
    }
}
