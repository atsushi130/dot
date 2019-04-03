//
//  GithubDirectory.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/04/03.
//

import Foundation

indirect enum _GithubResource {
    case file(resource: GithubResource, outputPath: String)
    case directory(resources: [_GithubResource], outputPath: String)
}
