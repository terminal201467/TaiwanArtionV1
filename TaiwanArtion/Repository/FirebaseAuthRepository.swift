//
//  FirebaseAuthRepository.swift
//  TaiwanArtion
//
//  Created by Refactor on 2026/2/13.
//

import Foundation
import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth
import FirebaseCore

/// Firebase 認證 Repository 實作
final class FirebaseAuthRepository: AuthRepository {

    // MARK: - Properties

    private let firebaseAuth: FirebaseAuth

    // MARK: - Initialization

    init(firebaseAuth: FirebaseAuth = .shared) {
        self.firebaseAuth = firebaseAuth
    }

    // MARK: - Current User

    var currentUser: User? {
        guard let firebaseUser = Auth.auth().currentUser else {
            return nil
        }
        return User(
            birth: "未知的生日",
            email: firebaseUser.email ?? "未知的Email",
            gender: "未知的性別",
            headImage: firebaseUser.photoURL?.absoluteString ?? "未知的大頭貼",
            phone: firebaseUser.phoneNumber ?? "未知的電話",
            name: firebaseUser.displayName ?? "未知的名字"
        )
    }

    var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    // MARK: - Social Sign In

    func signInWithGoogle(
        from controller: UIViewController,
        completion: @escaping (Result<AuthResult, AuthError>) -> Void
    ) {
        AppLogger.info("開始 Google 登入", category: .auth)

        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { [weak self] authResult, error in
            if let error = error {
                AppLogger.error("Google 登入失敗", category: .auth, error: error)
                completion(.failure(.googleSignInFailed(error)))
                return
            }

            guard let result = authResult else {
                AppLogger.error("Google 登入結果為空", category: .auth)
                completion(.failure(.googleSignInFailed(nil)))
                return
            }

            AppLogger.logAuthentication(
                action: "Google Sign In",
                provider: "Google",
                success: true
            )

            let user = User(
                birth: "未知的生日",
                email: result.user.profile?.email ?? "未知的Email",
                gender: "未知的性別",
                headImage: result.user.profile?.imageURL(withDimension: 200)?.absoluteString ?? "未知的大頭貼",
                phone: "未知的電話",
                name: result.user.profile?.name ?? "未知的名字"
            )

            let authResultModel = AuthResult(
                user: user,
                isNewUser: false,
                provider: .google
            )

            completion(.success(authResultModel))
        }
    }

