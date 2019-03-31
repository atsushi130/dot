//
//  Url.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Foundation
import Commandy

enum DotfilesRepositoryRegister: Command {
    static func run() throws {
        guard let dotfilesRepository = Arguments.cached.nonOptionArguments.first else {
            throw DotfilesRepositoryRegister.Error.notFoundDotfilesRepository
        }
        UserDefaults.standard.setValue(dotfilesRepository, forKey: "GITHUB_DOTFILES_REPOSITORY")
        exit(EXIT_SUCCESS)
    }
}

extension DotfilesRepositoryRegister {
    enum Error: Swift.Error {
        case notFoundDotfilesRepository
    }
}
