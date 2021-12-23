//
//  matrix.swift
//  matrix
//
//  Created by Vadim Turko on 12/23/21.
//

import Foundation

infix operator ~

class Matrix {
    var _m: [[Double]] = []
    
    let rows: Int
    let columns: Int
    var shape: (Int, Int) {
        get {return (rows, columns)}
    }
    
    init(columns: Int, rows: Int, fill: Double?) {
        self._m = Array(repeating: fill != nil
                        ? Array(repeating: fill!, count: columns)
                        : (0..<columns).map { _ in .random(in: 0...255) }, count: rows)
        self.rows = rows
        self.columns = columns
    }
    
    init(from arrays: [[Double]]) {
        self._m = arrays
        self.rows = arrays.endIndex
        self.columns = arrays.first!.endIndex
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
    
    func printMatrix() {
        print(_m)
    }
    
    subscript(index:Int) -> Array<Double> {
        get {
            return _m[index]
        }
        set(newElm) {
            _m[index] = newElm
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
    static func ~(a: Matrix, b: Matrix) throws -> Matrix {
        if (a.columns != b.rows) {
            throw "Sizes of matrices must be equal"
        } else {
            let transposedB: Matrix = b.transposed()
            let result: Matrix = Matrix(columns: b.columns, rows: a.rows, fill: 0)
            for i in 0..<a.rows {
                let rowA = a[i]
                for j in 0..<b.columns {
                    let colB = transposedB[j]
                    let sum: Double = (zip(rowA, colB).map {$0 * $1}).reduce(0, +)
                    result[i][j] = sum
                }
            }
            return result
        }
    }
    
    static private func elementWise(_ a: Matrix, _ b: Matrix, _ operation: (Double, Double) -> Double) throws -> Matrix {
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
