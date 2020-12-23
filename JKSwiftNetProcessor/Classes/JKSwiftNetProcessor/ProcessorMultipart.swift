//
//  ProcessorMultipart.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import Foundation
import Alamofire

public struct ProcessorMultipart {
    public let data: Data
    public let name: String
    public let filename: String?
    public let mimeType: String?
    
    public init(data: Data, name: String, filename: String? = nil, mimeType: String? = nil) {
        self.data = data
        self.name = name
        self.filename = filename
        self.mimeType = mimeType
    }
}

fileprivate extension MultipartFormData {
     func append(processorMultipart part: ProcessorMultipart) {
        if let fn = part.filename, let mt = part.mimeType {
            append(part.data, withName: part.name, fileName: fn, mimeType: mt)
            return
        }
        if let mt = part.mimeType {
            append(part.data, withName: part.name, mimeType: mt)
            return
        }
        append(part.data, withName: part.name)
    }
}

extension Array where Element == ProcessorMultipart {
    
    func processorEncode() throws -> (Data, String) {
        let fmt = MultipartFormData()
        forEach { (item) in
            fmt.append(processorMultipart: item)
        }
        do {
            let data = try fmt.encode()
            return (data, fmt.contentType)
        } catch let err {
            throw err
        }
    }
}

extension Processor {
    
    /// 上传参数的拼接
    /// - Parameter formdatas: 参数
    /// - Returns: 返回拼接后的参数
    func addUploadParam(formdatas: [ProcessorMultipart]) -> [ProcessorMultipart] {
        var fmd = formdatas
        guard let para = parameters as? [String: String] else {
            return fmd
        }
        para.forEach { (key, value) in
            if let data = value.data(using: .utf8, allowLossyConversion: false) {
                /*
                 - 参数01 上传的二进制文件
                 - 参数02 服务器指定的名字 pic mp4 mp3 区分客户端上传的是什么文件描述
                 - 参数03 文件路径名字 一般可以随意些 及时你写了 服务器也不用
                 - 参数04 告知服务器我们上传的文件的类型 一般可以传入application/octet-stream
                 */
                fmd.append(ProcessorMultipart(data: data, name: key, filename:nil, mimeType: nil))
            }
        }
        return fmd
    }
}

