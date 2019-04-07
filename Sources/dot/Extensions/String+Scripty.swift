//
//  String+.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/04/07.
//

import Foundation
import Scripty

extension String {
    
    enum Color: Int {
        case black = 30
        case red
        case green
        case yellow
        case brue
        case magenta
        case cyan
        case white
    }
    
    func colorize(color: String.Color) -> String {
        return "\u{1b}[\(color.rawValue)m\(self)"
    }
    
    func echo(overwrite: Bool = false, newline: Bool = true) {
        let overwriteAnsiEscape = overwrite ? "\r" : ""
        let newlineOption = newline ? "" : " -n"
        let script = Scripty.builder
            | "echo\(newlineOption) \"\(overwriteAnsiEscape)\(self)\""
        script.exec()
    }
}
