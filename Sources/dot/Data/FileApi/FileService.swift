//
//  FileService.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/03/31.
//

import Foundation
import RxSwift
import Scripty

extension FileApi {
    
    final class FileService: FileApiService {
        fileprivate static let shared = FileService()
        fileprivate typealias Replacing = (of: String, with: String)
        fileprivate var replacings: [Replacing] {
            return [
                Replacing(of: "\\",  with: "\\\\"),
                Replacing(of: "$",  with: "\\$"),
                Replacing(of: "\"",  with: "\\\""),
                Replacing(of: "`", with: "\\`")
            ]
            
        }
        
        private init() {}
    }
    
    static let fileService = FileService.shared
}

extension FileApi.FileService {
    
    func makeParentDirectory(for filePath: String) -> Observable<Void> {
        let script = Scripty.builder
            | "dirname \(filePath)"
            | "xargs -Idirectory mkdir -p directory"
        script.exec()
        return .just(())
    }
    
    func createFile(filePath: String, content: String) -> Observable<Void> {
        let escapedContent = self.replacings
            .reduce(content) { content, replacing in
                content.replacingOccurrences(of: replacing.of, with: replacing.with)
            }
        let script = Scripty.builder
            | "echo \"\(escapedContent)\" > \(filePath)"
        script.exec()
        return .just(())
    }
    
    func backupFile(filePath: String) -> Observable<Void> {
        let script = Scripty.builder
            | "cp -rf \(filePath) \(filePath).backup"
        script.exec()
        return .just(())
    }
}
