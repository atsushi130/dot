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
        private init() {}
    }
    
    static let fileService = FileService.shared
}

extension FileApi.FileService {
    
    func createFile(filePath: String, content: String) -> Observable<Void> {
        let escapedContent = content.replacingOccurrences(of: "\"", with: "\\\"")
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
