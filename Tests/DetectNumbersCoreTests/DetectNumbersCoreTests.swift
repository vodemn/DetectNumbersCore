import XCTest
@testable import DetectNumbersCore

final class DetectNumbersCoreTests: XCTestCase {
    func testExample() throws {
        let dataset: ((Matrix, Matrix), (Matrix, Matrix))? = loadDataset()
        if (dataset != nil) {
            let network: Core = Core(inputSize: dataset!.0.0.rows, outputSize: dataset!.1.0.rows, neurons: 10, lr: 0.4)
            network.train(inputs: dataset!.0.0, targets: dataset!.1.0, epochs: 100)
            network.test(inputs: dataset!.0.1, targets: dataset!.1.1)
        }
    }
}
