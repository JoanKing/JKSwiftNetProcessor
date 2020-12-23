//
//  Response.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import Alamofire
import Foundation

public enum ProcessorResult<Value> {
    /// 请求成功(result == success)，转model成功，或者data的json数据为空
    case success(Value?)
    /// 请求失败 result != success，或者转model失败
    /// error, msg, errorCode
    case failure(error: Error?, msg: String?, errorCode: String?)
    /// 请求被cancel
    case cancel
}

// MARK: 通过json解析首层协议
public protocol ResponseDecoder {
    typealias ResponseDecodeTuple = (isSuccess: Bool, msg: String?, errorCode: String?)
    // 此方法主要是给老的response用
    func decode(json: Any) -> ResponseDecodeTuple
}

public class Response<T> {
    public let json: [String: Any]?
    public var parameters: [String: Any]?
    public var header: [String: Any]?
    public var url: URL?

    public var result: ProcessorResult<T> = ProcessorResult.failure(error: nil, msg: "网络加载失败，请稍后再试", errorCode: nil)

    init(responseValue: Any?, parameters: [String: Any]?, header: [String: Any]?, url: URL?) {
        json = responseValue as? [String: Any]
        self.parameters = parameters
        self.header = header
        self.url = url
    }

    public var model: T? {
        guard case let .success(value) = result else {
            return nil
        }
        return value
    }

    // 暂时先放在这，便于让ResponseBaseModel override，后面可以提出来
    public var isSuccess: Bool {
        guard case .success = result else {
            return false
        }
        return true
    }

    public var msg: String? {
        guard case let .failure(error: _, msg: msg, errorCode: _) = result else {
            return nil
        }
        return msg
    }

    public var errorCode: String? {
        guard case let .failure(error: _, msg: _, errorCode: errorCode) = result else {
            return nil
        }
        return errorCode
    }
    
    public var isCancel: Bool {
        guard case .cancel = result else {
            return false
        }
        return true
    }

    // 转model前的通用处理
    fileprivate func jsonResult(dataResponse: DataResponse<Any>, responseDecoder: ResponseDecoder) -> (ProcessorResult<T>?, Any?) {
        if dataResponse.error?.code == -999 {
            return (ProcessorResult.cancel, nil)
        }
        if let error = dataResponse.error {
            return (ProcessorResult.failure(error: ProcessorError.AFError(error: error), msg: nil, errorCode: nil), nil)
        }
        guard let json = dataResponse.value as? [String: Any] else {
            return (ProcessorResult<T>.failure(error: ProcessorError.jsonInvalid(reason: .jsonNil), msg: nil, errorCode: nil), nil)
        }
        let decodeTuple = responseDecoder.decode(json: json)
        // 业务请求失败
        guard decodeTuple.isSuccess else {
            let result = ProcessorResult<T>.failure(error: ProcessorError.businessFailed(msg: decodeTuple.msg, errorCode: decodeTuple.errorCode), msg: decodeTuple.msg, errorCode: decodeTuple.errorCode)
            return (result, nil)
        }
        return (nil, json)
    }
}

extension Response where T == Any {
    func decode(dataResponse: DataResponse<Any>, responseDecoder: ResponseDecoder, modelKeysPath: String?) {
        let resultTuple = jsonResult(dataResponse: dataResponse, responseDecoder: responseDecoder)
        if let result = resultTuple.0 {
            self.result = result
            return
        }
        let json = resultTuple.1
        var nestedJson: Any? = json as Any
        // Model key path
        if let kp = modelKeysPath, !kp.isEmpty {
            nestedJson = (json as AnyObject).value(forKeyPath: kp)
        }
        result = ProcessorResult.success(nestedJson)
    }
}

extension Response where T: Codable {
    func decode(dataResponse: DataResponse<Any>, responseDecoder: ResponseDecoder, modelKeysPath: String?) {
        let resultTuple = jsonResult(dataResponse: dataResponse, responseDecoder: responseDecoder)
        if let result = resultTuple.0 {
            self.result = result
            return
        }
        let json = resultTuple.1
        var nestedJson: Any? = json as Any
        // Model key path
        if let kp = modelKeysPath, !kp.isEmpty {
            nestedJson = (json as AnyObject).value(forKeyPath: kp)
        }
        if let nj = nestedJson as? T {
            result = ProcessorResult.success(nj)
            return
        }
        guard let decodeJson = nestedJson else {
            result = ProcessorResult.success(nil)
            return
        }
        // model 解析
        let dic = decodeJson as? [String: Any]
        let arr = decodeJson as? [Any]
        guard (dic != nil || arr != nil) else {
            // assert(false, "the json is invalide, please check! json: \(json)")
            result = ProcessorResult.success(nil)
            return
        }
        
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: decodeJson)
        } catch let err {
            #if DEBUG
            print(err)
            #endif
            assert(false, "can't serialization json to data! json: \(decodeJson), error: \(err)")
            result = ProcessorResult.success(nil)
            return
            // return ProcessorResult.failure(error: ProcessorError.jsonSerializationFailed(error: err), msg: nil, errorCode: nil)
        }
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            result = ProcessorResult.success(object)
            return
        } catch let err {
            #if DEBUG
            print(err)
            #endif
            assert(false, "can't JSONDecoder the json to object! json: \(decodeJson), error: \(err)")
            // return ProcessorResult.failure(error: ProcessorError.modelEncodingFailed(error: err), msg: nil, errorCode: nil)
        }
        result = ProcessorResult.success(nil)
    }
}

/// 请不要使用此对象的Result属性
public class ResponseBaseModel<Type: BaseModel>: Response<Type> {
    private var md: Type?
    public override var model: Type? {
        return md
    }
    public var models: [Type]?
    private var success: Bool = false
    private var message: String?
    private var errCode: String?
    public override var msg: String? {
        return message
    }
    public override var isSuccess: Bool {
        return success
    }
    public override var errorCode: String? {
        return errCode
    }
    init(responseValue: Any?, parameters: [String: Any]?, header: [String: Any]?, url: URL?, decoder: ResponseDecoder, keyPath: String?) {
        super.init(responseValue: responseValue, parameters: parameters, header: header, url: url)
        if let json = self.json {
            let decodeTuple = decoder.decode(json: json)
            success = decodeTuple.isSuccess
            message = decodeTuple.msg
            errCode = decodeTuple.errorCode
        }
        guard success else {
            return
        }
        var nestedJson: Any? = json as Any
        if let keyPath = keyPath, !keyPath.isEmpty {
            nestedJson = (json as AnyObject).value(forKeyPath: keyPath)
        }
        if let dic = nestedJson as? [String: Any], let m = Type.deserialize(from: dic) {
            md = m
            return
        }
        if let list = nestedJson as? [Any], let m = [Type].deserialize(from: list) {
            models = m as? [Type]
        }
    }
}
