//
//  GithubDirectory.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/04/03.
//

import Foundation

enum _GithubResource {
    case file(resource: GithubResource)
    indirect case directory(resources: [_GithubResource])
}
