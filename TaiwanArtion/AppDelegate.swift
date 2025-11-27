//
//  AppDelegate.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/11.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import Kingfisher

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Facebook SDK 配置
        ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions
                )

        // Kingfisher 全域配置
        configureKingfisher()

        return true
    }

    // MARK: - Kingfisher Configuration

    /// 配置 Kingfisher 圖片快取系統
    private func configureKingfisher() {
        // 設定記憶體快取限制為 100 MB
        ImageCache.default.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024

        // 設定磁碟快取限制為 500 MB
        ImageCache.default.diskStorage.config.sizeLimit = 500 * 1024 * 1024

        // 設定快取過期時間為 7 天
        ImageCache.default.diskStorage.config.expiration = .days(7)

        // 清理過期的磁碟快取
        ImageCache.default.cleanExpiredDiskCache()

        // 配置下載器
        let downloader = ImageDownloader.default
        downloader.downloadTimeout = 15.0 // 下載超時時間 15 秒
        downloader.trustedHosts = Set(["firebasestorage.googleapis.com"]) // 信任的主機

        // 設定預設圖片處理選項
        KingfisherManager.shared.defaultOptions = [
            .transition(.fade(0.2)), // 淡入效果
            .cacheOriginalImage, // 快取原始圖片
            .scaleFactor(UIScreen.main.scale), // 螢幕縮放因子
            .processor(DownsamplingImageProcessor(size: CGSize(width: 300, height: 300))), // 降採樣
            .backgroundDecode // 背景解碼
        ]
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let googleSignInHandled = GIDSignIn.sharedInstance.handle(url)
        let facebookSignInHandled = ApplicationDelegate.shared.application(app, open: url, options: options)
      return googleSignInHandled || facebookSignInHandled
    }
}

