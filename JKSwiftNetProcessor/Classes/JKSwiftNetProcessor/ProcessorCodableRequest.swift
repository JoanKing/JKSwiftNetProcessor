//
//  ProcessorCodableRequest.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import Alamofire
import CryptoSwift
import Foundation

// MARK: 渠道 ID
public var fbchannelId: String = ""
// MARK: 基础的 URL
public var fbBaseURLStr: String = ""
// MARK: 加密的key
public var fbSecretKey: String = ""

public class JKNetConfig: NSObject {
    @objc public static func config(chanId: String, baseUrl: String, secrKey: String) {
        
        // 设置日志
        ServerLog.redirectConsoleLogToDocumentFolder()
       
        fbchannelId = chanId
        fbBaseURLStr = baseUrl
        fbSecretKey = secrKey
    }
}

open class ResponseNet: ResponseDecoder {

    // MARK: 服务器请求结果解析
    /// 服务器请求结果解析
    /// - Parameter json: json 数据
    /// - Returns: 解码后的数据
    public func decode(json: Any) -> ResponseDecoder.ResponseDecodeTuple {
        guard let json = json as? [String: Any] else {
            return (false, nil, nil)
        }
        var success = false
        var msg: String? = nil
        var errorCode: String? = nil
        
        if let result = json["resultCode"] as? String, result == "1" {
            success = true
        }
        if let message = json["msg"] as? String {
            msg = message
        }
        if let err = json["errorCode"] as? String {
            errorCode = err
        }
        return (success, msg, errorCode)
    }
}

open class JKCodable<Type: Codable>: ProcessorDecoding {
    
    public var parameterEncoding: ProcessorParameterEncoding = .URL
    
    public var completionStorage = ProcessorCompletionStorage<Type>()

    open var modelKeysPath: String? {
        return "data"
    }
    /// 数据类型
    public typealias DataType = Type
    /// 页码
    open var pageIndex: Int?
    /// 每页的数量
    open var pageSize: Int?
    
    public init() {}
    
    /// 用这个字典设置参数
    public var param = [String: Any]()
    /// 基础的 URL
    open var baseURL: URL {
        return URL(string: fbBaseURLStr)!
    }
    /// 默认 .post 请求
    open var method: HTTPMethod {
        return .post
    }
    /// 请求路径
    open var path: String {
        return ""
    }
    
    // override token
    var token: String {
        return ""
    }
    
    var userId: String {
        return ""
    }
    
    open var request: ProcessorRequest?
    
    open var action: ProcessorAction {
        return .request
    }
    
    open var parameters: [String: Any]? {
        var parameter = param
        parameter["userId"] = userId
        // let signedParam = _sign(parameters: parameter)
        return parameter
    }
    
    open var headers: [String: String]? {
        var header = [String: String]()
        header["nxs-u"] = userId
        header["nxs-t"] = token
 
        // if let parameters = self.parameters as? [String: String] {
        //   let signedParam = _sign(parameters: parameters)
        //   header["nxs-sign"] = signedParam
        // }
        
        let logContent = "🚀 开始请求：接口：" + "基础URL：\(self.baseURL)" + "接口名：\(self.path)" + "参数：" + "\(self.parameters ?? ["": ""])" + " ==start=="
        ServerLog.log(content: logContent)

        return header
    }
    
    open var responseDecoder: ResponseDecoder {
        return ResponseNet()
    }
    
    public func responseWillCall<T>(response: Response<T>) {
        #if DEBUG
        // let logContent = "🚀 请求开始 接口：" + self.path + "参数：" + "\(self.parameters ?? ["": ""])" + "==resp==" + "\(response.json ?? ["": ""])"
        // ServerLog.log(content: logContent)
        #endif
    }
    
    open var isNeedCache: Bool {
        return false
    }
    
    open var cacheName: String {
        return ""
    }
    
    open var cachefilePath: String {
        get {
            let path: String = self.path.replacingOccurrences(of: "/", with: "_")
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            let versionStr = version.replacingOccurrences(of: ".", with: "_")
            var fileName = cacheName + "_" + path + versionStr
            if cacheName.count <= 0 {
                fileName = path + versionStr
            }
            let filePath = ProcessorCachsFileUtil.getPath(fileName, fileType: "plist")
            return filePath
        }
    }
    
    open func readcache() -> DataType? {
        let path = self.cachefilePath
        let data = ProcessorCachsFileUtil.readFile(path)
        
        guard let jsonDic = data?["data"] else {
            return nil
        }
      
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonDic)
        } catch _ {
            return nil
        }
        
        let ret: DataType
        do {
            ret = try JSONDecoder().decode(DataType.self, from: jsonData)
        } catch _ {
            return nil
        }
        return ret
    }
    
    public func responseDidCall<T>(response: Response<T>) {
  
        var logContent = "🚀 请求成功：接口：" + self.path + "参数：" + "\(self.parameters ?? ["": ""])" + "==resp==" + "\(response.json ?? ["": ""])" + "==end=="
        if response.isSuccess, response.model != nil {
        logContent = logContent + "==Model=="
        } else {
        logContent = logContent + "==Error" + (response.errorCode ?? "")
        }
        ServerLog.log(content: logContent)
        
        if let json = response.json, let error = json["errorCode"] as? String, error == "-1" {
           
        }
        
        if isNeedCache == true, response.isSuccess, response.model != nil {
            if ProcessorCachsFileUtil.writeFile(cachefilePath, jsonDic: response.json as NSDictionary?) {
                // print("writeFile success%@", cachefilePath)
            }
        }
    }
}

// MARK:- 参数加密
public extension JKCodable {
    // 参数加密
    private func _sign(parameters: [String: String]) -> String {
        var para = parameters
        para["secret"] = fbSecretKey
        var queryArray: [String] = []
        
        for key in para.keys.sorted() {
            let value = para[key]
            if let field = value {
                let str = key + "=" + field
                queryArray.append(str)
            }
        }
        queryArray.append("nxs-u=" + "100001") // userId
        let sign = queryArray.joined(separator: "&")
        return sign.sha1()
    }
}

open class JKCodableRequest<Type: Codable>: JKCodable<Type> {}
