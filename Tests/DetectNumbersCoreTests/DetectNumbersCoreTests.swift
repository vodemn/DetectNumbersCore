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
        if let dataset = loadDataset() {
            let network: Core = Core(inputSize: dataset.0.0.rows, outputSize: dataset.1.0.rows, neurons: 10)
            network.train(inputs: dataset.0.0, targets: dataset.1.0, epochs: 380, lr: 0.4)
            _ = network.test(inputs: dataset.0.1, targets: dataset.1.1)
        }
    }
    
    func testSaveAndRestore() throws {
        let dataset: ((Matrix, Matrix), (Matrix, Matrix))? = loadDataset()
        
        let network: Core = Core(inputSize: dataset!.0.0.rows, outputSize: dataset!.1.0.rows, neurons: 10)
        network.train(inputs: dataset!.0.0, targets: dataset!.1.0, epochs: 380, lr: 0.4)
        let originalResult = network.test(inputs: dataset!.0.1, targets: dataset!.1.1)
        
        let restoredNetwork: Core = Core(weightArrays: restoreDensesFromFile())
        let restoredResult = restoredNetwork.test(inputs: dataset!.0.1, targets: dataset!.1.1)
        
        XCTAssertEqual(originalResult, restoredResult)
    }
    
    func testDetection() throws {
        let dataset: ((Matrix, Matrix), (Matrix, Matrix))? = loadDataset()
        let restoredNetwork: Core = Core(weightArrays: restoreDensesFromFile())
        let result = restoredNetwork.detect(input: dataset!.0.1.transposed().valuesAsMatrix[0])
        let detectedNumberP = result.max()!
        let detectedNumber = result.firstIndex(of: detectedNumberP)!
        print((detectedNumber, String(format: "%.1f", (detectedNumberP * 100))))
    }
}
