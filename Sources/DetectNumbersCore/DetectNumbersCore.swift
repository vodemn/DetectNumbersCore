public struct DetectNumbersCore {
    let core: Core
    
    public var inputSize: (Int, Int) {
        get {return self.core.inputSize}
    }
    
    public init() {
        self.core = Core(weightArrays: savedDenses)
    }
    
    public func detect(input: [Double]) -> [Double] {
        return self.core.detect(input: input)
    }
    
    public func mostProbableNumber(input: [Double]) -> (Int, Double) {
        let result = self.detect(input: input)
        let detectedNumberP = result.max()!
        let detectedNumber = result.firstIndex(of: detectedNumberP)!
        return (detectedNumber, detectedNumberP)
    }
}
