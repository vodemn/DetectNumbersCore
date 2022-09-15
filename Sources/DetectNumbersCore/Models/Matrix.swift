//
//  Matrix.swift
//  Matrix
//
//  Created by Vadim Turko on 12/23/21.
//

import Foundation
import Accelerate

public class Matrix {
    //
    //  Values are stored row-by-row:
    //
    //  [1, 2, 3, 4, 5, 6, 7, 8, 9]
    //
    //  [1, 2, 3,
    //   4, 5, 6,
    //   7, 8, 9]
    //
    var values: [Double] = []
    public let columns: Int
    public private(set) var rows: Int
    
    public var shape: (Int, Int) {
        get {return (rows, columns)}
    }
    
    var min: Double {
        get {return self.values.min()!}
    }
    
    var max: Double {
        get {return self.values.max()!}
    }
    
    var valuesAsMatrix: [[Double]] {
        get {return self.values.chunked(into: self.columns)}
    }
    
    public init(fill: Double, shape: (Int, Int)) {
        self.rows = shape.0
        self.columns = shape.1
        self.values = Array(repeating: fill, count: rows*columns)
    }
    
    public init(from arrays: [[Double]]) {
        self.rows = arrays.endIndex
        self.columns = arrays.first!.endIndex
        self.values = arrays.flatMap {$0}
    }
    
    public init(from array: [Double], shape: (Int, Int)) {
        self.rows = shape.0
        self.columns = shape.1
        self.values = array
    }
}

// Useful getters
extension Matrix {
    func maxInColumns() -> [Int] {
        var result: [Int] = []
        for subsequence in transposed().values.unfoldSubSequences(limitedTo: rows) {
            result.append(Int(vDSP.indexOfMaximum(subsequence).0))
        }
        return result
    }
}

// Transformation
extension Matrix {
    func apply(_ function: (Double) -> Double) -> Matrix {
        return Matrix.init(from: values.map {function($0)}, shape: shape)
    }
    
    func applyOnRows(_ function: ([Double]) -> [Double]) -> Matrix {
        var result: [Double] = []
        for subsequence in values.unfoldSubSequences(limitedTo: columns) {
            result.append(contentsOf: function(Array(subsequence)))
        }
        return Matrix.init(from: result, shape: shape)
    }
    
    func applyOnColumns(_ function: ([Double]) -> [Double]) -> Matrix {
        return transposed().applyOnRows(function).transposed()
    }
    
    func appendRow(row: Array<Double>) -> Matrix {
        assert(row.endIndex == columns, "Cannot append row of size \(row.endIndex)")
        return Matrix(from: (values + row), shape: (rows + 1, columns))
    }
}

// Operators
infix operator ~*

extension Matrix {
    
    // Element-wise operations
    static func +(a: Matrix, b: Matrix) -> Matrix {
        return Matrix(from: vDSP.add(a.values, b.values), shape: a.shape)
    }
    
    static func -(a: Matrix, b: Matrix) -> Matrix {
        return Matrix(from: vDSP.subtract(a.values, b.values), shape: a.shape)
    }
    
    static func *(a: Matrix, b: Matrix) -> Matrix {
        return Matrix(from: vDSP.multiply(a.values, b.values), shape: a.shape)
    }
    
    static func *(a: Matrix, b: Double) -> Matrix {
        return Matrix(from: vDSP.multiply(b, a.values), shape: a.shape)
    }
    
    static func /(a: Matrix, b: Double) -> Matrix {
        return Matrix(from: vDSP.divide(a.values, b), shape: a.shape)
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
            return Matrix(from: c, shape: (a.rows, b.columns))
        }
    }
}

// Subscripts
extension Matrix {
    public subscript(range: CountableRange<Int>) -> Matrix {
        get {
            precondition(range.upperBound <= rows, "Invalid range")
            return Matrix(from: Array(self.valuesAsMatrix[range]))
            
        }
    }
}

// Transpose
extension Matrix {
    public func transposed() -> Matrix {
        let results = Matrix(fill: 0, shape: (columns, rows))
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

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
