//
//  ViewController.swift
//  JKSwiftNetProcessor
//
//  Created by JoanKing on 12/23/2020.
//  Copyright (c) 2020 JoanKing. All rights reserved.
//

import UIKit
import Alamofire
import JKSwiftExtension

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
        dataArray = [["配置基本的信息", "注意事项\n2.1、在 model 仅仅是服务器的数据的时候使用 struct，如果有其他自定义字段我们就需要使用 class;\n2.2、在返回的数据是 data 是数组的时候，我们需要把model用 `[]` 包裹起来"], ["data是Array类型（model是struct）", "data是Dictionary类型", "data是Array类型(有自定义字段，model是class)", "data类型是嵌套的模型", "data类型里面的 nick_name 自定义为 nickName"], ["上传"], ["自定义下载文件的保存目录：下面代码将logo图片下载下来保存到用户文档目录下（Documnets目录）,文件名不变。", "自定义下载文件的保存目录：将logo图片下载下来保存到用户 Documnets/测试改名 目录下,文件名改成myLogo.png", "使用默认提供的下载路径：Alamofire内置的许多常用的下载路径方便我们使用，简化代码。注意的是，使用这种方式如果下载路径下有同名文件，不会覆盖原来的文件", "下载时附带请求参数：如果下载文件时需要传递一些参数，我们可以将参数拼接在 url 后面。也可以配置在 download 方法里的 parameters 参数中（其实这个方式最终也是拼接到 url 后面）", "下载进度：下载过程中会不断地打印下载进度，同时下载完成后也会打印完成信息，下载的过程中我们也可以得到已下载部分的大小，以及文件总大小。（单位都是字节）", "断点续传（Resume Data）：当下载过程中被意外停止时，可以在响应方法中把已下载的部分保存起来，下次再从断点继续下载"], ["日志跳转", "测试"]]
    }
}

// MARK:- 五、日志
extension ViewController {
    
    @objc func test52() {
   
        Alamofire.request("http://cg-trade-gateway-test.yixin.com/user/helpCenter/select/treeDetail?id=79", parameters: nil).responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                if let JSON = response.result.value {
                    print("JSON: \(JSON)") //具体如何解析json内容可看下方“响应处理”部分
                }
            }
    }
    
    // MARK: 5.1、日志跳转
    @objc func test51() {
        self.present(ProcessorServerLogViewController(), animated: true, completion: nil)
    }
}

// MARK:- 四、下载
extension ViewController {
    
    // MARK: 4.6、断点续传（Resume Data）：当下载过程中被意外停止时，可以在响应方法中把已下载的部分保存起来，下次再从断点继续下载
    @objc func test46() {
        /**
          下面通过样例演示如何断点续传：
         （1）程序启动后自动开始下载文件
         （2）点击“停止下载”，终止下载并把已下载的数据保存起来，进度条停止走动。
         （3）点击“继续下载”，从上次终止的地方继续下载，进度条继续走动。
         */
        self.navigationController?.pushViewController(ResumeDataViewController(), animated: true)
    }
    
    // MARK: 4.5、下载进度：下载过程中会不断地打印下载进度，同时下载完成后也会打印完成信息，下载的过程中我们也可以得到已下载部分的大小，以及文件总大小。（单位都是字节）
    @objc func test45() {
        let imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 150, height: 150))
        self.view.addSubview(imageView)
        //下面这两种方式效果是一样的
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download("http://localhost/large.png", to: destination).response(completionHandler: { (response) in
            
        }).downloadProgress { progress in
                print("当前进度: \(progress.fractionCompleted)")
                print("已下载：\(progress.completedUnitCount/1024)KB")
                print("总大小：\(progress.totalUnitCount/1024)KB\n--------------------------------------")
            }.responseData { response in
                if let data = response.result.value {
                    print("下载完毕!")
                    let image = UIImage(data: data)
                    imageView.image = image
                    JKAsyncs.asyncDelay(3) {
                    } _: {
                        imageView.removeFromSuperview()
                    }
                }
            }
    }
    
    // MARK: 4.4、下载时附带请求参数：如果下载文件时需要传递一些参数，我们可以将参数拼接在 url 后面。也可以配置在 download 方法里的 parameters 参数中（其实这个方式最终也是拼接到 url 后面）
    @objc func test44() {
        let imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 150, height: 150))
        self.view.addSubview(imageView)
        // 下面这两种方式效果是一样的
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        // Alamofire.download("http://www.hangge.com/blog/images/logo.png?foo=bar", to: destination)
        Alamofire.download("http://www.hangge.com/blog/images/logo.png", parameters: ["foo": "bar"],
                           to: destination).response { (response) in
                            
                if let imagePath = response.destinationURL?.path {
                    let image = UIImage(contentsOfFile: imagePath)
                    imageView.image = image
                    JKAsyncs.asyncDelay(3) {
                    } _: {
                        imageView.removeFromSuperview()
                    }
                }
        }
    }
    
    // MARK: 4.3、使用默认提供的下载路径，Alamofire内置的许多常用的下载路径方便我们使用，简化代码。注意的是，使用这种方式如果下载路径下有同名文件，不会覆盖原来的文件。
    @objc func test43() {
        let imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 150, height: 150))
        self.view.addSubview(imageView)
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download("http://localhost/ironman.png", to: destination).response { (response) in
            if let imagePath = response.destinationURL?.path {
                let image = UIImage(contentsOfFile: imagePath)
                imageView.image = image
                JKAsyncs.asyncDelay(3) {
                } _: {
                    imageView.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK: 4.2、自定义下载文件的保存目录：将logo图片下载下来保存到用户 Documnets/测试改名 目录下,文件名改成myLogo.png
    @objc func test42() {
        
        let imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 150, height: 150))
        self.view.addSubview(imageView)
        //指定下载路径和保存文件名
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = URL(fileURLWithPath: FileManager.jk.DocumnetsDirectory() + "/测试改名/" + "myLogo.png")
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
         
        //开始下载
        Alamofire.download("http://localhost/testicon.png", to: destination)
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
        }
    }
    
    // MARK: 4.1、自定义下载文件的保存目录：将logo图片下载下来保存到用户文档目录下（Documnets目录）,文件名不变
    @objc func test41() {
        
        let imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 150, height: 150))
        self.view.addSubview(imageView)
        
        print("路径：\(FileManager.jk.homeDirectory())")
        // 指定下载后的存储路径（文件名不变）
        let destination: DownloadRequest.DownloadFileDestination = { _, response in
            let fileURL = URL(fileURLWithPath: FileManager.jk.DocumnetsDirectory() + "/" + response.suggestedFilename!)
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
            } else {
                JKPrint(response.getMsgStr())
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

