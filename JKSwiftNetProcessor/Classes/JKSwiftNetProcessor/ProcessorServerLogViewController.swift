//
//  ProcessorServerLogViewController.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import UIKit
/// 状态栏的高度
let kStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
/// 是否是刘海屏
let isIphoneX: Bool = (kStatusBarHeight > 20)
let kBottomSafeAreaHeight: CGFloat = (isIphoneX ? 34 : 0)

class DebugNav: UINavigationController {}

public class ProcessorServerLogViewController: UIViewController {
    let textview = UITextView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "NSLog打印日志"
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = UIColor.black
        
        textview.isEditable = false
        textview.backgroundColor = UIColor.black
        textview.font = UIFont.systemFont(ofSize: 13)
        textview.textColor = .white
        let top = UIApplication.shared.statusBarFrame.size.height + 20
        let bottom = kBottomSafeAreaHeight + 60
        textview.frame = CGRect(x: 10, y: top, width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.height - top - bottom)
        self.view.addSubview(textview)
        
        let backBtn = UIButton(frame: CGRect(x: 0, y: textview.frame.maxY, width: UIScreen.main.bounds.size.width / 2.0, height: 40))
        backBtn.setTitle("返回", for: .normal)
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(backBtn)
        
        let refreshBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width / 2.0, y: textview.frame.maxY, width: UIScreen.main.bounds.size.width / 2.0, height: 40))
        refreshBtn.setTitle("刷新", for: .normal)
        refreshBtn.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        self.view.addSubview(refreshBtn)
        
        let str = ServerLog.readLogFile()
        textview.text = str
        textview.layoutManager.allowsNonContiguousLayout = false
        
        self.toBottom()
    }
    
    func toBottom() {
        // 读取textview的range
        let nsra:NSRange = NSMakeRange((textview.text.lengthOfBytes(using: String.Encoding.utf8))-1, 1)
         // 将textview滚动到最后一栏。
        textview.scrollRangeToVisible(nsra)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.toBottom()
    }
    
    @objc func back() {
        if let nav = self.navigationController  {
            if nav.viewControllers.count > 1 {
                nav.popViewController(animated: true)
            } else if let _ = nav.presentingViewController {
                nav.dismiss(animated: true, completion: nil)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func refresh() {
        self.textview.text = ServerLog.readLogFile()
        self.toBottom()
    }
    
    static func showLogVC() {
        let vc = UIViewController.getCurrentVC()
        vc.present(ProcessorServerLogViewController(), animated: true, completion: nil)
    }
}

fileprivate extension UIViewController {
    
    // MARK: 获取当前VC
    /// 获取当前VC
    /// - Returns: 当前VC
    class final func getCurrentVC() -> UIViewController {
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            return UIViewController()
        }
        let curVC = getCurrentVCFrom(rootVC)
        return curVC
    }
    
    class final func getCurrentVCFrom(_ rootVC:UIViewController) -> UIViewController {
        var curVC:UIViewController?
        var rootTempVC = rootVC
        
        if let vc = rootTempVC.presentedViewController {
            // 视图是被presented出来的
            rootTempVC = vc
        }
        
        if rootTempVC is UITabBarController {
            // 根视图为UITabBarController
            let vc = rootTempVC as? UITabBarController
            curVC = getCurrentVCFrom((vc?.selectedViewController)!)
        } else if rootTempVC is UINavigationController {
            // 根视图为UINavigationController
            let vc = rootTempVC as? UINavigationController
            if let visibleViewController = vc?.visibleViewController {
                curVC = getCurrentVCFrom(visibleViewController)
            } else {
                curVC = rootTempVC
            }
        } else {
            curVC = rootTempVC
        }
        return curVC ?? (UIApplication.shared.keyWindow?.rootViewController)!
    }
}
 

