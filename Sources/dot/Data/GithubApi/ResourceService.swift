//
//  ResourceService.swift
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
        fileprivate var cachedDotilfeConfigurations: [DotfileConfiguration]? = nil
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
    
    func fetchGithubResource<T>(path: String) -> Observable<T> where T: Decodable {
        return self.provider.rx.request(.fetchGithubResource(path: path))
            .asObservable()
            .flatMap { response -> Observable<T> in
                switch response.statusCode {
                case 200...226:
                    guard let dotConfiguration = try? response.map(T.self, using: .snakeCaseDecoder) else {
                        throw GithubApi.ResourceService.Error.resourceNotFound(path: path)
                    }
                    return .just(dotConfiguration)
                case 401:
                    throw GithubApi.ResourceService.Error.invalidGithubAccessToken
                case 404:
                    throw GithubApi.ResourceService.Error.resourceNotFound(path: path)
                default:
                    return .empty()
                }
            }
    }
    
    /// sync dot.json
    // Parameters:
    //      - cache: use cache
    /// Returns: Dotfiles
    func syncDotfileConfigurations(cache: Bool = true) -> Observable<[DotfileConfiguration]> {
        
        if cache, let cached = self.cachedDotilfeConfigurations {
            return Observable.just(cached)
        }
        
        return self.fetchGithubResource(path: "dot.json")
            .map { (githubResource: GithubResource) -> [DotfileConfiguration] in
                guard let data = githubResource.decodedContent.data(using: .utf8),
                      let dotfileConfigurations = try? JSONDecoder.snakeCaseDecoder.decode([DotfileConfiguration].self, from: data) else {
                    throw DotfileConfiguration.Error.invalidDotfileConfiguration
                }
                return dotfileConfigurations
            }
            .do(onNext: { [weak self] dotfileConfigurations in
                self?.cachedDotilfeConfigurations = dotfileConfigurations
            })
    }
    
    // fetch dotfile
    // Parameters:
    //      - dotfileConfiguration: resource info
    // Returns: fetched Dotfile
    func fetchDotfile(dotfileConfiguration: DotfileConfiguration) -> Observable<Dotfile> {
        return self.fetchGithubResource(path: dotfileConfiguration.input)
            .map { (githubResource: GithubResource) -> Dotfile in
                Dotfile(content: githubResource.decodedContent, outputPath: dotfileConfiguration.output)
            }
    }
}

extension GithubApi.ResourceService {
    enum Error: Swift.Error {
        case invalidGithubAccessToken
        case resourceNotFound(path: String)
        
        var message: String {
            switch self {
            case .invalidGithubAccessToken:
                return "Invalid Github access token."
            case .resourceNotFound(let path):
                return "\(path) not found..."
            }
        }
    }
}
