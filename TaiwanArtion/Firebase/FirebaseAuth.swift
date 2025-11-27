//
//  FirebaseAuth.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/6/15.
//

import Foundation
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth
import Firebase
import os.log

class FirebaseAuth {
    
    static let shared = FirebaseAuth()
    
    init() {
        setGoogleSignInConfiguration()
    }
    
    private func setGoogleSignInConfiguration() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    func googleSignInAction(with controller: UIViewController, completion: @escaping (User) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { authResult, error in
            if let error = error {
                AppLogger.error("Google 登入失敗", category: .auth, error: error)
            }

            if let result = authResult {
                AppLogger.logAuthentication(
                    action: "Google Sign In",
                    provider: "Google",
                    userID: result.user.userID,
                    success: true
                )
                AppLogger.debug(
                """
                ----------Google登入資訊-----------
                userID:\(result.user.userID ?? "")
                name:\(result.user.profile?.name ?? "")
                email:\(result.user.profile?.email ?? "")
                url:\(result.user.profile?.imageURL(withDimension: .zero)?.absoluteString ?? "")
                ----------------------------------
                """, category: .auth
                )
                let user = User(birth: "未知的生日",
                                email: result.user.profile?.email ?? "未知的Email",
                                gender: "未知的性別",
                                headImage: result.user.profile?.imageURL(withDimension: .zero)?.scheme ?? "未知的大頭貼",
                                phone: "未知的電話",
                                name: result.user.profile?.name ?? "未知的名字")
                completion(user)
            }
        }
    }
    
    //Google登入
    func googleSignIn(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?, isLogginCompletion: @escaping (Bool) -> Void) {
        if let error = error {
            AppLogger.error("Google 登入發生錯誤", category: .auth, error: error)
            return
        }

        guard let idToken = user.idToken else { return }
        let accessToken = user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                       accessToken: accessToken)

        // 使用 Firebase 認證憑證登入
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                AppLogger.error("Firebase 登入發生錯誤", category: .auth, error: error)
                return
            }
            AppLogger.info("使用者成功登入：\(authResult?.user.displayName ?? "未知使用者")", category: .auth)
            isLogginCompletion((authResult?.user.isEmailVerified)!)
        }
    }
    
    //GoogleSignOut
    func googleSignOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    //Facebook登入
    func facebookSignIn(with controller: UIViewController, completion: @escaping (User) -> Void) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile","email"], from: controller) { result, error in
            if let error = error {
                AppLogger.error("Facebook 登入發生錯誤", category: .auth, error: error)
                return
            } else if let result = result, !result.isCancelled {
                if AccessToken.current != nil {
                    Profile.loadCurrentProfile { (profile, error) in
                        if let profile = profile {
                            AppLogger.logAuthentication(
                                action: "Facebook Sign In",
                                provider: "Facebook",
                                userID: profile.userID,
                                success: true
                            )
                            AppLogger.debug(
                            """
                            ---------Facebook登入資訊----------
                            userID:\(profile.userID)
                            name:\(profile.name ?? "")
                            email:\(profile.email ?? "")
                            ----------------------------------
                            """, category: .auth
                            )
                            let formatter = DateFormatter()
                            let user = User(birth: formatter.string(from: profile.birthday ?? Date()) ?? "未知的生日",
                                            email: profile.email ?? "未知的Email",
                                            gender: profile.gender ?? "未知的性別",
                                            headImage: profile.imageURL?.scheme ?? "未知的大頭貼",
                                            phone: "未知的電話",
                                            name: profile.name ?? "未知的姓名")
                            completion(user)
                        }
                    }
                }
            }
        }
    }

    //一般註冊
    func normalCreateAccount(email: String, password: String, completion: @escaping (User) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                AppLogger.error("註冊失敗", category: .auth, error: error)
            }

            if let result = authResult {
                AppLogger.logAuthentication(
                    action: "Normal Sign Up",
                    provider: "Email",
                    userID: result.user.uid,
                    success: true
                )
                AppLogger.debug(
                """
                ----------一般註冊成功資訊-----------
                email:\(result.user.email ?? "")
                userID:\(result.user.uid)
                ----------------------------------
                """, category: .auth
                )
                let user = User(birth: "未知的生日",
                                email: result.user.email ?? "未知的Email",
                                gender: "未知的性別",
                                headImage: result.user.photoURL?.scheme ?? "未知的大頭貼",
                                phone: "未知的電話",
                                name: result.user.displayName ?? "未知的名字")
                completion(user)
            }
        }
    }
    //一般登入
    func normalLogin(email: String, password: String, completion: @escaping (User) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                AppLogger.error("登入失敗", category: .auth, error: error)
            }

            if let result = authResult {
                AppLogger.logAuthentication(
                    action: "Normal Login",
                    provider: "Email",
                    userID: result.user.uid,
                    success: true
                )
                AppLogger.debug(
                """
                ----------一般登入成功資訊-----------
                email:\(result.user.email ?? "")
                userID:\(result.user.uid)
                ----------------------------------
                """, category: .auth
                )
                let user = User(birth: "未知的生日",
                                email: result.user.email ?? "未知的Email",
                                gender: "未知的性別",
                                headImage: "\(result.user.photoURL)",
                                phone: "未知的電話",
                                name: result.user.displayName ?? "未知的名字")
                completion(user)
            }
        }
    }
    
    //手機號碼驗證
    func sendMessengeVerified(byPhoneNumber number: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { verificationID, error in
            if let error = error {
                AppLogger.error("發送驗證碼失敗", category: .auth, error: error)
                return
            }
            if let verificationID = verificationID {
                AppLogger.info("驗證碼已發送，verificationID: \(verificationID)", category: .auth)
                // 將 verificationID 儲存起來，稍後用於驗證碼確認
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            }
        }
    }
    
    func verifyMessengeCode(byVerifyCode code: String, completion: @escaping (String) -> Void) {
        // 在某個按鈕點擊事件中處理
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let verificationCode = code // 使用者輸入的驗證碼

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID ?? "",
            verificationCode: verificationCode
        )

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                AppLogger.error("驗證碼驗證失敗", category: .auth, error: error)
                return
            }
            AppLogger.info("驗證碼驗證成功", category: .auth)
            authResult?.additionalUserInfo?.username
            // 驗證成功，authResult 中包含使用者資訊
        }

    }
    
    func sendEmailVerified(byEmail email: String, byPassword password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                AppLogger.error("創建用戶失敗", category: .auth, error: error)
                return
            }

            // 發送驗證郵件
            authResult?.user.sendEmailVerification(completion: { error in
                if let error = error {
                    AppLogger.error("發送驗證郵件失敗", category: .auth, error: error)
                    return
                }

                AppLogger.info("驗證郵件已發送", category: .auth)
            })
        }
    }
    
    func verifiedEmailCode(byEmail email: String, byPassword password: String, code: String) {
        let verificationCode = code // 使用者通過郵件接收到的驗證碼
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        Auth.auth().currentUser?.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                AppLogger.error("重新認證失敗", category: .auth, error: error)
                return
            }
            // 驗證成功，更新你的使用者介面
            AppLogger.info("Email 驗證成功", category: .auth)
        }
    }
}