    func signInWithFacebook(
        from controller: UIViewController,
        completion: @escaping (Result<AuthResult, AuthError>) -> Void
    ) {
        AppLogger.info("開始 Facebook 登入", category: .auth)

        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: controller) { result, error in
            if let error = error {
                AppLogger.error("Facebook 登入失敗", category: .auth, error: error)
                completion(.failure(.facebookSignInFailed(error)))
                return
            }

            guard let result = result, !result.isCancelled else {
                AppLogger.warning("Facebook 登入被取消", category: .auth)
                completion(.failure(.facebookSignInFailed(nil)))
                return
            }

            guard AccessToken.current != nil else {
                AppLogger.error("Facebook Access Token 為空", category: .auth)
                completion(.failure(.facebookSignInFailed(nil)))
                return
            }

            Profile.loadCurrentProfile { profile, error in
                if let error = error {
                    AppLogger.error("載入 Facebook Profile 失敗", category: .auth, error: error)
                    completion(.failure(.facebookSignInFailed(error)))
                    return
                }

                guard let profile = profile else {
                    AppLogger.error("Facebook Profile 為空", category: .auth)
                    completion(.failure(.facebookSignInFailed(nil)))
                    return
                }

                AppLogger.logAuthentication(
                    action: "Facebook Sign In",
                    provider: "Facebook",
                    success: true
                )

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"

                let user = User(
                    birth: profile.birthday.map { formatter.string(from: $0) } ?? "未知的生日",
                    email: profile.email ?? "未知的Email",
                    gender: profile.gender ?? "未知的性別",
                    headImage: profile.imageURL?.absoluteString ?? "未知的大頭貼",
                    phone: "未知的電話",
                    name: profile.name ?? "未知的姓名"
                )

                let authResultModel = AuthResult(
                    user: user,
                    isNewUser: false,
                    provider: .facebook
                )

                completion(.success(authResultModel))
            }
        }
    }

    // MARK: - Email Authentication

    func signUpWithEmail(
        email: String,
        password: String,
        completion: @escaping (Result<AuthResult, AuthError>) -> Void
    ) {
        AppLogger.info("開始 Email 註冊", category: .auth)

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                AppLogger.error("Email 註冊失敗", category: .auth, error: error)
                completion(.failure(.emailSignUpFailed(error)))
                return
            }

            guard let result = authResult else {
                AppLogger.error("Email 註冊結果為空", category: .auth)
                completion(.failure(.emailSignUpFailed(nil)))
                return
            }

            AppLogger.logAuthentication(
                action: "Email Sign Up",
                provider: "Email",
                success: true
            )

            let user = User(
                birth: "未知的生日",
                email: result.user.email ?? "未知的Email",
                gender: "未知的性別",
                headImage: result.user.photoURL?.absoluteString ?? "未知的大頭貼",
                phone: "未知的電話",
                name: result.user.displayName ?? "未知的名字"
            )

            let authResultModel = AuthResult(
                user: user,
                isNewUser: true,
                provider: .email
            )

            completion(.success(authResultModel))
        }
    }

    func signInWithEmail(
        email: String,
        password: String,
        completion: @escaping (Result<AuthResult, AuthError>) -> Void
    ) {
        AppLogger.info("開始 Email 登入", category: .auth)

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                AppLogger.error("Email 登入失敗", category: .auth, error: error)
                completion(.failure(.emailSignInFailed(error)))
                return
            }

            guard let result = authResult else {
                AppLogger.error("Email 登入結果為空", category: .auth)
                completion(.failure(.emailSignInFailed(nil)))
                return
            }

            AppLogger.logAuthentication(
                action: "Email Sign In",
                provider: "Email",
                success: true
            )

            let user = User(
                birth: "未知的生日",
                email: result.user.email ?? "未知的Email",
                gender: "未知的性別",
                headImage: result.user.photoURL?.absoluteString ?? "未知的大頭貼",
                phone: "未知的電話",
                name: result.user.displayName ?? "未知的名字"
            )

            let authResultModel = AuthResult(
                user: user,
                isNewUser: false,
                provider: .email
            )

            completion(.success(authResultModel))
        }
    }

    // MARK: - Phone Authentication

    func sendPhoneVerificationCode(
        phoneNumber: String,
        completion: @escaping (Result<Void, AuthError>) -> Void
    ) {
        AppLogger.info("發送手機驗證碼", category: .auth)

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                AppLogger.error("發送驗證碼失敗", category: .auth, error: error)
                completion(.failure(.phoneVerificationFailed(error)))
                return
            }

            guard let verificationID = verificationID else {
                AppLogger.error("驗證 ID 為空", category: .auth)
                completion(.failure(.phoneVerificationFailed(nil)))
                return
            }

            // 將 verificationID 安全儲存至 Keychain
            KeychainManager.shared.save(key: "com.taiwanartion.authVerificationID", value: verificationID)

            AppLogger.info("驗證碼已發送", category: .auth)
            completion(.success(()))
        }
    }

    func verifyPhoneCode(
        code: String,
        completion: @escaping (Result<AuthResult, AuthError>) -> Void
    ) {
        AppLogger.info("驗證手機驗證碼", category: .auth)

        guard let verificationID = KeychainManager.shared.get(key: "com.taiwanartion.authVerificationID") else {
            AppLogger.error("找不到驗證 ID", category: .auth)
            completion(.failure(.verificationCodeInvalid(nil)))
            return
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                AppLogger.error("驗證碼驗證失敗", category: .auth, error: error)
                completion(.failure(.verificationCodeInvalid(error)))
                return
            }

            guard let result = authResult else {
                AppLogger.error("驗證結果為空", category: .auth)
                completion(.failure(.verificationCodeInvalid(nil)))
                return
            }

            AppLogger.logAuthentication(
                action: "Phone Verification",
                provider: "Phone",
                success: true
            )

            let user = User(
                birth: "未知的生日",
                email: result.user.email ?? "未知的Email",
                gender: "未知的性別",
                headImage: result.user.photoURL?.absoluteString ?? "未知的大頭貼",
                phone: result.user.phoneNumber ?? "未知的電話",
                name: result.user.displayName ?? "未知的名字"
            )

            let authResultModel = AuthResult(
                user: user,
                isNewUser: result.additionalUserInfo?.isNewUser ?? false,
                provider: .phone
            )

            // 清除已使用的驗證 ID
            KeychainManager.shared.delete(key: "com.taiwanartion.authVerificationID")

            completion(.success(authResultModel))
        }
    }

    // MARK: - Email Verification

    func sendEmailVerification(
        email: String,
        password: String,
        completion: @escaping (Result<Void, AuthError>) -> Void
    ) {
        AppLogger.info("發送 Email 驗證信", category: .auth)

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                AppLogger.error("創建用戶失敗", category: .auth, error: error)
                completion(.failure(.emailVerificationFailed(error)))
                return
            }

            authResult?.user.sendEmailVerification { error in
                if let error = error {
                    AppLogger.error("發送驗證郵件失敗", category: .auth, error: error)
                    completion(.failure(.emailVerificationFailed(error)))
                    return
                }

                AppLogger.info("驗證郵件已發送", category: .auth)
                completion(.success(()))
            }
        }
    }

    func verifyEmail(
        email: String,
        password: String,
        code: String,
        completion: @escaping (Result<Void, AuthError>) -> Void
    ) {
        AppLogger.info("驗證 Email", category: .auth)

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        Auth.auth().currentUser?.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                AppLogger.error("重新認證失敗", category: .auth, error: error)
                completion(.failure(.emailVerificationFailed(error)))
                return
            }

            AppLogger.info("Email 驗證成功", category: .auth)
            completion(.success(()))
        }
    }

    // MARK: - Password Reset

    func sendPasswordResetEmail(
        email: String,
        completion: @escaping (Result<Void, AuthError>) -> Void
    ) {
        AppLogger.info("發送密碼重設郵件", category: .auth)

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                AppLogger.error("發送密碼重設郵件失敗", category: .auth, error: error)
                completion(.failure(.emailVerificationFailed(error)))
                return
            }

            AppLogger.info("密碼重設郵件已發送", category: .auth)
            completion(.success(()))
        }
    }

    // MARK: - Sign Out

    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        AppLogger.info("開始登出", category: .auth)

        do {
            // Google Sign Out
            GIDSignIn.sharedInstance.signOut()

            // Facebook Sign Out
            LoginManager().logOut()

            // Firebase Sign Out
            try Auth.auth().signOut()

            // 清除敏感資料
            UserDefaultInterface.shared.clearSensitiveData()

            AppLogger.info("登出成功", category: .auth)
            completion(.success(()))
        } catch {
            AppLogger.error("登出失敗", category: .auth, error: error)
            completion(.failure(.signOutFailed(error)))
        }
    }
}
