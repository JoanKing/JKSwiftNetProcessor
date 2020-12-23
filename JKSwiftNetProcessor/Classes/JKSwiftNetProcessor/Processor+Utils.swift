//
//  Processor+Utils.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import Foundation

extension URL {
    public func append(path: String) -> URL {
        // 检查字符串是否拥有特定后缀。
        // hasSuffix(suffix: String)
        let urlHasDiv = absoluteString.hasSuffix("/")
        // 检查字符串是否拥有特定前缀
        // hasPrefix(prefix: String)
        let pathHasDiv = path.hasPrefix("/")
        // 基础路径和路径都 包含 /
        if urlHasDiv, pathHasDiv {
            var str = path
            // 移除路径的前缀 /
            str.removeFirst()
            return appendingPathComponent(str)
        }
        // 基础路径和路径都 不 包含 /
        if !urlHasDiv, !pathHasDiv {
            return appendingPathComponent(("/" + path))
        }
        // 基础路径和路径有一个包含 /，直接拼接即可
        return appendingPathComponent(path)
    }
}

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

