//
//  JSONDecoder+.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Foundation

extension JSONDecoder {
    static var snakeCaseDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
