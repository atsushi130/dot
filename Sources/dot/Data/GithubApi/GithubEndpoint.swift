//
//  GithubEndpoint.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Moya
import Foundation

protocol GithubEndpoint: TargetType {}

extension GithubEndpoint {
    
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String : String]? {
        return [
            "Authorization": "token cd6b83382a3888c6504ddd21f6216d403a1c16b7"
        ]
    }
}
