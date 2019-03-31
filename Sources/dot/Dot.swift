//
//  Dot.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Foundation
import Commandy

enum Dot: String, Cli {
    
    case install
    
    func run() throws {
        switch self {
        case .install: try Install.run()
        }
    }
}
