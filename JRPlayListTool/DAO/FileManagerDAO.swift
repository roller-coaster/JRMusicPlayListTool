//
//  FileManagerDAO.swift
//  JRPlayListTool
//
//  Created by ikaros on 2022/4/16.
//

import Foundation

fileprivate let FM = FileManager.default

extension FileManager {
    @discardableResult
    class func createFile(_ path: String) -> Bool {
        guard !path.isEmpty else {
            return false
        }
        guard FM.fileExists(atPath: path) == false else {
            return true
        }
        return FM.createFile(atPath: path, contents: nil, attributes: nil)
    }
    /// 文件夹是否存在
    /// - Parameter atPath: 文件夹路径
    /// - Returns: bool
    @discardableResult
    class func directoryExists(_ path: String) -> Bool {
        guard path.isEmpty else {
            var directoryExists = ObjCBool.init(false)
            let exist = FileManager.default.fileExists(atPath: path, isDirectory: &directoryExists)
            return exist && directoryExists.boolValue
        }
        return false
    }

    /// 获取指定目录下所有文件
    /// - Parameter path: 指定目录
    /// - Returns: [String]
    @discardableResult
    class func subpathsOfDirectory(_ path: String) -> [String] {
        var filePaths = [String]()
        guard directoryExists(path) else {
            return filePaths
        }
        do {
            let array = try FM.subpathsOfDirectory(atPath: path)
            filePaths.append(contentsOf: array.map({ "\(path)/\($0)" }))
            return filePaths.filter { (path) -> Bool in
                var rs = false
                do {
                    let fileInfo = try FM.attributesOfItem(atPath: path)
                    guard let extensionHidden = fileInfo[.extensionHidden] as? Bool else { return true }
                    guard let type = fileInfo[.type] as? FileAttributeKey else { return true }
                    if type == FileAttributeKey.init(rawValue: "NSFileTypeRegular") {
                        return !extensionHidden
                    } else {
                        return false
                    }
                } catch {
                    rs = false
                }
                return rs
            }
        } catch {
            return filePaths
        }
    }
    
}
