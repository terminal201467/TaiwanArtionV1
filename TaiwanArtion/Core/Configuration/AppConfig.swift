//
//  AppConfig.swift
//  TaiwanArtion
//
//  Created by Claude Code on 2025-11-27.
//

import Foundation

/// 應用程式配置管理器
/// 負責管理所有環境變數和敏感配置
struct AppConfig {

    // MARK: - Environment

    /// 當前運行環境
    static var currentEnvironment: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    /// 環境類型
    enum Environment {
        case development
        case staging
        case production

        var name: String {
            switch self {
            case .development: return "Development"
            case .staging: return "Staging"
            case .production: return "Production"
            }
        }
    }

    // MARK: - Firebase Configuration

    /// Google API Key (從 Info.plist 讀取)
    static var googleAPIKey: String {
        return getConfigValue(for: "GOOGLE_API_KEY")
    }

    /// Firebase 配置檔名稱
    static var firebaseConfigFileName: String {
        switch currentEnvironment {
        case .development:
            return "GoogleService-Info-Dev"
        case .staging:
            return "GoogleService-Info-Staging"
        case .production:
            return "GoogleService-Info"
        }
    }

    // MARK: - Third-Party Login

    /// Facebook App ID
    static var facebookAppID: String {
        return getConfigValue(for: "FACEBOOK_APP_ID")
    }

    /// Facebook Client Token
    static var facebookClientToken: String {
        return getConfigValue(for: "FACEBOOK_CLIENT_TOKEN")
    }

    /// Google Client ID
    static var googleClientID: String {
        return getConfigValue(for: "GOOGLE_CLIENT_ID")
    }

    // MARK: - App Information

    /// App 版本號
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    /// App Build 號碼
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    /// Bundle Identifier
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "Unknown"
    }

    // MARK: - API Configuration

    /// API Base URL (如果有後端 API)
    static var apiBaseURL: String {
        switch currentEnvironment {
        case .development:
            return "https://dev-api.taiwanartion.com"
        case .staging:
            return "https://staging-api.taiwanartion.com"
        case .production:
            return "https://api.taiwanartion.com"
        }
    }

    /// API 逾時時間（秒）
    static let apiTimeout: TimeInterval = 30

    // MARK: - Feature Flags

    /// 是否啟用除錯模式
    static var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// 是否啟用日誌
    static var isLoggingEnabled: Bool {
        return isDebugMode
    }

    /// 是否啟用分析
    static var isAnalyticsEnabled: Bool {
        return currentEnvironment == .production
    }

    // MARK: - Private Methods

    /// 從 Info.plist 讀取配置值
    /// - Parameter key: 配置鍵值
    /// - Returns: 配置值
    private static func getConfigValue(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty,
              !value.hasPrefix("$(") else {  // 檢查是否為未替換的環境變數
            #if DEBUG
            print("⚠️ Warning: \(key) not found or not configured in Info.plist")
            return "NOT_CONFIGURED_\(key)"
            #else
            fatalError("❌ Error: \(key) not found in Info.plist. Please configure it in Xcode Build Settings.")
            #endif
        }

        return value
    }

    // MARK: - Validation

    /// 驗證所有必要的配置是否已設定
    /// - Returns: 是否所有配置都已正確設定
    static func validateConfiguration() -> Bool {
        let requiredKeys = [
            "GOOGLE_API_KEY",
            "FACEBOOK_APP_ID",
            "FACEBOOK_CLIENT_TOKEN",
            "GOOGLE_CLIENT_ID"
        ]

        var isValid = true

        for key in requiredKeys {
            let value = getConfigValue(for: key)
            if value.hasPrefix("NOT_CONFIGURED_") {
                print("❌ Missing configuration: \(key)")
                isValid = false
            }
        }

        if isValid {
            print("✅ All configurations are valid")
        }

        return isValid
    }

    /// 打印當前配置（除錯用，不會顯示敏感資訊）
    static func printConfiguration() {
        guard isDebugMode else { return }

        print("""

        ═══════════════════════════════════
        📱 TaiwanArtion Configuration
        ═══════════════════════════════════
        Environment: \(currentEnvironment.name)
        App Version: \(appVersion) (\(buildNumber))
        Bundle ID: \(bundleIdentifier)
        API Base URL: \(apiBaseURL)
        Debug Mode: \(isDebugMode)
        Logging: \(isLoggingEnabled)
        Analytics: \(isAnalyticsEnabled)
        ═══════════════════════════════════

        """)
    }
}
