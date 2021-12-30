//
//  matrix.swift
//  matrix
//
//  Created by Vadim Turko on 12/23/21.
//

import Foundation

infix operator ~*

class Matrix {
    var _m: [[Double]] = []
    
    var rows: Int {
        get {return _m.endIndex}
    }
    var columns: Int {
        get {return _m.first!.endIndex}
    }
    var shape: (Int, Int) {
        get {return (rows, columns)}
    }
    
    var values: [[Double]] {
        get {return _m}
    }
    
    init(columns: Int, rows: Int, fill: Double) {
        self._m = Array(repeating: Array(repeating: fill, count: columns), count: rows)
    }
    
    init(from arrays: [[Double]]) {
        self._m = arrays
    }
    
    func copy() -> Matrix {
        return Matrix(from: self._m)
    }
    
    func appendRow(row: Array<Double>) throws {
        if (row.endIndex != _m.first?.endIndex) {
            throw "Cannot append row (size: \(row.endIndex))"
        }
        self._m.append(contentsOf: [row])
    }
    
    func appendColumn(column: Array<Double>) throws {
        if (column.endIndex != _m.endIndex) {
            throw "Cannot append column (size: \(column.endIndex))"
        } else {
            for (index, _) in self._m.enumerated() {
                self._m[index].append(contentsOf: [column[index]])
            }
        }
        
    }
    
    subscript(index:Int) -> Array<Double> {
        get {
            return _m[index]
        }
        set(newElm) {
            _m[index] = newElm
        }
    }
    
    subscript(range:Range<Int>) -> Matrix {
        get {
            return Matrix(from: Array(_m[range]))
        }
    }
    
    func transposed() -> Matrix {
        var result = [[Double]]()
        for index in 0..<_m.first!.count {
            // About map https://habr.com/ru/post/440722/
            result.append(_m.map{$0[index]})
        }
        return Matrix(from: result)
    }
    
    static func +(a: Matrix, b: Matrix) throws -> Matrix {try elementWise(a, b, +)}
    
    static func -(a: Matrix, b: Matrix) throws -> Matrix {try elementWise(a, b, -)}
    
    static func *(a: Matrix, b: Matrix) throws -> Matrix {try elementWise(a, b, *)}
    
    // Basic matrix multiplication
    static func ~*(a: Matrix, b: Matrix) throws -> Matrix {
        if (a.columns != b.rows) {
            throw "Sizes of matrices must be equal"
        } else {
            let transposedB: Matrix = b.transposed()
            let result: Matrix = Matrix(columns: b.columns, rows: a.rows, fill: 0)
            
            // TODO rewrite so it works faster
            for i in 0..<a.rows {
                let rowA = a[i]
                for j in 0..<b.columns {
                    let colB = transposedB[j]
                    result[i][j] = (zip(rowA, colB).map {$0 * $1}).reduce(0, +)
                }
            }
            return result
        }
    }
    
    static func elementWise(_ a: Matrix, _ b: Matrix, _ operation: (Double, Double) -> Double) throws -> Matrix {
        if (a.rows != b.rows && a.columns != b.columns) {
            throw "Sizes of matrices must be equal"
        } else {
            let result: Matrix = Matrix(columns: a.columns, rows: a.rows, fill: 0)
            for i in 0..<a.rows {
                for j in 0..<a.columns {
                    result[i][j] = operation(a[i][j], b[i][j])
                }
            }
            return result
        }
    }
    
    func apply(_ function: (Double) -> Double) {
        self._m = self._m.map {$0.map {function($0)}}
    }
    
    func applyOnRows(_ function: ([Double]) -> [Double]) {
        self._m = self._m.map {function($0)}
    }
}

extension String: LocalizedError {}

// Test of matrix operators
func testMatrixOperators() throws {
    let a: Matrix = Matrix(from: [[1, 2], [3, 4], [5, 6], [7, 8]])
    let b: Matrix = Matrix(from: [[1, 2, 3], [4, 5, 6]])
    print(a.shape)
    print(b.shape)
    do {
        print("Add:")
        (try print((a + a).values))
        print("Substract:")
        (try print((a - a).values))
        print("Multiply element-wise:")
        (try print((a * a).values))
        print("Multiply:")
        let c: Matrix = try a ~* b
        print(c.shape)
        print(c.values)
    }
}
