//
//  ProcessorCachsFileUtil.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import Foundation

// MARK:- 数据文件的缓存
public class ProcessorCachsFileUtil {
    
    // MARK: 获取缓存路径
    /// 获取缓存路径
    /// - Parameters:
    ///   - fileName: 文件的名字
    ///   - fileType: 文件类型
    /// - Returns: 返回文件路径
    public static func getPath(_ fileName: String, fileType: String) -> String {
        let ducumentPath = NSHomeDirectory() + "/Documents"
        let file = fileName + "." + fileType
        let jsonPath = (ducumentPath as NSString).appendingPathComponent(file)
        return jsonPath
    }
    
    // MARK: json数据写入文件
    /// json数据写入文件
    /// - Parameters:
    ///   - filePath: 文件路径
    ///   - jsonDic: json字典
    /// - Returns: 返回写入的结果
    public static func writeFile(_ filePath: String, jsonDic: NSDictionary?) -> Bool {
        guard let jsonDictionary = jsonDic else{
            return false
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
            let retString = String(data: jsonData, encoding: .utf8) ?? ""
            let dictionary: NSDictionary = ["value": retString]
            return dictionary.write(toFile: filePath, atomically: true)
        } catch {
            return false
        }
    }
    
    // MARK: 读取缓存文件
    /// 读取缓存文件
    /// - Parameter filePath: 缓存路径
    /// - Returns: 返回缓存的数据
    public static func readFile(_ filePath: String) -> NSDictionary? {
        let source = NSMutableDictionary.init(contentsOfFile: filePath)
        guard let jsonString = source?.value(forKey: "value") as? String else {
            return nil
        }
        let stringData = jsonString.data(using: .utf8)
        do {
            if let jsonDictionary = try JSONSerialization.jsonObject(with: stringData ?? Data(), options: []) as? [String: Any?] {
                return jsonDictionary as NSDictionary
            }
        } catch {
            return nil
        }
        return nil
    }
}

