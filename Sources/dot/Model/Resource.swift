//
//  GithubDirectory.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/04/03.
//

import Foundation

indirect enum Resource {
    case file(resource: Resourceable, outputPath: String)
    case directory(resources: [Resource], outputPath: String)
}

protocol Resourceable {
    var name: String { get }
    var content: String? { get }
    var type: ResourceType { get }
    var path: String { get }
    var decodedContent: String { get }
}

enum ResourceType: String, Decodable {
    case file
    case dir
}
