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
       
        // 上传带参数：https://blog.csdn.net/wj610671226/article/details/51491528
        curAction = [ProcessorMultipart(data: data, name: "file", filename: "12345.mp4", mimeType: "video/mp4")]
        /**
         for image in imageArrays {
         let data = UIImageJPEGRepresentation(image as! UIImage, 0.5)
         let imageName = String(NSDate()) + ".png"
         multipartFormData.appendBodyPart(data: data!, name: "name", fileName: imageName, mimeType: "image/png")
         }
         
         // 这里就是绑定参数的地方 param 是需要上传的参数，我这里是封装了一个方法从外面传过来的参数，你可以根据自己的需求用NSDictionary封装一个param
         for (key, value) in param {
         assert(value is String, "参数必须能够转换为NSData的类型，比如String")
         multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key )
         }
         
         */
        super.init()
    }
    
    var curAction: [ProcessorMultipart]
    
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
