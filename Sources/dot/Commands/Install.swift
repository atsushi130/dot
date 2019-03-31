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
    
    case all
    case withRefresh
    
    var shortOption: String? {
        switch self {
        case .all: return "a"
        case .withRefresh: return "w"
        }
    }
    
    private static let disposeBag = DisposeBag()
    
    static func run() throws {
        // let filename = Arguments.cached.nonOptionArguments.first
        let filename = "vimrc"
        let matchOptions = Install.matchOptions
        switch matchOptions {
        case _ where matchOptions[.all]:
            break
        case _ where matchOptions[.withRefresh]:
            break
        case _ where matchOptions[.all, .withRefresh]:
            break
        default:
            // guard let filename = filename else { throw Install.Error.notFoundFilename }
            self.install(filename: filename)
                .subscribe(
                    onNext: { exit(EXIT_SUCCESS) },
                    onError: { _ in exit(EXIT_FAILURE) }
                )
                .disposed(by: self.disposeBag)
          }
        // 1. sync dot configuration
        // 2. fetch install file
        // 3. backup local file
        // 4. output fetched file to local
        // 5. source file
    }
    
    private static func install(filename: String) -> Observable<Void> {
        
        let fetchedDotfile = GithubApi.fileContentService.syncDotfileConfigurations()
            .flatMap { dotfileConfigurations in
                Observable.from(dotfileConfigurations)
            }
            .filter { dotConfiguration in
                dotConfiguration.name == filename
            }
            .flatMap(GithubApi.fileContentService.fetchDotfile(dotfileConfiguration:))
        
        return fetchedDotfile
            .flatMap { dotfile in
                FileApi.fileService.backupFile(filePath: dotfile.outputPath)
            }
            .withLatestFrom(fetchedDotfile)
            .flatMap { dotfile in
                FileApi.fileService.createFile(filePath: dotfile.outputPath, content: dotfile.content)
            }
    }
}

extension Install {
    enum Error: Swift.Error {
        case notFoundFilename
    }
}
