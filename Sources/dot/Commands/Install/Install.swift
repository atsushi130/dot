//
//  Install.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Foundation
import RxSwift
import Commandy

enum Install: String, Command {
    
    case chain

    var shortOption: String? {
        switch self {
        case .chain: return "c"
        }
    }
    
    private static let disposeBag = DisposeBag()
    
    static func run() throws {
        
        Observable.just(Arguments.cached.nonOptionArguments.first)
            .do(onNext: { _ in
                try self.validate()
            })
            .map { firstArgument -> String in
                guard let resourceName = firstArgument else { throw Install.Error.filenameNotFound }
                return resourceName
            }
            .flatMap { resourceName -> Observable<Void> in
                self.install(resourceName: resourceName, chain: Install.matchOptions[.chain])
                    .catchError { error in
                        if let resourceError = error as? GithubApi.ResourceService.Error {
                            let installError = Install.Error.referenceResourceError(resourceError: resourceError)
                            return .error(installError)
                        } else {
                            return .error(error)
                        }
                    }
            }
            .subscribe(
                onError: { error in
                    if let installError = error as? Install.Error {
                        print(installError.message)
                    } else {
                        print(error)
                    }
                    exit(EXIT_FAILURE)
                },
                onCompleted: {
                    exit(EXIT_SUCCESS)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    private static func onError(error: Error) {
        exit(EXIT_FAILURE)
    }
    
    private static func validate() throws {
        guard let _ = UserDefaults.standard.string(forKey: "GITHUB_ACCESS_TOKEN") else {
            throw Install.Error.githubAccessTokenNotFound
        }
        guard let _ = UserDefaults.standard.string(forKey: "GITHUB_DOTFILES_REPOSITORY") else {
            throw Install.Error.githubDotfilesRepositoryNotFound
        }
    }
    
    private static func install(resourceName: String, chain: Bool = false) -> Observable<Void> {
        
        let fetchedDotfileConfigurations = GithubApi.resourceService.syncDotfileConfigurations()
            .do(onNext: { dotfileConfigurations in
                let dotfileConfigurationExists = dotfileConfigurations
                    .map { $0.name }
                    .contains(resourceName)
                if !dotfileConfigurationExists {
                    throw Install.Error.undefinedInDotJson(resourceName: resourceName)
                }
            })
            .flatMap { dotfileConfigurations in
                Observable.from(dotfileConfigurations)
            }
            
        let matchedDotfileConfiguration = fetchedDotfileConfigurations
            .filter { dotConfiguration in
                dotConfiguration.name == resourceName
            }
            
        let chainDotfileConfigurations = fetchedDotfileConfigurations
            .withLatestFrom(matchedDotfileConfiguration) { ($0, $1) }
            .flatMap { dotfileConfigurations -> Observable<(DotfileConfiguration, DotfileConfiguration)> in
                chain ? .just(dotfileConfigurations) : .empty()
            }
            .do(onNext: { dotfileConfiguration, matchedDotfileConfiguration in
                guard let _ = matchedDotfileConfiguration.chain else { throw Install.Error.undefinedChainInDotJson(resourceName: resourceName) }
            })
            .filter { dotfileConfiguration, matchedDotfileConfiguration in
                matchedDotfileConfiguration.chain!.contains(dotfileConfiguration.name)
            }
            .map { $0.0 }
            
        let matchedResources = Observable
            .concat(
                matchedDotfileConfiguration,
                chainDotfileConfigurations
            )
            .flatMap { dotfileConfiguration -> Observable<Resource> in
                switch dotfileConfiguration.type {
                case .file:
                    return GithubApi.resourceService.fetchGithubResource(path: dotfileConfiguration.input)
                        .map { (resource: GithubResource) -> Resource in
                            .file(resource: resource, outputPath: dotfileConfiguration.output)
                        }
                case .dir:
                    let resourcePath = dotfileConfiguration.input
                    return self.fetchDirectory(input: resourcePath, resourcePath: resourcePath, output: dotfileConfiguration.output)
                }
            }

        return matchedResources
            .flatMap { resource -> Observable<Void> in
                self.outputGithubResource(resource: resource)
            }
    }
    
    static func outputGithubResource(resource: Resource) -> Observable<Void> {
        switch resource {
        case let .file(resource, outputPath):
            return Observable
                .concat(
                    FileApi.fileService.makeParentDirectory(for: outputPath),
                    FileApi.fileService.backupFile(filePath: outputPath),
                    FileApi.fileService.createFile(filePath: outputPath, content: resource.decodedContent)
                )
        case let .directory(resources, _):
            let outputResources = resources
                .map { resource -> Observable<Void> in
                    self.outputGithubResource(resource: resource)
                }
            return Observable
                .from(outputResources)
                .flatMap { $0 }
        }
    }
        
    
    static func fetchDirectory(input directoryPath: String, resourcePath: String, output entryPath: String) -> Observable<Resource> {
        return GithubApi.resourceService.fetchGithubResource(path: resourcePath)
            .flatMap { (resources: [GithubResource]) -> Observable<GithubResource> in
                return .from(resources)
            }
            .flatMap { resource -> Observable<Resource> in
                switch resource.type {
                case .file:
                    return GithubApi.resourceService.fetchGithubResource(path: resource.path)
                        .map { (file: GithubResource) -> Resource in
                            let filePath = directoryPath.hasPrefix("/") ? "/" + file.path : file.path
                            let path = filePath.replacingOccurrences(of: "^" + directoryPath, with: "", options: .regularExpression)
                            return .file(resource: file, outputPath: entryPath + path)
                        }
                case .dir:
                    return self.fetchDirectory(input: directoryPath, resourcePath: resource.path, output: entryPath)
                }
            }
            .reduce([Resource]()) { resources, resource in
                resources + [resource]
            }
            .map { resources -> Resource in
                let path = resourcePath.replacingOccurrences(of: "^" + directoryPath, with: "", options: .regularExpression)
                return .directory(resources: resources, outputPath: entryPath + path)
            }
    }
}

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
