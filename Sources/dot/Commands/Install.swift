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
        let resourceName = Arguments.cached.nonOptionArguments.first
        let matchOptions = Install.matchOptions
        switch matchOptions {
        case _ where matchOptions[.chain]:
            guard let resourceName = resourceName else { throw Install.Error.notFoundFilename }
            self.install(resourceName: resourceName, chain: true)
                .subscribe(
                    onError: { _ in exit(EXIT_FAILURE) },
                    onCompleted: { exit(EXIT_SUCCESS) }
                )
                .disposed(by: self.disposeBag)
        default:
            guard let resourceName = resourceName else { throw Install.Error.notFoundFilename }
            self.install(resourceName: resourceName)
                .subscribe(
                    onError: { _ in exit(EXIT_FAILURE) },
                    onCompleted: { exit(EXIT_SUCCESS) }
                )
                .disposed(by: self.disposeBag)
          }
    }
    
    private static func install(resourceName: String, chain: Bool = false) -> Observable<Dotfile> {
        
        let fetchedDotfileConfigurations = GithubApi.resourceService.syncDotfileConfigurations()
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
            .filter { dotfileConfiguration, matchedDotfileConfiguration in
                 matchedDotfileConfiguration.chain?.contains(dotfileConfiguration.name) ?? false
            }
            .map { $0.0 }
            
        let matchedDotfiles = Observable
            .concat(
                matchedDotfileConfiguration,
                chainDotfileConfigurations
            )
            .flatMap { dotfileConfiguration -> Observable<Dotfile> in
                switch dotfileConfiguration.type {
                case .file:
                    return GithubApi.resourceService.fetchDotfile(dotfileConfiguration: dotfileConfiguration)
                case .dir:
                    return .empty()
                }
            }

        return matchedDotfiles
            .flatMap { dotfile in
                Observable.concat(
                    FileApi.fileService.backupFile(filePath: dotfile.outputPath),
                    FileApi.fileService.createFile(filePath: dotfile.outputPath, content: dotfile.content)
                )
            }
            .flatMap { _ -> Observable<Dotfile> in
                matchedDotfiles
            }
    }
    
    static func fetchDirectory(directoryPath: String = "vim/dein") -> Observable<_GithubResource> {
        return GithubApi.resourceService.fetchGithubResource(path: directoryPath)
            .flatMap { (resources: [GithubResource]) -> Observable<GithubResource> in
                return .from(resources)
            }
            .flatMap { resource -> Observable<_GithubResource> in
                switch resource.type {
                case .file:
                    return GithubApi.resourceService.fetchGithubResource(path: resource.path)
                        .map { file -> _GithubResource in
                            .file(resource: file)
                        }
                case .dir:
                    return self.fetchDirectory(directoryPath: resource.path)
                }
            }
            .reduce([_GithubResource]()) { resources, resource in
                resources + [resource]
            }
            .map { resources -> _GithubResource in
                .directory(resources: resources)
            }
    }
}

extension Install {
    enum Error: Swift.Error {
        case notFoundFilename
    }
}
