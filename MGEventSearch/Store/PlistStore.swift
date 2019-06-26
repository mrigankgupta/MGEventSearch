//
//  PlistStore.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 10/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import Foundation

protocol Persisting {
    func save<T: Encodable>(data: T, at path: String) -> Bool
    func fetch<T: Decodable>(at file: String) -> T?
}

struct PlistStore {

    func getDocumentPath(with name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentPath = paths[0] as String
        let path = documentPath.appending("/\(name)")
        return path
    }

    func encode<T: Encodable>(data: T, at path: URL) -> Bool {
        let encode = PropertyListEncoder()
        encode.outputFormat = .xml
        do {
            let data = try encode.encode(data)
            print(data.debugDescription)
            try data.write(to: path)
        } catch {
            return false
        }
        return true
    }

    func decode<T: Decodable>(at path: URL) -> T? {
        let decode = PropertyListDecoder()
        guard let data = try? Data.init(contentsOf: path) else { return nil }
        return try? decode.decode(T.self, from: data)
    }
}

extension PlistStore: Persisting {

    @discardableResult func save<T: Encodable>(data: T, at file: String) -> Bool {
        let docPath = getDocumentPath(with: file)
        guard FileManager.default.isWritableFile(atPath: docPath) ||
            FileManager.default.createFile(atPath: docPath, contents: nil, attributes: nil) else { return false }
        let url = URL(fileURLWithPath: docPath)
        return encode(data: data, at: url)
    }

    func fetch<T: Decodable>(at file: String) -> T? {
        let docPath = getDocumentPath(with: file)
        guard FileManager.default.fileExists(atPath: docPath) else { return nil }
        let url = URL(fileURLWithPath: docPath)
        return decode(at: url)
    }
}
