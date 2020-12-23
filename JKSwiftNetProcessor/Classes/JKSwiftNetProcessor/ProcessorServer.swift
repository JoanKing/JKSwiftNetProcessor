//
//  ProcessorServer.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import Foundation
import Alamofire

public protocol Server {}

class AFRequestAdapter: RequestAdapter {
    
    let timeoutInterval: TimeInterval
    
    init(timeoutInterval: TimeInterval = 9) {
        self.timeoutInterval = timeoutInterval
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        request.timeoutInterval = timeoutInterval
        return request
    }
}

let requestAdapter = AFRequestAdapter()

class ServerManager {
    public static let `default`: SessionManager = {
        let serverTrustPolicy = ServerTrustPolicy.performDefaultEvaluation(validateHost: true)
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "yingapi.yirendai.com": serverTrustPolicy
        ]
        let manager = SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        // 可以在必要时以某种方式检查和可选地调整URLRequest的类型
        manager.adapter = requestAdapter
        // 一种类型，用于确定在由指定的会话管理器执行并遇到错误之后是否应重试请求
        // manager.retrier =
        return manager
    }()
}

