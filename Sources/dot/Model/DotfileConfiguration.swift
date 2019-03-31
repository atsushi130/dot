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

extension DotfileConfiguration {
    enum Error: Swift.Error {
        case invalidDotfileConfiguration
        var message: String {
            switch self {
            case .invalidDotfileConfiguration:
                return "invald `dot.json`. please confirm to format."
            }
        }
    }
}
