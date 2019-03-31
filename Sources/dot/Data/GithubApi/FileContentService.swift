//
//  FileContentService.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Foundation
import Moya
import RxMoya
import RxSwift

extension GithubApi {
    
    // MARK: - Service
    public final class FileContentService: GithubApiService {
        
        static let shared = FileContentService()
        private init() {}
        
        let provider = MoyaProvider<Endpoint>()
        
        // MARK: - Endpoint
        enum Endpoint: GithubEndpoint {
            case fetchGithubFile(path: String)
        }
    }
    
    public static let fileContentService = FileContentService.shared
}

// MARK: - Request configuration
extension GithubApi.FileContentService.Endpoint {
    
    var path: String {
        switch self {
        case .fetchGithubFile(let path):
            let repository = "atsushi130/dotfiles"
            if path.hasPrefix("/") {
                return "/repos/\(repository)/contents\(path)"
            } else {
                return "/repos/\(repository)/contents/\(path)"
            }
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchGithubFile:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchGithubFile:
            return .requestPlain
        }
    }
}

// MARK: - Interface
extension GithubApi.FileContentService {
    
    func fetchGithubFile(path: String) -> Observable<GithubFile> {
        return self.provider.rx.request(.fetchGithubFile(path: path))
            .asObservable()
            .flatMap { response -> Observable<GithubFile> in
                switch response.statusCode {
                case 200...226:
                    let dotConfiguration = try! response.map(GithubFile.self, using: .snakeCaseDecoder)
                    return .just(dotConfiguration)
                default:
                    return .empty()
                }
            }
    }
    
    /// sync dot.json
    /// Returns: Dotfiles
    func syncDotfileConfigurations() -> Observable<[DotfileConfiguration]> {
        return self.fetchGithubFile(path: "dot.json")
            .map { githubFile -> [DotfileConfiguration] in
                guard let data = githubFile.decodedContent.data(using: .utf8),
                      let dotfileConfigurations = try? JSONDecoder.snakeCaseDecoder.decode([DotfileConfiguration].self, from: data) else {
                    throw DotfileConfiguration.Error.invalidDotfileConfiguration
                }
                return dotfileConfigurations
            }
    }
    
    // fetch dotfile
    // Parameters:
    //      - dotfileConfiguration: resource info
    // Returns: fetched Dotfile
    func fetchDotfile(dotfileConfiguration: DotfileConfiguration) -> Observable<Dotfile> {
        return self.fetchGithubFile(path: dotfileConfiguration.input)
            .map { githubFile -> Dotfile in
                Dotfile(content: githubFile.decodedContent, outputPath: dotfileConfiguration.output)
            }
    }
}
