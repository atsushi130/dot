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
    
    private static func install(resourceName: String, chain: Bool = false) -> Observable<Void> {
        
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
            
        let matchedResources = Observable
            .concat(
                matchedDotfileConfiguration,
                chainDotfileConfigurations
            )
            .flatMap { dotfileConfiguration -> Observable<_GithubResource> in
                switch dotfileConfiguration.type {
                case .file:
                    return GithubApi.resourceService.fetchGithubResource(path: dotfileConfiguration.input)
                        .map { (resource: GithubResource) -> _GithubResource in
                            .file(resource: resource, outputPath: dotfileConfiguration.output)
                        }
                case .dir:
                    return self.fetchDirectory(input: dotfileConfiguration.input, resourcePath: dotfileConfiguration.input, output: dotfileConfiguration.output)
                }
            }

        return matchedResources
            .flatMap { resource -> Observable<Void> in
                self.outputGithubResource(resource: resource)
            }
    }
    
    static func outputGithubResource(resource: _GithubResource) -> Observable<Void> {
        switch resource {
        case let .file(resource, outputPath):
            return Observable
                .concat(
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
        
    
    static func fetchDirectory(input directoryPath: String, resourcePath: String, output entryPath: String) -> Observable<_GithubResource> {
        return GithubApi.resourceService.fetchGithubResource(path: resourcePath)
            .flatMap { (resources: [GithubResource]) -> Observable<GithubResource> in
                return .from(resources)
            }
            .flatMap { resource -> Observable<_GithubResource> in
                switch resource.type {
                case .file:
                    return GithubApi.resourceService.fetchGithubResource(path: resource.path)
                        .map { (file: GithubResource) -> _GithubResource in
                            let path = file.path.replacingOccurrences(of: "^" + directoryPath, with: "", options: .regularExpression)
                            return .file(resource: file, outputPath: entryPath + path)
                        }
                case .dir:
                    return self.fetchDirectory(input: directoryPath, resourcePath: resource.path, output: entryPath)
                }
            }
            .reduce([_GithubResource]()) { resources, resource in
                resources + [resource]
            }
            .map { resources -> _GithubResource in
                let path = resourcePath.replacingOccurrences(of: "^" + directoryPath, with: "", options: .regularExpression)
                return .directory(resources: resources, outputPath: entryPath + path)
            }
    }
}

extension Install {
    enum Error: Swift.Error {
        case notFoundFilename
    }
}
