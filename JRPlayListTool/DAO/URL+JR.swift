//
//  URL+JR.swift
//  JRPlayListTool
//
//  Created by ikaros on 2022/4/16.
//

import Foundation

extension URL {
    var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
