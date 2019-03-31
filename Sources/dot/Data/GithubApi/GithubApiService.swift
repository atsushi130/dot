//
//  GithubApiService.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Moya

protocol GithubApiService {
    associatedtype Endpoint: GithubEndpoint
    var provider: MoyaProvider<Endpoint> { get }
}
