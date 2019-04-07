//
//  Install+Error.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/04/06.
//

import Foundation

extension Install {
    enum Error: Swift.Error {
        case filenameNotFound
        case githubAccessTokenNotFound
        case githubDotfilesRepositoryNotFound
        case undefinedInDotJson(resourceName: String)
        case undefinedChainInDotJson(resourceName: String)
        case referenceResourceError(resourceError: GithubApi.ResourceService.Error)
        
        var message: String {
            switch self {
            case .filenameNotFound:
                return """
                Argument not found. Please input filename.
                ❯ dot install filename
                """
            case .githubAccessTokenNotFound:
                return """
                Github access token not found. Please register it.
                ❯ dot token ******
                """
            case .githubDotfilesRepositoryNotFound:
                return """
                Github dotfiles repository not found. Please register it.
                ❯ dot repository owner/repository
                """
            case .undefinedInDotJson(let resourceName):
                return """
                Undefined \(resourceName) in dot.json. Please define dotfile information according to dot.json format.
                document: https://github.com/atsushi130/dot#configuration
                example:  https://github.com/atsushi130/dotfiles/blob/master/dot.json
                """
            case .undefinedChainInDotJson(let resourceName):
                return "Undefined chain in \(resourceName). No chain option is required."
            case let .referenceResourceError(resourceError):
                return resourceError.message
            }
        }
    }
}
