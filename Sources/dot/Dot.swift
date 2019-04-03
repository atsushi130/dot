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
    case token
    case repository
    
    func run() throws {
        switch self {
        case .install: try Install.run()
        case .token:      try GithubTokenRegister.run()
        case .repository: try DotfilesRepositoryRegister.run()
        }
    }
}
