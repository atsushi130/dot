//
//  GithubResource.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Foundation

struct GithubResource: Decodable {
    let name: String
    let content: String
    let type: ResourceType
    let path: String

    var decodedContent: String {
        let removedEscapedReturn = self.content.replacingOccurrences(of: "\n", with: "")
        guard let data = Data(base64Encoded: removedEscapedReturn),
              let decoded = String(data: data, encoding: .utf8) else { return "" }
        return decoded
    }
    
    enum ResourceType: String, Decodable {
        case file
        case dir
    }
}
