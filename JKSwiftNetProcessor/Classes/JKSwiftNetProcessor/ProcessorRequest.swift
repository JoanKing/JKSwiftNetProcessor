//
//  ProcessorRequest.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import Foundation
import Alamofire

public protocol ProcessorRequest: class {
    func cancel()
    func resume()
}

extension Alamofire.Request: ProcessorRequest {}
