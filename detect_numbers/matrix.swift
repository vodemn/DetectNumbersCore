//
//  matrix.swift
//  matrix
//
//  Created by Vadim Turko on 12/23/21.
//

import Foundation
import Accelerate

class Matrix {
    var values: [Double] = []
    let columns: Int
    var rows: Int
    
    var shape: (Int, Int) {
        get {return (rows, columns)}
    }
    
    var min: Double {
        get {return self.values.min()!}
    }
    
    var max: Double {
        get {return self.values.max()!}
    }
    
    init(columns: Int, rows: Int, fill: Double) {
        self.columns = columns
        self.rows = rows
        self.values = Array(repeating: fill, count: rows*columns)
    }
    
    init(from arrays: [[Double]]) {
        self.columns = arrays.first!.endIndex
        self.rows = arrays.endIndex
        self.values = arrays.flatMap {$0}
    }
    
    init(from array: [Double], columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        self.values = array
    }
    
    func copy() -> Matrix {
        return Matrix(from: self.values, columns: self.columns, rows: self.rows)
    }
    
    func appendRow(row: Array<Double>) {
        precondition(row.endIndex == self.columns, "Cannot append row of size \(row.endIndex)")
        self.values.append(contentsOf: row)
        self.rows = Int(values.endIndex / self.columns)
    }
}

// Transformation
extension Matrix {
    func apply(_ function: (Double) -> Double) -> Matrix {
        return Matrix.init(from: self.values.map {function($0)}, columns: columns, rows: rows)
    }
    
    func applyOnRows(_ function: ([Double]) -> [Double]) -> Matrix {
        var result: [Double] = []
        for subsequence in self.values.unfoldSubSequences(limitedTo: self.columns) {
            result.append(contentsOf: function(Array(subsequence)))
        }
        return Matrix.init(from: result, columns: columns, rows: rows)
    }
    
    func applyOnColumns(_ function: ([Double]) -> [Double]) -> Matrix {
        return transposed().applyOnRows(function).transposed()
    }
}

// Operators
infix operator ~*

extension Matrix {
    
    // Element-wise operations
    static func +(a: Matrix, b: Matrix) -> Matrix {elementWise(a, b, +)}
    
    static func -(a: Matrix, b: Matrix) -> Matrix {elementWise(a, b, -)}
    
    static func *(a: Matrix, b: Matrix) -> Matrix {elementWise(a, b, *)}
    
    static func *(a: Matrix, b: Double) -> Matrix {elementWise(a, b, *)}
    
    static func /(a: Matrix, b: Double) -> Matrix {elementWise(a, b, /)}
    
    private static func elementWise(_ a: Matrix, _ b: Matrix, _ operation: (Double, Double) -> Double) -> Matrix {
        if (a.shape != b.shape) {
            fatalError("Sizes of matrices must be equal")
        } else {
            let result = zip(a.values, b.values).map{operation($0.0, $0.1)}
            return Matrix(from: result, columns: a.columns, rows: a.rows)
        }
    }
    
    private static func elementWise(_ a: Matrix, _ b: Double, _ operation: (Double, Double) -> Double) -> Matrix {
        let result = a.values.map{operation($0, b)}
        return Matrix(from: result, columns: a.columns, rows: a.rows)
    }
    
    // Basic matrix multiplication
    static func ~*(a: Matrix, b: Matrix) -> Matrix {
        if (a.columns != b.rows) {
            fatalError("Sizes of matrices must be equal")
        } else {
            var c: [Double] = Array(repeating: 0, count: a.rows * b.columns)
            vDSP_mmulD(a.values, vDSP_Stride(1),
                       b.values, vDSP_Stride(1),
                       &c, vDSP_Stride(1),
                       vDSP_Length(a.rows),
                       vDSP_Length(b.columns),
                       vDSP_Length(b.rows))
            return Matrix(from: c, columns: b.columns, rows: a.rows)
        }
    }
}

// Subscripts
extension Matrix {
    public subscript(range: CountableRange<Int>) -> Matrix {
        get {
            precondition(range.upperBound <= rows, "Invalid range")
            let ran = (range.lowerBound * self.columns)..<(range.upperBound * self.columns)
            return Matrix(from: Array(self.values[ran]), columns: columns, rows: range.upperBound - range.lowerBound)
    
        }
    }
}

// Transpose
extension Matrix {
    public func transposed() -> Matrix {
        let results = Matrix(columns: rows, rows: columns, fill: 0)
        let rows = vDSP_Length(results.rows)
        let columns = vDSP_Length(results.columns)
        values.withUnsafeBufferPointer { srcPtr in
            vDSP_mtransD(srcPtr.baseAddress!, 1, &results.values, 1, rows, columns)
        }
        return results
    }
}

extension Collection {
    func unfoldSubSequences(limitedTo maxLength: Int) -> UnfoldSequence<SubSequence,Index> {
        sequence(state: startIndex) { start in
            guard start < self.endIndex else { return nil }
            let end = self.index(start, offsetBy: maxLength, limitedBy: self.endIndex) ?? self.endIndex
            defer { start = end }
            return self[start..<end]
        }
    }
}

extension String: LocalizedError {}

// Test of matrix operators
func testMatrixOperators() {
    let a: Matrix = Matrix(from: [[1, 2], [3, 4], [5, 6], [7, 8]])
    let b: Matrix = Matrix(from: [[1, 2, 3], [4, 5, 6]])
    print("Add:")
    print((a + a).values)
    print("Substract:")
    print((a - a).values)
    print("Multiply element-wise:")
    print((a * a).values)
    print("Multiply:")
    let c: Matrix = a ~* b
    print(c.shape)
    print(c.values)
}
