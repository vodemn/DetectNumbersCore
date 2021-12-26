//
//  matrix.swift
//  matrix
//
//  Created by Vadim Turko on 12/23/21.
//

import Foundation

infix operator ~*

class Matrix<T: Numeric> {
    var _m: [[T]] = []
    
    let rows: Int
    let columns: Int
    var shape: (Int, Int) {
        get {return (rows, columns)}
    }
    
    init(columns: Int, rows: Int, fill: T) {
        self._m = Array(repeating: Array(repeating: fill, count: columns), count: rows)
        self.rows = rows
        self.columns = columns
    }
    
    init(from arrays: [[T]]) {
        self._m = arrays
        self.rows = arrays.endIndex
        self.columns = arrays.first!.endIndex
    }
    
    func appendRow(row: Array<T>) throws {
        if (row.endIndex != _m.first?.endIndex) {
            throw "Cannot append row (size: \(row.endIndex))"
        }
        self._m.append(contentsOf: [row])
    }
    
    func appendColumn(column: Array<T>) throws {
        if (column.endIndex != _m.endIndex) {
            throw "Cannot append column (size: \(column.endIndex))"
        } else {
            for (index, _) in self._m.enumerated() {
                self._m[index].append(contentsOf: [column[index]])
            }
        }
        
    }
    
    func printMatrix() {
        print(_m)
    }
    
    subscript(index:Int) -> Array<T> {
        get {
            return _m[index]
        }
        set(newElm) {
            _m[index] = newElm
        }
    }
    
    func transposed() -> Matrix<T> {
        var result = [[T]]()
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
            for i in 0..<a.rows {
                let rowA = a[i]
                for j in 0..<b.columns {
                    let colB = transposedB[j]
                    let sum: T = (zip(rowA, colB).map {$0 * $1}).reduce(0, +)
                    result[i][j] = sum
                }
            }
            return result
        }
    }
    
    static private func elementWise(_ a: Matrix<T>, _ b: Matrix<T>, _ operation: (T, T) -> T) throws -> Matrix<T> {
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
        (try a + a).printMatrix()
        print("Substract:")
        (try a - a).printMatrix()
        print("Multiply element-wise:")
        (try a * a).printMatrix()
        print("Multiply:")
        let c: Matrix = try a ~* b
        print(c.shape)
        c.printMatrix()
    }
}
