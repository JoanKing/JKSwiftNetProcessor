//
//  ResumeDataViewController.swift
//  JKSwiftNetProcessor_Example
//
//  Created by IronMan on 2021/2/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Alamofire

class ResumeDataViewController: UIViewController {

    /// 开始下载按钮
    lazy var startBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: kScreenW / 2.0 - 150, y: stopBtn.jk.bottom + 50, width: 90, height: 40))
        button.backgroundColor = .randomColor
        button.setTitle("开始下载", for: .normal)
        button.addTarget(self, action: #selector(startBtnClick), for: .touchUpInside)
        return button
    }()
    
    /// 停止下载按钮
    lazy var stopBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: kScreenW / 2.0 - 150, y: downProgress.jk.bottom + 50, width: 90, height: 40))
        button.backgroundColor = .randomColor
        button.setTitle("停止下载", for: .normal)
        button.addTarget(self, action: #selector(stopBtnClick), for: .touchUpInside)
        return button
    }()
    /// 继续下载按钮
    lazy var continueBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: kScreenW / 2.0 + 60, y: downProgress.jk.bottom + 50, width: 90, height: 40))
        button.backgroundColor = .randomColor
        button.setTitle("继续下载", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(continueBtnClick), for: .touchUpInside)
        return button
    }()
    /// 下载进度条
    lazy var downProgress: UIProgressView = {
        let progress = UIProgressView(frame: CGRect(x: 20, y: 150, width: kScreenW - 40, height: 30))
        // 进度条颜色
        // 已有进度颜色
        progress.progressTintColor = UIColor.red
        // 剩余进度颜色（即进度槽颜色）
        progress.trackTintColor = UIColor.blue
        // 更改进度条高度(宽度不变，高度变为默认的3倍)，/ 默认高度2.0
        progress.transform = CGAffineTransform(scaleX: 1.0,y: 3.0)
        return progress
    }()
    /// 下载文件的保存路径（
    var destination: DownloadRequest.DownloadFileDestination!
    ///用于停止下载时，保存已下载的部分
    var cancelledData: Data?
    /// 下载请求对象
    var downloadRequest: DownloadRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brown
        self.view.addSubview(downProgress)
        self.view.addSubview(stopBtn)
        self.view.addSubview(continueBtn)
        self.view.addSubview(startBtn)
    }

    // 下载过程中改变进度条
    func downloadProgress(progress: Progress) {
        //进度条更新
        self.downProgress.setProgress(Float(progress.fractionCompleted), animated:true)
        print("当前进度：\(progress.fractionCompleted*100)%")
    }
    
    
    // 下载停止响应（不管成功或者失败）
    func downloadResponse(response: DownloadResponse<Data>) {
        switch response.result {
        case .success(_):
            //self.image = UIImage(data: data)
            print("文件下载完毕: \(response)")
        case .failure:
            // 意外终止的话，把已下载的数据储存起来
            self.cancelledData = response.resumeData
        }
    }
    
    @objc func startBtnClick() {
        //设置下载路径。保存到用户文档目录，文件名不变，如果有同名文件则会覆盖
        self.destination = { _, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                        in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename!)
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        //页面加载完毕就自动开始下载
        self.downloadRequest =  Alamofire.download(
            "http://dldir1.qq.com/qqfile/qq/QQ7.9/16621/QQ7.9.exe", to: destination)
        self.downloadRequest.downloadProgress(queue: DispatchQueue.main, closure: downloadProgress) //下载进度
        self.downloadRequest.responseData(completionHandler: downloadResponse) //下载停止响应
    }
    
    // 停止按钮点击
    @objc func stopBtnClick(sender: UIButton) {
        self.downloadRequest?.cancel()
        self.stopBtn.isEnabled = false
        self.continueBtn.isEnabled = true
    }
    
    // 继续按钮点击
    @objc func continueBtnClick(sender: UIButton) {
        if let cancelledData = self.cancelledData {
            self.downloadRequest = Alamofire.download(resumingWith: cancelledData,
                                                      to: destination)
            // 下载进度
            self.downloadRequest.downloadProgress(queue: DispatchQueue.main,
                                                  closure: downloadProgress)
            // 下载停止响应
            self.downloadRequest.responseData(completionHandler: downloadResponse)
            self.stopBtn.isEnabled = true
            self.continueBtn.isEnabled = false
        }
    }
}
