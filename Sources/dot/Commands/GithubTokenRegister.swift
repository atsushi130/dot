//
//  GithubTokenRegister.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Foundation
import Commandy

enum GithubTokenRegister: Command {
    static func run() throws {
        guard let githubAccessToken = Arguments.cached.nonOptionArguments.first else { throw GithubTokenRegister.Error.tokenNotFound }
        UserDefaults.standard.setValue(githubAccessToken, forKey: "GITHUB_ACCESS_TOKEN")
        exit(EXIT_SUCCESS)
    }
}

// MARK: Error
extension GithubTokenRegister {
    enum Error: Swift.Error {
        case tokenNotFound
    }
}
