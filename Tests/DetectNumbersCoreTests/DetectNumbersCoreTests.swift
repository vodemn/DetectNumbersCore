import XCTest
@testable import DetectNumbersCore

final class DetectNumbersCoreTests: XCTestCase {
    
    func testTraining() throws {
        let dataset = loadDataset()!
        let network: Core = Core(inputSize: dataset.0.0.rows, outputSize: dataset.1.0.rows, neurons: 10)
        network.train(inputs: dataset.0.0, targets: dataset.1.0, epochs: 380, lr: 0.4)
        _ = network.test(inputs: dataset.0.1, targets: dataset.1.1)
    }
    
    func testSaveAndRestore() throws {
        let dataset = loadDataset()!
        let network: Core = Core(inputSize: dataset.0.0.rows, outputSize: dataset.1.0.rows, neurons: 10)
        network.train(inputs: dataset.0.0, targets: dataset.1.0, epochs: 380, lr: 0.4)
        let originalResult = network.test(inputs: dataset.0.1, targets: dataset.1.1)
        network.saveDensesToFile()
        
        let restoredNetwork: Core = Core(weightArrays: savedDenses)
        let restoredResult = restoredNetwork.test(inputs: dataset.0.1, targets: dataset.1.1)
        
        XCTAssertEqual(originalResult, restoredResult)
    }
    
    func testDetection() throws {
        let dataset = loadDataset()!
        let restoredCore = DetectNumbersCore()
        let result = restoredCore.detect(input: dataset.0.1.transposed().valuesAsMatrix[0])
        print(restoredCore.inputSize)
        let detectedNumberP = result.max()!
        let detectedNumber = result.firstIndex(of: detectedNumberP)!
        print((detectedNumber, String(format: "%.1f", (detectedNumberP * 100))))
    }
    
    func testMNISTParse() {
        saveMNIST()
    }
    
    func testMNISTInit() {
        let trainSet = parseMNISTFile("mnist_train")!
        let network: Core = Core(inputSize: trainSet.inputs.rows, outputSize: trainSet.targets.rows, neurons: trainSet.inputs.rows)
        network.train(inputs: trainSet.inputs, targets: trainSet.targets, epochs: 100, lr: 0.4)
        
        let testSet = parseMNISTFile("mnist_test")!
        _ = network.test(inputs: testSet.inputs, targets: testSet.targets)
    }
}
