import XCTest
@testable import DetectNumbersCore

final class MatrixTests: XCTestCase {
    let a: Matrix = Matrix(from: [[1, 2], [3, 4], [5, 6], [7, 8]])
    let b: Matrix = Matrix(from: [[1, 2, 3], [4, 5, 6]])
    
    func testAddOperator() throws {
        print("Add:")
        print((a + a).values)
    }
    
    func testSubtractOperator() throws {
        print("Substract:")
        print((a - a).values)
    }
    
    func testMultiplyElementWiseOperator() throws {
        print("Multiply element-wise:")
        print((a * a).values)
    }
    
    func testMultiplyOperator() throws {
        print("Multiply:")
        let c: Matrix = a ~* b
        print(c.shape)
        print(c.values)
    }
    
    func testSubscript() throws {
        let c = Matrix(from: [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3], [4, 4, 4, 4]])
        print(c[1..<3].valuesAsMatrix)
    }
}
