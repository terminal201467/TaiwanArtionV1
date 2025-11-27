//
//  AppConfig.swift
//  TaiwanArtion
//
//  Created by Claude Code on 2025/11/27.
//

import Foundation

/// 應用程式配置管理
/// 從 Info.plist 讀取環境變數，避免在代碼中硬編碼敏感資訊
struct AppConfig {

    // MARK: - Firebase Configuration

    /// Google API Key (從 Firebase 配置)
    static var googleAPIKey: String {
        return getConfigValue(for: "GOOGLE_API_KEY")
    }

    // MARK: - Facebook Configuration

    /// Facebook App ID
    static var facebookAppID: String {
        return getConfigValue(for: "FACEBOOK_APP_ID")
    }

    /// Facebook Client Token
    static var facebookClientToken: String {
        return getConfigValue(for: "FACEBOOK_CLIENT_TOKEN")
    }

    // MARK: - Environment

    /// 當前環境（Development, Staging, Production）
    static var environment: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    enum Environment: String {
        case development = "Development"
        case staging = "Staging"
        case production = "Production"

        var isProduction: Bool {
            return self == .production
        }
    }

    // MARK: - Helper Methods

    /// 從 Info.plist 讀取配置值
    /// - Parameter key: 配置鍵名
    /// - Returns: 配置值
    private static func getConfigValue(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty,
              !value.hasPrefix("$(") else {
            #if DEBUG
            print("⚠️ Warning: \(key) not found or not configured in Info.plist")
            #endif
            return ""
        }
        return value
    }

    /// 驗證所有必要的配置是否已設定
    static func validateConfiguration() -> Bool {
        let requiredKeys = [
            "GOOGLE_API_KEY",
            "FACEBOOK_APP_ID",
            "FACEBOOK_CLIENT_TOKEN"
        ]

        var isValid = true
        for key in requiredKeys {
            if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
               !value.isEmpty,
               !value.hasPrefix("$(") {
                continue
            } else {
                print("❌ Missing configuration: \(key)")
                isValid = false
            }
        }

        return isValid
    }
}
