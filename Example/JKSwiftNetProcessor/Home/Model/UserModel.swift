//
//  UserModel.swift
//  JKSwiftNetProcessor_Example
//
//  Created by IronMan on 2020/12/23.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct UserModel: Codable {

    var name: String = ""
    var age: Int = 0
    var sex: String?
}

class UserInfoRequestList: JKCodable<UserModel> {
    
    override init() {
        super.init()
    }
    
    override public var path: String {
        return kURLUserinfo
    }
    
    override var baseURL: URL {
        return URL(string: kBaseUrl)!
    }
    
    override var method: HTTPMethod {
        .get
    }
    
    override var isNeedCache: Bool {
        return true
    }
    
    override var cacheName: String {
        return "B-stockIndexList"
    }
    
}
