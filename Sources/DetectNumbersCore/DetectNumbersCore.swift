public struct DetectNumbersCore {
    let core: Core
    
    public init() {
        self.core = Core(weightArrays: restoreDensesFromFile())
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
