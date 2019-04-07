//
//  Version.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/04/06.
//

import Foundation
import Commandy

enum Version: Command {
    static func run() throws {
        print("dot v1.1.1 2019-04-08")
        exit(EXIT_SUCCESS)
    }
}
