//
//  DotConfiguration.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Foundation

struct GithubFile: Decodable {
    let name: String
    let content: String
    
    var decodedContent: String {
        let removedEscapedReturn = self.content.replacingOccurrences(of: "\n", with: "")
        guard let data = Data(base64Encoded: removedEscapedReturn),
              let decoded = String(data: data, encoding: .utf8) else { return "" }
        return decoded
    }
}
