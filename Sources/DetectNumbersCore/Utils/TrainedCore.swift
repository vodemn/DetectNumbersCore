//
//  TrainedCore.swift
//  
//
//  Created by Vadim Turko on 9/11/22.
//

import Foundation

let fileURL = getFileUrl(filename: "Generated/TrainedCoreValues.txt")

extension Core {
    func saveDensesToFile() {
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

func restoreDensesFromFile() -> [[[Double]]] {
    let content = try! String(contentsOf: fileURL, encoding: .utf8)
    var result: [[[Double]]] = []
    content.enumerateSubstrings(in: content.startIndex..<content.endIndex, options: .byLines) {
        (substring, range, _, __) in
        guard let substring = substring else { return }
        let array = try! JSONSerialization.jsonObject(with: Data(substring.utf8)) as! [[Double]]
        result.append(array)
    }
    return result
}
