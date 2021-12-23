//
//  main.swift
//  detect_numbers
//
//  Created by Vadim Turko on 12/23/21.
//

import Foundation

print("Hello, World!")

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
    let c: Matrix = try a ~ b
    print(c.shape)
    c.printMatrix()
}
