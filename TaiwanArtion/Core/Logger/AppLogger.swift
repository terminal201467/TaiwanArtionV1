//
//  AppLogger.swift
//  TaiwanArtion
//
//  Created by Claude Code on 2025-11-27.
//

import Foundation
import os.log

/// 應用程式統一日誌系統
/// 用於取代所有 print() 語句，提供結構化的日誌記錄
class AppLogger {

    // MARK: - Singleton

    static let shared = AppLogger()

    private init() {}

    // MARK: - Log Subsystems

    private let subsystem = Bundle.main.bundleIdentifier ?? "com.taiwanartion"

    // 日誌分類
    enum Category: String {
        case general = "General"
        case network = "Network"
        case firebase = "Firebase"
        case auth = "Authentication"
        case ui = "UI"
        case viewModel = "ViewModel"
        case database = "Database"
        case map = "Map"
        case payment = "Payment"
        case navigation = "Navigation"
    }

    // MARK: - Log Levels

    /// Debug - 除錯資訊（只在 Debug 建構顯示）
    static func debug(
        _ message: String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        let log = OSLog(subsystem: shared.subsystem, category: category.rawValue)
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(fileName):\(line)] \(function) - \(message)"
        os_log(.debug, log: log, "%{public}@", formattedMessage)
        #endif
    }

    /// Info - 一般資訊
    static func info(
        _ message: String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let log = OSLog(subsystem: shared.subsystem, category: category.rawValue)
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(fileName):\(line)] \(function) - \(message)"
        os_log(.info, log: log, "%{public}@", formattedMessage)
    }

    /// Warning - 警告訊息
    static func warning(
        _ message: String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let log = OSLog(subsystem: shared.subsystem, category: category.rawValue)
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "⚠️ [\(fileName):\(line)] \(function) - \(message)"
        os_log(.default, log: log, "%{public}@", formattedMessage)
    }

    /// Error - 錯誤訊息
    static func error(
        _ message: String,
        category: Category = .general,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let log = OSLog(subsystem: shared.subsystem, category: category.rawValue)
        let fileName = (file as NSString).lastPathComponent

        var formattedMessage = "❌ [\(fileName):\(line)] \(function) - \(message)"
        if let error = error {
            formattedMessage += "\nError: \(error.localizedDescription)"
        }

        os_log(.error, log: log, "%{public}@", formattedMessage)
    }

    /// Fault - 嚴重錯誤（系統級錯誤）
    static func fault(
        _ message: String,
        category: Category = .general,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let log = OSLog(subsystem: shared.subsystem, category: category.rawValue)
        let fileName = (file as NSString).lastPathComponent

        var formattedMessage = "🔥 [\(fileName):\(line)] \(function) - \(message)"
        if let error = error {
            formattedMessage += "\nError: \(error.localizedDescription)"
        }

        os_log(.fault, log: log, "%{public}@", formattedMessage)
    }

    // MARK: - Specialized Logging

    /// 記錄網路請求
    static func logNetworkRequest(
        url: String,
        method: String,
        headers: [String: String]? = nil
    ) {
        #if DEBUG
        var message = "🌐 Network Request\nURL: \(url)\nMethod: \(method)"
        if let headers = headers {
            message += "\nHeaders: \(headers)"
        }
        debug(message, category: .network)
        #endif
    }

    /// 記錄網路回應
    static func logNetworkResponse(
        url: String,
        statusCode: Int,
        data: Data? = nil
    ) {
        #if DEBUG
        var message = "📥 Network Response\nURL: \(url)\nStatus: \(statusCode)"
        if let data = data, let jsonString = String(data: data, encoding: .utf8) {
            message += "\nData: \(jsonString.prefix(500))..."  // 限制長度
        }
        debug(message, category: .network)
        #endif
    }

    /// 記錄 Firebase 操作
    static func logFirebaseOperation(
        operation: String,
        collection: String? = nil,
        documentID: String? = nil,
        success: Bool,
        error: Error? = nil
    ) {
        var message = "🔥 Firebase \(operation)"
        if let collection = collection {
            message += "\nCollection: \(collection)"
        }
        if let documentID = documentID {
            message += "\nDocument ID: \(documentID)"
        }
        message += "\nSuccess: \(success)"

        if success {
            info(message, category: .firebase)
        } else {
            self.error(message, category: .firebase, error: error)
        }
    }

    /// 記錄用戶認證
    static func logAuthentication(
        action: String,
        provider: String? = nil,
        userID: String? = nil,
        success: Bool,
        error: Error? = nil
    ) {
        var message = "🔐 Authentication: \(action)"
        if let provider = provider {
            message += "\nProvider: \(provider)"
        }
        if let userID = userID {
            message += "\nUser ID: \(userID)"
        }
        message += "\nSuccess: \(success)"

        if success {
            info(message, category: .auth)
        } else {
            self.error(message, category: .auth, error: error)
        }
    }

    /// 記錄頁面導航
    static func logNavigation(
        from: String? = nil,
        to: String
    ) {
        #if DEBUG
        var message = "📱 Navigation"
        if let from = from {
            message += "\nFrom: \(from)"
        }
        message += "\nTo: \(to)"
        debug(message, category: .navigation)
        #endif
    }

    /// 記錄 ViewModel 事件
    static func logViewModelEvent(
        viewModel: String,
        event: String,
        data: Any? = nil
    ) {
        #if DEBUG
        var message = "🎯 ViewModel Event\nViewModel: \(viewModel)\nEvent: \(event)"
        if let data = data {
            message += "\nData: \(data)"
        }
        debug(message, category: .viewModel)
        #endif
    }

    // MARK: - Performance Logging

    /// 測量代碼執行時間
    static func measureTime(
        _ label: String,
        category: Category = .general,
        block: () -> Void
    ) {
        #if DEBUG
        let startTime = CFAbsoluteTimeGetCurrent()
        block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        debug("⏱ \(label) - Time: \(String(format: "%.4f", timeElapsed))s", category: category)
        #else
        block()
        #endif
    }

    /// 測量異步代碼執行時間
    static func measureTimeAsync(
        _ label: String,
        category: Category = .general,
        block: (@escaping () -> Void) -> Void
    ) {
        #if DEBUG
        let startTime = CFAbsoluteTimeGetCurrent()
        block {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            debug("⏱ \(label) - Time: \(String(format: "%.4f", timeElapsed))s", category: category)
        }
        #else
        block {}
        #endif
    }

    // MARK: - Convenience Methods

    /// 記錄函數進入點（用於追蹤執行流程）
    static func enter(
        _ function: String = #function,
        category: Category = .general,
        file: String = #file,
        line: Int = #line
    ) {
        #if DEBUG
        debug("➡️ Enter", category: category, file: file, function: function, line: line)
        #endif
    }

    /// 記錄函數退出點（用於追蹤執行流程）
    static func exit(
        _ function: String = #function,
        category: Category = .general,
        file: String = #file,
        line: Int = #line
    ) {
        #if DEBUG
        debug("⬅️ Exit", category: category, file: file, function: function, line: line)
        #endif
    }
}

// MARK: - String Extension for Truncation

extension String {
    func truncate(length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }
}
