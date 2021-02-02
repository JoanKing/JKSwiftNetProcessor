//
//  ViewController.swift
//  JKSwiftNetProcessor
//
//  Created by JoanKing on 12/23/2020.
//  Copyright (c) 2020 JoanKing. All rights reserved.
//

import UIKit
import Alamofire
class ViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 类型要求如下
         {
         "resultCode": "1",
         "errorCode": "0000",
         "msg": "",
         "serverTime": "2020-11-19T10:52:44.881+0000",
         "data": {
         "name": "1",
         "age": 12,
         "sex": "1"
         }
         }
         */
        print("路径=\(NSHomeDirectory())")
        
        headDataArray = ["一、网络的基本配置", "二、网络请求", "三、网络上传", "四、网络下载：配置的本地Apache服务器：https://www.jianshu.com/p/713adb751223", "五、日志"]
        dataArray = [["配置基本的信息", "注意事项\n2.1、在 model 仅仅是服务器的数据的时候使用 struct，如果有其他自定义字段我们就需要使用 class;\n2.2、在返回的数据是 data 是数组的时候，我们需要把model用 `[]` 包裹起来"], ["data是Array类型（model是struct）", "data是Dictionary类型", "data是Array类型(有自定义字段，model是class)", "data类型是嵌套的模型", "data类型里面的 nick_name 自定义为 nickName"], ["上传"], ["下载1：下面代码将logo图片下载下来保存到用户文档目录下（Documnets目录）,文件名不变。", "显示"], ["日志跳转"]]
    }
}

// MARK:- 五、日志
extension ViewController {
    
    // MARK: 5.1、日志跳转
    @objc func test51() {
        self.present(ProcessorServerLogViewController(), animated: true, completion: nil)
    }
}

// MARK:- 四、下载
extension ViewController {
    
    @objc func test42() {
        
    }
    
    // MARK: 4.1、将logo图片下载下来保存到用户文档目录下（Documnets目录）,文件名不变
    @objc func test41() {
        
        let imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 150, height: 150))
        self.view.addSubview(imageView)
        
        print("路径：\(FileManager.homeDirectory())")
        // 指定下载后的存储路径（文件名不变）
        let destination: DownloadRequest.DownloadFileDestination = { _, response in
            let fileURL = URL(fileURLWithPath: FileManager.DocumnetsDirectory() + "/" + response.suggestedFilename!)
            // 两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        // 开始下载
        Alamofire.download("http://localhost/ironman.png", to: destination)
            .response { response in
                
                print(response)
                
                if let imagePath = response.destinationURL?.path {
                    let image = UIImage(contentsOfFile: imagePath)
                    imageView.image = image
                    JKAsyncs.asyncDelay(3) {
                    } _: {
                        imageView.removeFromSuperview()
                    }
                }
                /*
                 let readData = FileManager.readFromFile(readType: .ImageType, readPath: FileManager.DocumnetsDirectory() + "/ironman.png")
                 imageView.image = (readData.content as! UIImage)
                 */
            }
    }
}


// MARK:- 三、上传
extension ViewController {
    
    // MARK: 3.1、上传
    @objc func test31() {
        // 资源数据
        let data = Data()
        VodeoUploadRequest(data: data).upload { (response) in
            guard response.isSuccess, let _ = response.model else {
                return
            }
            print("上传成功...")
        } _: { (progress) -> (Void) in
            print("上传的进度：\(progress)")
        }
    }
}

// MARK:- 二、网络请求
extension ViewController {
    
    // MARK: 2.1、data是Array类型（model是struct）
    @objc func test21() {
        
        let request = HomeModelList(username: "王二")
        if request.isNeedCache, let models = request.readcache() {
            print("缓存数组的个数：\(models.count)")
        }
        
        // model 是 HomeModel
        // wiki链接是：http://rest.apizza.net/mock/f7479d4be5e7ab3d9829e20c2835578c/homelist
        HomeModelList(username: "王二").request { (response) in
            print("列表：\(response.json as Any)")
        }
    }
    
    // MARK: 2.2、data是Dictionary类型
    @objc func test22() {
        // model 是 UserModel
        // wiki链接是：http://rest.apizza.net/mock/f7479d4be5e7ab3d9829e20c2835578c/userinfo
        UserInfoRequestList().request { (response) in
            print("个人信息：\(response.json as Any)")
        }
    }
    
    // MARK: 2.3、data是Array类型(有自定义字段)
    @objc func test23() {
        // model 是 UserModel
        // wiki链接是：http://rest.apizza.net/mock/f7479d4be5e7ab3d9829e20c2835578c/personinfo
        PersonInfoRequest().request { (response) in
            print("person信息：\(response.json as Any)")
            if response.isSuccess, let model = response.model {
                print("姓名和身高：\(model.nameAndAge ?? "")")
            }
        }
    }
    
    // MARK: 2.4、data类型是嵌套的模型
    @objc func test24() {
        // model 是 UserModel
        // wiki链接是：http://rest.apizza.net/mock/f7479d4be5e7ab3d9829e20c2835578c/animal
        AnimalRequest().request { (response) in
            print("person信息：\(response.json as Any)")
            if response.isSuccess, let model = response.model, let type = model.type  {
                print("动物的高度：\(type.height)")
            }
        }
    }
    
    // MARK: 2.5、data类型里面的 nick_name 自定义为 nickName
    @objc func test25() {
        // model 是 UserModel
        // wiki链接是：http://rest.apizza.net/mock/f7479d4be5e7ab3d9829e20c2835578c/car
        CarRequest().request { (response) in
            print("Car信息：\(response.json as Any)")
            if response.isSuccess, let model = response.model {
                print("汽车的名字：\(model.nickName)")
                print("汽车的高度：\(model.height ?? 3)")
                print("汽车的年龄：\(model.age ?? 20)")
                print("汽车的年龄2：\(model.age2 ?? 11)")
            }
        }
    }
}

// MARK:- 一、网络的基本配置
extension ViewController {
    
    // MARK: 1.1、配置基本的信息
    @objc func test11() {
        // 配置一些基本的信息
        JKNetConfig.config(chanId: "appstore", baseUrl: kBaseUrl, secrKey: "")
    }
}

