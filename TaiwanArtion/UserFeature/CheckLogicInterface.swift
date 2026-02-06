//
//  CheckLogicInterface.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/17.
//

import Foundation

/// 驗證邏輯介面，用於帳號、密碼、信箱、手機號碼等驗證
class CheckLogicInterface {

    // MARK: - 帳號檢查

    /// 帳號輸入檢查：4-21碼小寫英文.數字
    func checkAccount(_ account: String) -> Bool {
        let accountRegex = "^[a-z0-9]{4,21}$"
        let accountPredicate = NSPredicate(format: "SELF MATCHES %@", accountRegex)
        return accountPredicate.evaluate(with: account)
    }

    // MARK: - 密碼檢查

    /// 密碼輸入檢查：6-18位數密碼，請區分大小寫
    func checkPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])[a-zA-Z0-9]{6,18}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }

    /// 密碼提示檢查：回傳符合的條件列表
    func checkPasswordHint(_ password: String) -> [String] {
        var hints: [String] = []

        let uppercaseRegex = ".*[A-Z]+.*"
        let lowercaseRegex = ".*[a-z]+.*"
        let alphanumericRegex = "^[a-zA-Z0-9]+$"
        let specialCharactersRegex = "^[a-zA-Z0-9\\p{P}]+$"

        // 1. 至少一個大寫字母
        if password.range(of: uppercaseRegex, options: .regularExpression) != nil {
            hints.append("包含至少一個大寫字母")
        }

        // 2. 至少一個小寫字母
        if password.range(of: lowercaseRegex, options: .regularExpression) != nil {
            hints.append("包含至少一個小寫字母")
        }

        // 3. 8-16位英、數字
        if password.count >= 8 && password.count <= 16 {
            if password.range(of: alphanumericRegex, options: .regularExpression) != nil {
                hints.append("長度在8-16位且僅包含英文和數字")
            }
        }

        // 4. 僅能使用英文.數字或特殊標點符號
        if password.range(of: specialCharactersRegex, options: .regularExpression) != nil {
            hints.append("僅使用英文、數字或特殊標點符號")
        }

        return hints
    }

    /// 密碼強度檢查
    func checkPasswordStrenght(_ password: String) -> String {
        let verifiedCheckCondition = checkPasswordHint(password).count
        switch verifiedCheckCondition {
        case ..<1: return "無"
        case 1: return "弱"
        case 2: return "中"
        case 3: return "強"
        case 4: return "強"
        default: return "無"
        }
    }

    // MARK: - 驗證碼檢查

    /// 驗證碼檢查
    func checkVerifyCode(_ code: String) -> Bool {
        // TODO: 從 UserDefault 或 Keychain 取出驗證碼比對
        return false
    }

    // MARK: - 電子郵件檢查

    /// 電子郵件檢查：回傳錯誤訊息列表
    func checkEmail(_ email: String) -> [String] {
        var errors: [String] = []

        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        if !emailPredicate.evaluate(with: email) {
            errors.append("電子郵件格式不正確")
        }

        let validDomains = [".com", ".tw", ".com.tw"]
        var hasValidDomain = false
        for domain in validDomains {
            if email.hasSuffix(domain) {
                hasValidDomain = true
                break
            }
        }
        if !hasValidDomain {
            errors.append("無效的郵件域名")
        }

        if !email.contains("@") {
            errors.append("缺乏 @ 符號")
        }

        if email.components(separatedBy: "@").count != 2 {
            errors.append("帳號格式不正確")
        }

        return errors
    }

    // MARK: - 手機號碼檢查

    /// 手機號碼檢查：回傳錯誤訊息列表
    func checkPhoneNumber(_ phoneNumber: String) -> [String] {
        var errors: [String] = []

        let phoneNumberRegex = "^09[0-9]{8}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)

        if !phoneNumberPredicate.evaluate(with: phoneNumber) {
            errors.append("手機號碼格式不正確")
        }

        return errors
    }

    // MARK: - 國際電話號碼檢查

    // TODO: 實作含有其他國籍碼的電話號碼檢查
}
