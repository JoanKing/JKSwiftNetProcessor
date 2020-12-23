//
//  Animal.swift
//  JKSwiftNetProcessor_Example
//
//  Created by IronMan on 2020/12/23.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class AnimalRequest: JKCodable<Animal> {
    override init() {
        super.init()
    }
    
    override public var path: String {
        return kURLAnimalInfo
    }
    
    override var baseURL: URL {
        return URL(string: kBaseUrl)!
    }
}

struct Animal: Codable {

    /// 名字
    var name: String = ""
    /// 动物类型
    var type: AnimalType?
}

struct AnimalType: Codable {

    /// 身高
    var height: String = ""
    /// 时间
    var time: String = ""
}

