//
//  ProcessorServerLog.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import Foundation

public struct ServerLog {
    // MARK: 设置日志文件和信息
    public static func redirectConsoleLogToDocumentFolder() {
        #if DEBUG
        // 设置日志
        freopen(logFilePath(), "a+", stderr)
        #endif
    }
    
    // MARK: 读取日志信息
    static func readLogFile() -> String {
        let logPath = logFilePath()
        do {
            let content = try String(contentsOfFile: logPath)
            return content
        } catch {
            return ""
        }
    }
    
    // MARK: 文件路径
    static func logFilePath() -> String {
        let timestamp = Int64(Date().timeIntervalSince1970)
        let time = Self.toString(formatter: "MM_dd", timeIntervalSince1970: Int(timestamp))
        let fileName = "APPlogNew" + time + ".log"
        let result = createFolder(folderPath: NSHomeDirectory() + "/Documents/JKAppLogs")
        guard result.isSuccess else {
            return (NSHomeDirectory() + "/Documents" as NSString).appendingPathComponent(fileName)
        }
        let documentPath = NSHomeDirectory() + "/Documents/JKAppLogs"
        let logPath = (documentPath as NSString).appendingPathComponent(fileName)
        return logPath
    }
    
    // MARK: 日志信息打印
    public static func log(content: String) {
        let timestamp = Int64(Date().timeIntervalSince1970)
        let time = Self.toString(formatter: "yyyy年MM月dd日 HH:mm:ss", timeIntervalSince1970: Int(timestamp))
        let log = "\r\n服务请求日志SeverLog_" + time + " " + content
        #if DEBUG
        NSLog(log)
        #endif
    }
}

private extension ServerLog {
    // MARK: 时间的转换
    static func toString(formatter: String, timeIntervalSince1970: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timeIntervalSince1970))
        let dformatter = DateFormatter()
        dformatter.dateFormat = formatter
        return dformatter.string(from: date)
    }
}
 
private extension ServerLog {
    // MARK: 创建文件夹
    /// 创建文件夹
    /// - Parameter folderName: 文件夹的名字
    /// - Returns: 返回创建的 创建文件夹路径
    @discardableResult
    static func createFolder(folderPath: String) -> (isSuccess: Bool, error: String) {
        if isFileOrFolderExists(filePath: folderPath) {
            return (true, "")
        }
        // 不存在的路径才会创建
        do {
            // withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
            try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            return (true, "")
        } catch _ {
            return (false, "创建失败")
        }
    }
    
    // MARK: 创建文件
    /// 创建文件
    /// - Parameter filePath: 文件路径
    /// - Returns: 返回创建的结果 和 路径
    @discardableResult
    static func createFile(filePath: String) -> (isSuccess: Bool, error: String) {
        guard isFileOrFolderExists(filePath: filePath) else {
            // 不存在的文件路径才会创建
            // withIntermediateDirectories 为 ture 表示路径中间如果有不存在的文件夹都会创建
            let createSuccess = FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            return (createSuccess, "")
        }
        return (true, "")
    }
    
    // MARK: 2.4、删除文件
    /// 删除文件
    /// - Parameter filePath: 文件路径
    @discardableResult
    static func removefile(filePath: String) -> (isSuccess: Bool, error: String) {
        guard isFileOrFolderExists(filePath: filePath) else {
            // 不存在的文件路径就不需要要移除
            return (true, "")
        }
        // 移除文件
        do {
            try FileManager.default.removeItem(atPath: filePath)
            return (true, "")
        } catch _ {
            return (false, "移除文件失败")
        }
    }
    
    // MARK: 判断 (文件夹/文件) 是否存在
    static func isFileOrFolderExists(filePath: String) -> Bool {
        let exist = FileManager.default.fileExists(atPath: filePath)
        // 查看文件夹是否存在，如果存在就直接读取，不存在就直接反空
        guard exist else {
            return false
        }
        return true
    }
}
