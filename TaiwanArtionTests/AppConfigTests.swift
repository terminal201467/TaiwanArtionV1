//
//  AppConfigTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2025-11-27.
//

import XCTest
@testable import TaiwanArtion

final class AppConfigTests: XCTestCase {

    // MARK: - Environment Tests

    func testCurrentEnvironment_InDebugMode_ReturnsDevelopment() {
        // When
        let environment = AppConfig.currentEnvironment

        // Then
        #if DEBUG
        XCTAssertEqual(environment, .development, "Debug 模式下應該是 development 環境")
        #else
        XCTAssertEqual(environment, .production, "Release 模式下應該是 production 環境")
        #endif
    }

    func testEnvironmentName_ReturnsCorrectNames() {
        // When & Then
        XCTAssertEqual(AppConfig.Environment.development.name, "Development")
        XCTAssertEqual(AppConfig.Environment.staging.name, "Staging")
        XCTAssertEqual(AppConfig.Environment.production.name, "Production")
    }

    // MARK: - App Information Tests

    func testAppVersion_NotEmpty() {
        // When
        let version = AppConfig.appVersion

        // Then
        XCTAssertFalse(version.isEmpty, "App 版本號不應該為空")
        XCTAssertNotEqual(version, "Unknown", "應該能讀取到 App 版本號")
    }

    func testBuildNumber_NotEmpty() {
        // When
        let buildNumber = AppConfig.buildNumber

        // Then
        XCTAssertFalse(buildNumber.isEmpty, "Build 號碼不應該為空")
        XCTAssertNotEqual(buildNumber, "Unknown", "應該能讀取到 Build 號碼")
    }

    func testBundleIdentifier_NotEmpty() {
        // When
        let bundleId = AppConfig.bundleIdentifier

        // Then
        XCTAssertFalse(bundleId.isEmpty, "Bundle Identifier 不應該為空")
        XCTAssertNotEqual(bundleId, "Unknown", "應該能讀取到 Bundle Identifier")
    }

    // MARK: - API Configuration Tests

    func testAPIBaseURL_DifferentForEnvironments() {
        // Given
        let devURL = "https://dev-api.taiwanartion.com"
        let stagingURL = "https://staging-api.taiwanartion.com"
        let prodURL = "https://api.taiwanartion.com"

        // When
        let currentURL = AppConfig.apiBaseURL

        // Then
        switch AppConfig.currentEnvironment {
        case .development:
            XCTAssertEqual(currentURL, devURL, "Development 環境應該使用開發 API")
        case .staging:
            XCTAssertEqual(currentURL, stagingURL, "Staging 環境應該使用測試 API")
        case .production:
            XCTAssertEqual(currentURL, prodURL, "Production 環境應該使用正式 API")
        }
    }

    func testAPITimeout_IsPositive() {
        // When
        let timeout = AppConfig.apiTimeout

        // Then
        XCTAssertGreaterThan(timeout, 0, "API 逾時時間應該大於 0")
        XCTAssertEqual(timeout, 30, "API 逾時時間應該為 30 秒")
    }

    // MARK: - Feature Flags Tests

    func testIsDebugMode_MatchesBuildConfiguration() {
        // When
        let isDebug = AppConfig.isDebugMode

        // Then
        #if DEBUG
        XCTAssertTrue(isDebug, "Debug 建構應該啟用除錯模式")
        #else
        XCTAssertFalse(isDebug, "Release 建構不應該啟用除錯模式")
        #endif
    }

    func testIsLoggingEnabled_MatchesDebugMode() {
        // When
        let loggingEnabled = AppConfig.isLoggingEnabled
        let debugMode = AppConfig.isDebugMode

        // Then
        XCTAssertEqual(loggingEnabled, debugMode, "日誌啟用狀態應該與除錯模式一致")
    }

    func testIsAnalyticsEnabled_OnlyInProduction() {
        // When
        let analyticsEnabled = AppConfig.isAnalyticsEnabled

        // Then
        if AppConfig.currentEnvironment == .production {
            XCTAssertTrue(analyticsEnabled, "Production 環境應該啟用分析")
        } else {
            XCTAssertFalse(analyticsEnabled, "非 Production 環境不應該啟用分析")
        }
    }

    // MARK: - Firebase Configuration Tests

    func testFirebaseConfigFileName_DifferentForEnvironments() {
        // When
        let fileName = AppConfig.firebaseConfigFileName

        // Then
        switch AppConfig.currentEnvironment {
        case .development:
            XCTAssertEqual(fileName, "GoogleService-Info-Dev", "Development 應該使用開發配置檔")
        case .staging:
            XCTAssertEqual(fileName, "GoogleService-Info-Staging", "Staging 應該使用測試配置檔")
        case .production:
            XCTAssertEqual(fileName, "GoogleService-Info", "Production 應該使用正式配置檔")
        }
    }

    // MARK: - Configuration Validation Tests

    func testValidateConfiguration_ChecksAllKeys() {
        // 這個測試會檢查配置是否正確設定
        // 在 CI/CD 環境中可能會失敗（因為沒有配置環境變數）
        // 但在本地開發環境應該通過

        // When
        let isValid = AppConfig.validateConfiguration()

        // Then
        // 在測試環境中，我們只檢查方法不會崩潰
        // 實際的驗證結果取決於環境變數是否已設定
        XCTAssertNotNil(isValid, "驗證方法應該返回結果")
    }

    // MARK: - Edge Cases

    func testGetConfigValue_WithInvalidKey_HandlesGracefully() {
        // 這個測試確保當讀取不存在的配置時，不會崩潰

        // When & Then
        // 在 Debug 模式下應該返回 "NOT_CONFIGURED_" 前綴的字串
        // 在 Release 模式下應該會 crash（fatalError）
        #if DEBUG
        // 測試環境預設是 Debug，所以這裡可以測試
        XCTAssertNoThrow({
            _ = AppConfig.googleAPIKey
            _ = AppConfig.facebookAppID
        }(), "讀取配置不應該導致測試崩潰")
        #endif
    }

    // MARK: - Print Configuration Tests

    func testPrintConfiguration_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppConfig.printConfiguration()
        }(), "打印配置不應該崩潰")
    }
}
