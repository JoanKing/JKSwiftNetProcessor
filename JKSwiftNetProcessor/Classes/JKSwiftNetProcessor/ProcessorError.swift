//
//  ProcessorError.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import Foundation

public enum ProcessorError: Error {
    case unknow
    case jsonInvalid(reason: JsonInvaliedReason)
    case businessFailed(msg: String?, errorCode: String?)
    case AFError(error: Error)
    case modelEncodingFailed(error: Error)
    case jsonSerializationFailed(error: Error)

    public enum JsonInvaliedReason {
        case jsonNil
        case encodingJsonInvalid(json: Any?)
    }
}

extension ProcessorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknow:
            return "Processor-> request error whit unkow reason"
        case let .jsonInvalid(reason: reason):
            return reason.localizedDescription
        case let .businessFailed(msg: msg, errorCode: errorCode):
            var result = "Processor-> Business request failed,"
            result.append("msg: \(msg ?? "<msg null>") \n")
            result.append("errrCode: \(errorCode ?? "<errorCode null>")")
            return result
        case let .AFError(error: err):
            return "Processor-> AFError: \n\(err.localizedDescription)"
        case let .modelEncodingFailed(error: err):
            return "Processor-> Model encoding error: \n\(err.localizedDescription)"
        case let .jsonSerializationFailed(error: err):
            return "Processor-> Model encoding error: \n\(err.localizedDescription)"
        }
    }
}

extension ProcessorError.JsonInvaliedReason {
    var localizedDescription: String {
        switch self {
        case .jsonNil:
            return "Processor-> Response Json is nil"
        case let .encodingJsonInvalid(json: json):
            return "Processor-> Encoding Json is invalid: \n\(json ?? "json is nil")"
        }
    }
}

