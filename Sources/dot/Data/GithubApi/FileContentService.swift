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
    public final class ResourceService: GithubApiService {
        
        static let shared = ResourceService()
        private init() {}
        
        let provider = MoyaProvider<Endpoint>()
        
        // MARK: - Endpoint
        enum Endpoint: GithubEndpoint {
            case fetchGithubResource(path: String)
        }
    }
    
    public static let resourceService = ResourceService.shared
}

// MARK: - Request configuration
extension GithubApi.ResourceService.Endpoint {
    
    var path: String {
        switch self {
        case .fetchGithubResource(let path):
            guard let repository = UserDefaults.standard.string(forKey: "GITHUB_DOTFILES_REPOSITORY") else { return "" }
            if path.hasPrefix("/") {
                return "/repos/\(repository)/contents\(path)"
            } else {
                return "/repos/\(repository)/contents/\(path)"
            }
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchGithubResource:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchGithubResource:
            return .requestPlain
        }
    }
}

// MARK: - Interface
extension GithubApi.ResourceService {
    
    func fetchGithubResource(path: String) -> Observable<GithubResource> {
        return self.provider.rx.request(.fetchGithubResource(path: path))
            .asObservable()
            .flatMap { response -> Observable<GithubResource> in
                switch response.statusCode {
                case 200...226:
                    let dotConfiguration = try! response.map(GithubResource.self, using: .snakeCaseDecoder)
                    return .just(dotConfiguration)
                default:
                    return .empty()
                }
            }
    }
    
    /// sync dot.json
    /// Returns: Dotfiles
    func syncDotfileConfigurations() -> Observable<[DotfileConfiguration]> {
        return self.fetchGithubResource(path: "dot.json")
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
        return self.fetchGithubResource(path: dotfileConfiguration.input)
            .map { githubFile -> Dotfile in
                Dotfile(content: githubFile.decodedContent, outputPath: dotfileConfiguration.output)
            }
    }
}
