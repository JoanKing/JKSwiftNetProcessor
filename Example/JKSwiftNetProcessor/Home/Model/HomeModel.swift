//
//  HomeModel.swift
//  JKSwiftNetProcessor_Example
//
//  Created by IronMan on 2020/12/23.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

struct HomeModel: Codable {
    var name: String = ""
    var age: Int = 0
    var sex: String?
}

class HomeModelList: JKCodable<[HomeModel]> {
    init(username: String) {
        super.init()
        param["username"] = username
    }
    
    override public var path: String {
        return KURLHomelist
    }
    
    
    override var baseURL: URL {
        return URL(string: kBaseUrl)!
    }
    
    override var isNeedCache: Bool {
        return true
    }
    
    override var cacheName: String {
        return "A-stockIndexList"
    }
}
