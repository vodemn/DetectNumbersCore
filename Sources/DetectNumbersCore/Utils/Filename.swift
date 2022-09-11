//
//  Filename.swift
//  
//
//  Created by Vadim Turko on 9/11/22.
//

import Foundation

func getFileUrl(filename: String) -> URL {
    return URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent(filename)
}
