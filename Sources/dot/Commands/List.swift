//
//  List.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/04/13.
//

import Foundation
import Commandy
import RxSwift

enum List: Command {
    
    private static let disposeBag = DisposeBag()
    
    static func run() throws {
        GithubApi.resourceService.syncDotfileConfigurations()
            .flatMap { dotfileConfigurations in
                Observable.from(dotfileConfigurations)
            }
            .map { $0.name }
            .reduce([]) { names, name -> [String] in
                names + [name]
            }
            .map { $0.joined(separator: "\n") }
            .subscribe(
                onNext: { names in
                    names.echo()
                },
                onError: { _ in exit(EXIT_FAILURE) },
                onCompleted: { exit(EXIT_SUCCESS) }
            )
            .disposed(by: self.disposeBag)
    }
}
