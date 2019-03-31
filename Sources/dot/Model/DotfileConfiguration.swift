//
//  Dotfile.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Foundation

struct DotfileConfiguration: Decodable {
    let name: String
    let input: String
    let output: String
    let chain: [String]?
}
