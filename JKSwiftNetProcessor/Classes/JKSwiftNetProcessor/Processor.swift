//
//  Processor.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import Alamofire
import Foundation
import HandyJSON

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias JSONType = Any
public typealias BaseModel = HandyJSON

public let MimeTypeImg = "image/jpeg"

// MARK: 请求动作
public enum ProcessorAction {
    // 普通的请求
    case request
    // 上传数据 MultiPart
    case upload([ProcessorMultipart])
    // case download //暂时先不实现，没有需求
}

public enum ProcessorParameterEncoding {
    case URL
    case JSON
}

// MARK:- Processor 协议
public protocol Processor: class {
    
    /// The target's base `URL`.
    var baseURL: URL { get }
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }
    /// The HTTP method used in the request.
    var method: HTTPMethod { get }
    /// The HTTP
    var parameters: [String: Any]? { get }
    /// parameter encoding type, URL or JSON
    var parameterEncoding: ProcessorParameterEncoding { get }
    /// The headers to be used in the request.
    var headers: [String: String]? { get }
    /// request or upload
    var action: ProcessorAction { get }
    /// request object of AF, for cancel
    var request: ProcessorRequest? { set get }
}

public extension Processor {
    func cancel() {
        request?.cancel()
    }
}

public protocol ProcessorDecoding: Processor {
    associatedtype DataType
    var responseDecoder: ResponseDecoder { get }
    var modelKeysPath: String? { get }
    func responseWillCall(response: Response<DataType>)
    func responseDidCall(response: Response<DataType>)
    var completionStorage: ProcessorCompletionStorage<DataType> { get }
}

open class ProcessorCompletionStorage<DataType> {
    var completion: ((Response<DataType>) -> Void)?
    var success: ((Response<DataType>) -> Void)?
    var empty: ((Response<DataType>) -> Void)?
    var failure: ((Response<DataType>) -> Void)?
    var failureToast: ((Response<DataType>) -> Void)?
    
    open func excute(resp: Response<DataType>) {
        completion?(resp)
        if resp.isSuccess {
            success?(resp)
            checkEmpty(resp: resp)
        } else {
            failure?(resp)
            if !resp.isCancel {
                failureToast?(resp)
            }
        }
    }
    
    open func checkEmpty(resp: Response<DataType>) {
        guard let model = resp.model else {
            empty?(resp)
            return
        }
        if let list = model as? [Any], list.isEmpty {
            empty?(resp)
        }
        if let dic = model as? [String: Any], dic.isEmpty {
            empty?(resp)
        }
    }

    public init() {}
}

fileprivate extension ProcessorDecoding {
    
    func requestData(url: URL, responseHandler: @escaping (DataResponse<Any>) -> Response<DataType>, _ progress: ((Progress)->(Void))? = nil) {
        
        let responseClosure: (DataResponse<Any>) -> Void = { response in
            let resp = responseHandler(response)
            self.responseWillCall(response: resp)
            self.completionStorage.excute(resp: resp)
            self.responseDidCall(response: resp)
            self.observer?.remove(processor: self)
        }
        requestData(url: url, responseHandler: responseClosure, progress)
    }
    
    // MARK: 上传和普通请求的区分
    // BaseModel请求直接调这个
    func requestData(url: URL, responseHandler: @escaping (DataResponse<Any>) -> Void, _ progress: ((Progress)->(Void))? = nil) {
        switch action {
        case let .upload(datas):
            upload(datas: datas, url: url, responseHandler: responseHandler, progress)
        case .request:
            request(url: url, responseHandler: responseHandler)
        }
    }
    
    // MARK: 上传
    // 上传
    private func upload(datas: [ProcessorMultipart], url: URL, responseHandler: @escaping (DataResponse<Any>) -> Void, _ uploadProgress: ((Progress)->(Void))? = nil) {
        let formDatas = addUploadParam(formdatas: datas)
        var headers: [String: String] = self.headers ?? [:]
        do {
            let data = try formDatas.processorEncode()
            if headers["Content-Type"] == nil {
                headers["Content-Type"] = data.1
            }
            let req = ServerManager.default.upload(data.0, to: url, method: method, headers: headers)
            req.responseJSON(completionHandler: responseHandler)
            request = req
            req.uploadProgress { (progress) in
                uploadProgress?(progress)
            }
        } catch let err {
            let resp = DataResponse<Any>(request: nil, response: nil, data: nil, result: Result.failure(err))
            responseHandler(resp)
        }
    }
    
    // MARK: 普通请求
    // 普通请求
    private func request(url: URL, responseHandler: @escaping (DataResponse<Any>) -> Void) {
        let paramEncoding: Alamofire.ParameterEncoding
        switch parameterEncoding {
        case .URL:
            paramEncoding = URLEncoding.default
        case .JSON:
            paramEncoding = JSONEncoding.default
        }
        let req = ServerManager.default.request(url, method: method, parameters: parameters, encoding: paramEncoding, headers: headers)
        req.responseJSON(completionHandler: responseHandler)
        request = req
    }
}

