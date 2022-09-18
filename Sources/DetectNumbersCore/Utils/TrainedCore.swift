//
//  TrainedCore.swift
//  
//
//  Created by Vadim Turko on 9/11/22.
//

import Foundation

//let fileURL = getFileUrl(filename: "Generated/TrainedCoreValues.txt")
let fileURL = getFileUrl(filename: "Generated/TrainedCoreValues.swift")

extension Core {
    func saveDensesToFile() {
        try? FileManager.default.removeItem(at: fileURL)
        try! "".write(to: fileURL, atomically: true, encoding: .utf8)
        let fileHandle = FileHandle(forWritingAtPath: fileURL.path)
        fileHandle!.write("let savedDenses = [".data(using: .utf8)!)
        self.layers.forEach { layer in
            if let data = try? JSONSerialization.data(withJSONObject: layer.w.valuesAsMatrix, options: []) {
                fileHandle!.write("\n   ".data(using: .utf8)!)
                fileHandle!.write(data)
                fileHandle!.write(",".data(using: .utf8)!)
            }
        }
        fileHandle!.write("\n]".data(using: .utf8)!)
    }
}
