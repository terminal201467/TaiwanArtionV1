//
//  UserDefaultInterface.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/16.
//

import Foundation

class UserDefaultInterface {

    static let shared = UserDefaultInterface()

    private let userDefaults = UserDefaults.standard
    private let keychain = KeychainManager.shared

    // MARK: - Keychain Keys
    private enum SecureKeys {
        static let email = "com.taiwanartion.user.email"
        static let phoneNumber = "com.taiwanartion.user.phoneNumber"
        static let documentID = "com.taiwanartion.user.documentID"
        static let isLoggedIn = "com.taiwanartion.user.isLoggedIn"
        static let headImage = "com.taiwanartion.user.headImage"
    }

    // MARK: - Legacy UserDefaults Keys (用於遷移)
    private enum LegacyKeys {
        static let email = "email"
        static let phoneNumber = "phoneNumber"
        static let documentID = "documentID"
        static let isLoggedIn = "isLoggedIn"
        static let headImage = "headImage"
        static let migrated = "keychainMigrationCompleted"
    }

    private init() {
        migrateToKeychainIfNeeded()
    }

    // MARK: - 資料遷移
    private func migrateToKeychainIfNeeded() {
        guard !userDefaults.bool(forKey: LegacyKeys.migrated) else { return }

        if let email = userDefaults.string(forKey: LegacyKeys.email) {
            keychain.save(key: SecureKeys.email, value: email)
            userDefaults.removeObject(forKey: LegacyKeys.email)
        }

        if let phone = userDefaults.string(forKey: LegacyKeys.phoneNumber) {
            keychain.save(key: SecureKeys.phoneNumber, value: phone)
            userDefaults.removeObject(forKey: LegacyKeys.phoneNumber)
        }

        if let docID = userDefaults.string(forKey: LegacyKeys.documentID) {
            keychain.save(key: SecureKeys.documentID, value: docID)
            userDefaults.removeObject(forKey: LegacyKeys.documentID)
        }

        if let headImg = userDefaults.string(forKey: LegacyKeys.headImage) {
            keychain.save(key: SecureKeys.headImage, value: headImg)
            userDefaults.removeObject(forKey: LegacyKeys.headImage)
        }

        if userDefaults.object(forKey: LegacyKeys.isLoggedIn) != nil {
            let isLoggedIn = userDefaults.bool(forKey: LegacyKeys.isLoggedIn)
            keychain.save(key: SecureKeys.isLoggedIn, value: isLoggedIn ? "1" : "0")
            userDefaults.removeObject(forKey: LegacyKeys.isLoggedIn)
        }

        userDefaults.set(true, forKey: LegacyKeys.migrated)
        userDefaults.synchronize()
        AppLogger.info("敏感資料已從 UserDefaults 遷移至 Keychain", category: .general)
    }

    // MARK: - 非敏感資料 (UserDefaults)

    func setUsername(_ username: String) {
        userDefaults.set(username, forKey: "username")
        userDefaults.synchronize()
    }

    func getUsername() -> String? {
        return userDefaults.string(forKey: "username")
    }

    func setBirth(_ date: String) {
        userDefaults.set(date, forKey: "birth")
        userDefaults.synchronize()
    }

    func getBirth() -> String? {
        return userDefaults.string(forKey: "birth")
    }

    func setGender(_ gender: String) {
        userDefaults.set(gender, forKey: "gender")
        userDefaults.synchronize()
    }

    func getGender() -> String? {
        return  userDefaults.string(forKey: "gender")
    }

    func setStoreHabby(habbys: [String]) {
        userDefaults.set(habbys, forKey: "habbys")
        userDefaults.synchronize()
    }

    func getStoreHabby() -> [String]? {
        return userDefaults.array(forKey: "habbys") as? [String]
    }

    func setStoreSearchHistory(searchHistory: [String]) {
        userDefaults.set(searchHistory, forKey: "searchHistory")
        userDefaults.synchronize()
    }

    func getStoreSearchHistory() -> [String]? {
        return userDefaults.array(forKey: "searchHistory") as? [String]
    }

    func setStoreNewsSearchHistory(newsHistory: [String]) {
        userDefaults.set(newsHistory, forKey: "newsHistory")
        userDefaults.synchronize()
    }

    func getStoreNewsSearchHistory() -> [String]? {
        return userDefaults.array(forKey: "newsHistory") as? [String]
    }

    // MARK: - 敏感資料 (Keychain)

    func setPhoneNumber(number: String) {
        keychain.save(key: SecureKeys.phoneNumber, value: number)
    }

    func getPhoneNumber() -> String? {
        return keychain.get(key: SecureKeys.phoneNumber)
    }

    func setEmail(_ email: String) {
        keychain.save(key: SecureKeys.email, value: email)
    }

    func getEmail() -> String? {
        return keychain.get(key: SecureKeys.email)
    }

    func setHeadImage(_ image: String) {
        keychain.save(key: SecureKeys.headImage, value: image)
    }

    func getHeadImage() -> String? {
        return keychain.get(key: SecureKeys.headImage)
    }

    func setDocumentID(identifier: String) {
        keychain.save(key: SecureKeys.documentID, value: identifier)
    }

    func getDocumentID() -> String? {
        return keychain.get(key: SecureKeys.documentID)
    }

    func setIsLoggedIn(_ isLoggedIn: Bool) {
        keychain.save(key: SecureKeys.isLoggedIn, value: isLoggedIn ? "1" : "0")
    }

    func getIsLoggedIn() -> Bool {
        return keychain.get(key: SecureKeys.isLoggedIn) == "1"
    }

    // MARK: - 清除資料

    /// 清除所有 Keychain 中的敏感資料（登出時使用）
    func clearSensitiveData() {
        keychain.delete(key: SecureKeys.email)
        keychain.delete(key: SecureKeys.phoneNumber)
        keychain.delete(key: SecureKeys.documentID)
        keychain.delete(key: SecureKeys.isLoggedIn)
        keychain.delete(key: SecureKeys.headImage)
        keychain.delete(key: KeychainManager.Keys.authToken)
        keychain.delete(key: KeychainManager.Keys.refreshToken)
        keychain.delete(key: KeychainManager.Keys.firebaseToken)
    }

    /// 清除所有用戶資料（Keychain + UserDefaults）
    func clearAllData() {
        clearSensitiveData()
        userDefaults.removeObject(forKey: "username")
        userDefaults.removeObject(forKey: "birth")
        userDefaults.removeObject(forKey: "gender")
        userDefaults.removeObject(forKey: "habbys")
        userDefaults.removeObject(forKey: "searchHistory")
        userDefaults.removeObject(forKey: "newsHistory")
        userDefaults.synchronize()
    }
}
