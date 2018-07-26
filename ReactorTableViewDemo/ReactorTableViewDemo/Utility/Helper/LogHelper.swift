//
//  LogHelper.swift
//  ifanr
//
//  Created by luhe liu on 17/7/13.
//  Copyright © 2017年 ifanr. All rights reserved.
//

import Foundation

/// 统一 Log 方法
///
/// - Parameters:
///   - message: Log 信息
///   - file: Log 发生时所在文件路径
///   - method: Log 发生时所在方法名
///   - line: Log 发生时所在代码行数
///   - options: Log 输出信息配置
public func debugLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line, options: [LogOptionsInfoItem]? = nil) {
    #if DEBUG
        guard LogHelper.shared.enable else {
            return
        }
        let logMessage = LogHelper.shared.getLogMessage(message: message, file: file, method: method, line: line, options: options)
        if var fileStreamer = LogHelper.shared.fileStreamer {
            Swift.print(logMessage, to: &fileStreamer)
        } else {
            Swift.print(logMessage)
        }
    #endif
}

/// Log 信息种类
///
/// - fileName: Log 代码所在文件名
/// - line: Log 代码所在行数
/// - method: Log 代码所在方法
/// - date: Log 发生时的时间
public enum LogOptionsInfoItem {
    case fileName
    case line
    case method
    case date
}

/// Log 管理器，单例统一管理项目的 Log
final class LogHelper {
    
    /// 单例对象
    static let shared = LogHelper()
    
    /// 私有属性
    fileprivate var fileStreamer: FileStreamer?
    fileprivate static let defaultOptions: [LogOptionsInfoItem] = [.fileName, .line, .method, .date]
    
    /// Log 文件名
    public fileprivate(set) var logFileName: String?
    
    /// 是否开启 Log 打印功能
    public var enable: Bool = true
    
    /// 全局配置 Log 打印包含的信息种类，默认打印全部种类信息
    public var globalOptions: [LogOptionsInfoItem] = LogHelper.defaultOptions
    
    /// 全局时间打印字符串格式化
    public lazy var globalDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        return dateFormatter
    }()
    
    /// 重定向 Log 到文件
    ///
    /// - Parameter path: 重定向的文件路径，为 nil 则使用默认 Log 文件路径
    public func redirectLogToFile(with path: String? = nil, directory: FileManager.SearchPathDirectory = .documentDirectory, domainMask: FileManager.SearchPathDomainMask = .userDomainMask) {
        var logFilePath: String = ""
        if let filePath = path {
            logFilePath = filePath
        } else {
            if let directoryPath = NSSearchPathForDirectoriesInDomains(directory, domainMask, true).first {
                var fileName: String = ""
                if let logFileName = logFileName {
                    fileName = logFileName
                } else {
                    fileName = "\(Int(Date().timeIntervalSince1970)).log"
                    logFileName = fileName
                }
                logFilePath = (directoryPath as NSString).appendingPathComponent("/\(fileName)")
            }
        }
        guard !logFilePath.isEmpty else {
            return
        }
        let streamer = FileStreamer(logPath: logFilePath)
        if streamer.logPath != nil {
            fileStreamer = streamer
        }
    }
    
    /// 重定向 Log 到控制台
    public func redirectLogToConsole() {
        fileStreamer = nil
    }
    
    /// 处理 Log 输出信息方法
    ///
    /// - Parameters:
    ///   - message: Log 信息
    ///   - file: Log 发生时所在文件路径
    ///   - method: Log 发生时所在方法名
    ///   - line: Log 发生时所在代码行数
    ///   - options: Log 输出信息配置，当该值为 nil 时，使用全局 options 配置，当该值不为 nil，使用传入的临时 options 配置
    /// 默认格式：$(fileName)[$(line)], $(method), $(date): $(message)
    public func getLogMessage<T>(message: T, file: String, method: String, line: Int, options: [LogOptionsInfoItem]? = nil) -> String {
        let currentOptions = options ?? globalOptions
        var logMessage: String = ""
        if currentOptions.contains(.fileName) {
            var fileName = ""
            if let name = file.components(separatedBy: "/").last {
                fileName = name
            }
            logMessage += fileName
        }
        if currentOptions.contains(.line) {
            logMessage += "[\(line)]"
        }
        if currentOptions.contains(.method) {
            if !logMessage.isEmpty {
                logMessage += ", "
            }
            logMessage += "\(method)"
        }
        if currentOptions.contains(.date) {
            if !logMessage.isEmpty {
                logMessage += ", "
            }
            let date = Date()
            let dateString = globalDateFormatter.string(from: date)
            logMessage += dateString
        }
        if !logMessage.isEmpty {
            logMessage += ": "
        }
        logMessage += "\(message)"
        return logMessage
    }
    
    /// 删除 Log 文件
    public func removeLogFile() {
        if let streamer = fileStreamer {
            streamer.removeFile()
        }
    }
}

/// 输出文本文件流对象
open class FileStreamer: TextOutputStream {
    open var fileHandle: FileHandle?
    open var logPath: String?
    
    public init(logPath: String? = nil) {
        guard let logFilePath = logPath else {
            return
        }
        self.logPath = logFilePath
        setupFileHandle(with: logFilePath)
    }
    
    deinit {
        fileHandle?.closeFile()
    }
    
    open func setupFileHandle(with path: String?) {
        guard let path = path else {
            return
        }
        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        if self.fileHandle == nil {
            let fileHandle = FileHandle(forWritingAtPath: path)
            self.fileHandle = fileHandle
        }
    }
    
    ///  实现协议 TextOutputStream 的 Log 写入方法，该方法不需要自己调用
    ///
    /// - Parameter string: 写入的字符串
    open func write(_ string: String) {
        setupFileHandle(with: logPath)
        fileHandle?.seekToEndOfFile()
        if let writeData = string.data(using: .utf8) {
            fileHandle?.write(writeData)
        }
    }
    
    /// 删除 Log 文件
    open func removeFile() {
        guard let logFilePath = logPath else {
            return
        }
        do {
            if FileManager.default.fileExists(atPath: logFilePath) {
                try FileManager.default.removeItem(atPath: logFilePath)
            }
        } catch {
            debugLog("remove Log File error: \(error)")
        }
    }
}
