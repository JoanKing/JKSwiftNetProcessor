//
//  VodeoUploadRequest.swift
//  JKSwiftNetProcessor_Example
//
//  Created by IronMan on 2021/1/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

// 上传成功后返回的model
class VodeoUploadModel: Codable {
    
}

// MARK: 上传的 request
class VodeoUploadRequest: JKCodable<VodeoUploadModel> {
    
    init(data: Data) {
        curAction = [ProcessorMultipart(data: data, name: "file", filename: "12345.mp4", mimeType: "video/mp4")]
        super.init()
    }
    
    var curAction:[ProcessorMultipart]
    
    override var action: ProcessorAction {
        get {
            return .upload(curAction)
        }
    }
    
    override var baseURL: URL {
        return URL(string: "基础的url")!
    }
    
    override var path: String {
        return "上传的接口地址"
    }
}
