//
//  Ikaros.swift
//  JRPlayListTool
//
//  Created by ikaros on 2022/4/6.
//

import Foundation

struct ikaros<T> {
    var base: T
    init(_ base: T) {
        self.base = base
    }
}
protocol ikarosCompatible {}
extension ikarosCompatible { var ikaros: ikaros<Self> { JRPlayListTool.ikaros(self) } }
