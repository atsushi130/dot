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
        guard let githubAccessToken = UserDefaults.standard.string(forKey: "GITHUB_ACCESS_TOKEN") else { return nil }
        return [
            "Authorization": "token \(githubAccessToken)"
        ]
    }
}
