//
//  FileURL.swift
//  
//
//  Created by Vadim Turko on 9/11/22.
//

import Foundation

func getFileURL(filename: String) -> URL {
    return URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent(filename)
}
