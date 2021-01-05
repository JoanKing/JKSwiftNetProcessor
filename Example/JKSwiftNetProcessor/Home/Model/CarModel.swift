//
//  CarModel.swift
//  JKSwiftNetProcessor_Example
//
//  Created by IronMan on 2020/12/31.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct CarModel: Codable {
    /// 车的名字(这个是自定义的键值名)，json 里面是 nick_name
    var nickName: String = ""
    /// 车的高度
    var height: CGFloat?
    /// 车的年龄
    var age: CGFloat?
    /// 车的年龄2(新增字段)
    var age2: CGFloat? {
        return (self.age ?? 0) + 1.0
    }
    
    // 自定义键值名,虽然只是将 nick_name->nickName 其他字符也需要在这里列一遍，否则转换失败
    enum CodingKeys: String, CodingKey {
        case nickName = "nick_name"
        case height
        case age
    }
}

class CarRequest: JKCodable<CarModel> {
    override init() {
        super.init()
    }
    
    override public var path: String {
        return kURLCarInfo
    }
    
    override var baseURL: URL {
        return URL(string: kBaseUrl)!
    }
}
