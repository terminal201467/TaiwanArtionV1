//
//  KeychainManager.swift
//  TaiwanArtion
//
//  Created by Claude Code on 2025-11-27.
//

import Foundation
import Security

/// Keychain 管理器 - 用於安全儲存敏感資料
class KeychainManager {

    static let shared = KeychainManager()

    private init() {}

    // MARK: - Public Methods

    /// 儲存字串到 Keychain
    /// - Parameters:
    ///   - key: 儲存的鍵值
    ///   - value: 要儲存的字串
    /// - Returns: 是否儲存成功
    @discardableResult
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }

        return save(key: key, data: data)
    }

    /// 儲存 Data 到 Keychain
    /// - Parameters:
    ///   - key: 儲存的鍵值
    ///   - data: 要儲存的資料
    /// - Returns: 是否儲存成功
    @discardableResult
    func save(key: String, data: Data) -> Bool {
        // 先刪除現有的項目（如果存在）
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        return status == errSecSuccess
    }

    /// 從 Keychain 讀取字串
    /// - Parameter key: 要讀取的鍵值
    /// - Returns: 讀取到的字串，如果不存在則返回 nil
    func get(key: String) -> String? {
        guard let data = getData(key: key),
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    /// 從 Keychain 讀取 Data
    /// - Parameter key: 要讀取的鍵值
    /// - Returns: 讀取到的資料，如果不存在則返回 nil
    func getData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }

        return data
    }

    /// 從 Keychain 刪除項目
    /// - Parameter key: 要刪除的鍵值
    /// - Returns: 是否刪除成功
    @discardableResult
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// 清除所有儲存的項目
    /// - Returns: 是否清除成功
    @discardableResult
    func clear() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// 檢查 Keychain 中是否存在某個鍵值
    /// - Parameter key: 要檢查的鍵值
    /// - Returns: 是否存在
    func contains(key: String) -> Bool {
        return getData(key: key) != nil
    }
}

// MARK: - Keychain Keys

extension KeychainManager {
    /// Keychain 儲存鍵值常數
    enum Keys {
        static let authToken = "com.taiwanartion.authToken"
        static let refreshToken = "com.taiwanartion.refreshToken"
        static let userID = "com.taiwanartion.userID"
        static let firebaseToken = "com.taiwanartion.firebaseToken"
    }
}
