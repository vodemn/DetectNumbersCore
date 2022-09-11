//
//  TrainedCore.swift
//  
//
//  Created by Vadim Turko on 9/11/22.
//

import Foundation

extension Core {
    func saveDensesToFile() {
        let fileURL = getFileUrl(filename: "Generated/TrainedCoreValues.txt")
        try! FileManager.default.removeItem(at: fileURL)
        var fileHandle: FileHandle?
        try! self.layers.forEach { layer in
            if let data = try? JSONSerialization.data(withJSONObject: layer.w.valuesAsMatrix, options: []) {
                if (fileHandle != nil)  {
                    defer {
                        fileHandle!.closeFile()
                    }
                    fileHandle!.seekToEndOfFile()
                    fileHandle!.write("\n".data(using: .utf8)!)
                    fileHandle!.write(data)
                }
                else {
                    try data.write(to: fileURL, options: .atomic)
                    fileHandle = FileHandle(forWritingAtPath: fileURL.path)
                }
            }
        }
    }
}

extension Matrix {
    func appendMatrixToFile() throws {
        if let data = try? JSONSerialization.data(withJSONObject: self.valuesAsMatrix, options: []) {
            let fileURL = getFileUrl(filename: "Generated/TrainedCoreValues.txt")
            if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                defer {
                    fileHandle.closeFile()
                }
                fileHandle.seekToEndOfFile()
                
                fileHandle.write("\n".data(using: .utf8)!)
                fileHandle.write(data)
            }
            else {
                try data.write(to: fileURL, options: .atomic)
            }
        }
    }
}

