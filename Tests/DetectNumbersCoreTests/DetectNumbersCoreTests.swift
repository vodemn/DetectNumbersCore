import XCTest
@testable import DetectNumbersCore

final class DetectNumbersCoreTests: XCTestCase {
    func testMatrixOperators() throws {
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

    func testTraining() throws {
        let dataset: ((Matrix, Matrix), (Matrix, Matrix))? = loadDataset()
        if (dataset != nil) {
            let network: Core = Core(inputSize: dataset!.0.0.rows, outputSize: dataset!.1.0.rows, neurons: 10)
            network.train(inputs: dataset!.0.0, targets: dataset!.1.0, epochs: 380, lr: 0.4)
            network.test(inputs: dataset!.0.1, targets: dataset!.1.1)
        }
    }
}