public extension ProcessorDecoding {
    
    // MARK: 请求完成后的返回Closure
    /// 请求完成后的返回Closure
    @discardableResult
    func completion(_ completion: @escaping (Response<DataType>) -> Void) -> Self {
        completionStorage.completion = completion
        return self
    }
    
    // MARK: 请求成功的Closure，成功必须是与server的协议成功，并非http 200，但是基于http 200
    /// 请求成功的Closure，成功必须是与server的协议成功，并非http 200，但是基于http 200
    @discardableResult
    func success(_ success: @escaping (Response<DataType>) -> Void) -> Self {
        completionStorage.success = success
        return self
    }
    
    // MARK: 请求成功相反
    /// 与请求成功相反
    @discardableResult
    func failure(_ failure: @escaping (Response<DataType>) -> Void) -> Self {
        completionStorage.failure = failure
        return self
    }
    
    // MARK: 调用后自动为失败弹出toast
    /// 调用后自动为失败弹出toast
    @discardableResult
    func failureToast() -> Self {
        completionStorage.failureToast = { resp in
        }
        return self
    }
}

public extension ProcessorDecoding where DataType == Any {
    
    @discardableResult
    func request(completion: @escaping (Response<DataType>) -> Void) -> Self {
        completionStorage.completion = completion
        return start()
    }
    
    @discardableResult
    func start() -> Self {
        let url = baseURL.append(path: path)
        let responseHandler: (DataResponse<Any>) -> Response<DataType> = { response in
            let resp = Response<DataType>(responseValue: response.value, parameters: self.parameters, header: self.headers, url: url)
            resp.decode(dataResponse: response, responseDecoder: self.responseDecoder, modelKeysPath: self.modelKeysPath)
            return resp
        }
        requestData(url: url, responseHandler: responseHandler)
        return self
    }
}

// MARK:- 遵守协议 Codable 的网络请求
public extension ProcessorDecoding where DataType: Codable {
    // MARK: 最初的普通请求
    @discardableResult
    func request(completion: @escaping (Response<DataType>) -> Void) -> Self {
        completionStorage.completion = completion
        return start()
    }
    
    // MARK: 最初的 上传 请求
    @discardableResult
    func upload(completion: @escaping (Response<DataType>) -> Void, _ progress: ((Progress)->(Void))? = nil) -> Self {
        completionStorage.completion = completion
        return start(progress)
    }
    
    // MARK: 开始请求
    @discardableResult
    func start(_ progress: ((Progress)->(Void))? = nil) -> Self {
        let url = baseURL.append(path: path)
        let responseHandler: (DataResponse<Any>) -> Response<DataType> = { response in
            let resp = Response<DataType>(responseValue: response.value, parameters: self.parameters, header: self.headers, url: url)
            resp.decode(dataResponse: response, responseDecoder: self.responseDecoder, modelKeysPath: self.modelKeysPath)
            return resp
        }
        requestData(url: url, responseHandler: responseHandler, progress)
        return self
    }
}

public protocol ProcessorCodable: ProcessorDecoding where DataType: Codable {}

public protocol ListModelRequest {
    var pageIndex: Int? { get set }
    var pageSize: Int? { get }
    func hasMore(pageSize: Int) -> Bool
}

public extension ListModelRequest {
    func hasMore(pageSize: Int) -> Bool {
        return pageSize >= self.pageSize ?? 0
    }
}

// MARK:- 以下即将废弃
public protocol ProcessorBaseModel: ProcessorDecoding where DataType: BaseModel {}

public extension ProcessorBaseModel {
    @discardableResult
    func request(completion: @escaping (ResponseBaseModel<DataType>) -> Void) -> Self {
        let url = baseURL.append(path: path)
        let responseHandler: (DataResponse<Any>) -> Void = { response in
            let resp = ResponseBaseModel<DataType>(responseValue: response.value, parameters: self.parameters, header: self.headers, url: url, decoder: self.responseDecoder, keyPath: self.modelKeysPath)
            self.responseWillCall(response: resp)
            completion(resp)
            self.responseDidCall(response: resp)
            self.observer?.remove(processor: self)
        }
        requestData(url: url, responseHandler: responseHandler)
        return self
    }
}

extension Date: HandyJSONCustomTransformable {
    public static func _transform(from object: Any) -> Date? {
        if let timeInt = object as? Int {
            return Date(timeIntervalSince1970: TimeInterval(timeInt))
        }
        if let timeInt = object as? Double {
            return Date(timeIntervalSince1970: TimeInterval(timeInt))
        }
        if let timeStr = object as? String {
            return Date(timeIntervalSince1970: TimeInterval(atof(timeStr)) / 1000)
        }
        return nil
    }

    public func _plainValue() -> Any? {
        return "\(timeIntervalSince1970 * 1000)"
    }
}

