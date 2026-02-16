//
//  AuthRepository.swift
//  TaiwanArtion
//
//  Created by Refactor on 2026/2/13.
//

import Foundation
import UIKit

/// 認證錯誤類型
enum AuthError: LocalizedError {
    case googleSignInFailed(Error?)
    case facebookSignInFailed(Error?)
    case emailSignUpFailed(Error?)
    case emailSignInFailed(Error?)
    case phoneVerificationFailed(Error?)
    case verificationCodeInvalid(Error?)
    case emailVerificationFailed(Error?)
    case signOutFailed(Error?)
    case userNotFound
    case unknown(Error?)

    var errorDescription: String? {
        switch self {
        case .googleSignInFailed(let error):
            return "Google 登入失敗: \(error?.localizedDescription ?? "未知錯誤")"
        case .facebookSignInFailed(let error):
            return "Facebook 登入失敗: \(error?.localizedDescription ?? "未知錯誤")"
        case .emailSignUpFailed(let error):
            return "Email 註冊失敗: \(error?.localizedDescription ?? "未知錯誤")"
        case .emailSignInFailed(let error):
            return "Email 登入失敗: \(error?.localizedDescription ?? "未知錯誤")"
        case .phoneVerificationFailed(let error):
            return "手機驗證失敗: \(error?.localizedDescription ?? "未知錯誤")"
        case .verificationCodeInvalid(let error):
            return "驗證碼無效: \(error?.localizedDescription ?? "未知錯誤")"
        case .emailVerificationFailed(let error):
            return "Email 驗證失敗: \(error?.localizedDescription ?? "未知錯誤")"
        case .signOutFailed(let error):
            return "登出失敗: \(error?.localizedDescription ?? "未知錯誤")"
        case .userNotFound:
            return "找不到使用者"
        case .unknown(let error):
            return "未知錯誤: \(error?.localizedDescription ?? "發生未知錯誤")"
        }
    }
}

/// 認證結果
struct AuthResult {
    let user: User
    let isNewUser: Bool
    let provider: AuthProvider

    init(user: User, isNewUser: Bool = false, provider: AuthProvider) {
        self.user = user
        self.isNewUser = isNewUser
        self.provider = provider
    }
}

/// 認證提供者
enum AuthProvider: String {
    case google = "Google"
    case facebook = "Facebook"
    case email = "Email"
    case phone = "Phone"
    case unknown = "Unknown"
}

/// 認證 Repository 協議
/// 定義所有認證相關操作的介面
protocol AuthRepository {

    // MARK: - Social Sign In

    /// Google 登入
    /// - Parameters:
    ///   - controller: 用於顯示登入 UI 的 ViewController
    ///   - completion: 完成回調
    func signInWithGoogle(
        from controller: UIViewController,
        completion: @escaping (Result<AuthResult, AuthError>) -> Void
    )

    /// Facebook 登入
    /// - Parameters:
    ///   - controller: 用於顯示登入 UI 的 ViewController
    ///   - completion: 完成回調
    func signInWithFacebook(
        from controller: UIViewController,
        completion: @escaping (Result<AuthResult, AuthError>) -> Void
    )

    // MARK: - Email Authentication

    /// Email 註冊
    /// - Parameters:
    ///   - email: 電子郵件
    ///   - password: 密碼
    ///   - completion: 完成回調
    func signUpWithEmail(
        email: String,
        password: String,
        completion: @escaping (Result<AuthResult, AuthError>) -> Void
    )

    /// Email 登入
    /// - Parameters:
    ///   - email: 電子郵件
    ///   - password: 密碼
    ///   - completion: 完成回調
    func signInWithEmail(
        email: String,
        password: String,
        completion: @escaping (Result<AuthResult, AuthError>) -> Void
    )

    // MARK: - Phone Authentication

    /// 發送手機驗證碼
    /// - Parameters:
    ///   - phoneNumber: 手機號碼（含國碼）
    ///   - completion: 完成回調
    func sendPhoneVerificationCode(
        phoneNumber: String,
        completion: @escaping (Result<Void, AuthError>) -> Void
    )

    /// 驗證手機驗證碼
    /// - Parameters:
    ///   - code: 驗證碼
    ///   - completion: 完成回調
    func verifyPhoneCode(
        code: String,
        completion: @escaping (Result<AuthResult, AuthError>) -> Void
    )

    // MARK: - Email Verification

    /// 發送 Email 驗證信
    /// - Parameters:
    ///   - email: 電子郵件
    ///   - password: 密碼
    ///   - completion: 完成回調
    func sendEmailVerification(
        email: String,
        password: String,
        completion: @escaping (Result<Void, AuthError>) -> Void
    )

    /// 驗證 Email
    /// - Parameters:
    ///   - email: 電子郵件
    ///   - password: 密碼
    ///   - code: 驗證碼
    ///   - completion: 完成回調
    func verifyEmail(
        email: String,
        password: String,
        code: String,
        completion: @escaping (Result<Void, AuthError>) -> Void
    )

    // MARK: - Password Reset

    /// 發送密碼重設郵件
    /// - Parameters:
    ///   - email: 電子郵件
    ///   - completion: 完成回調
    func sendPasswordResetEmail(
        email: String,
        completion: @escaping (Result<Void, AuthError>) -> Void
    )

    // MARK: - Sign Out

    /// 登出
    /// - Parameter completion: 完成回調
    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void)

    // MARK: - Current User

    /// 取得當前登入的使用者
    var currentUser: User? { get }

    /// 是否已登入
    var isSignedIn: Bool { get }
}
