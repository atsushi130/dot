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
        let filename = Arguments.cached.nonOptionArguments.first
        let matchOptions = Install.matchOptions
        switch matchOptions {
        case _ where matchOptions[.chain]:
            guard let filename = filename else { throw Install.Error.notFoundFilename }
            self.install(filename: filename, chain: true)
                .subscribe(
                    onError: { _ in exit(EXIT_FAILURE) },
                    onCompleted: { exit(EXIT_SUCCESS) }
                )
                .disposed(by: self.disposeBag)
        default:
            guard let filename = filename else { throw Install.Error.notFoundFilename }
            self.install(filename: filename)
                .subscribe(
                    onError: { _ in exit(EXIT_FAILURE) },
                    onCompleted: { exit(EXIT_SUCCESS) }
                )
                .disposed(by: self.disposeBag)
          }
    }
    
    private static func install(filename: String, chain: Bool = false) -> Observable<Dotfile> {
        
        let fetchedDotfileConfigurations = GithubApi.fileContentService.syncDotfileConfigurations()
            .flatMap { dotfileConfigurations in
                Observable.from(dotfileConfigurations)
            }
            
        let matchedDotfileConfiguration = fetchedDotfileConfigurations
            .filter { dotConfiguration in
                dotConfiguration.name == filename
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
            .flatMap(GithubApi.fileContentService.fetchDotfile(dotfileConfiguration:))
        
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
}

extension Install {
    enum Error: Swift.Error {
        case notFoundFilename
    }
}
