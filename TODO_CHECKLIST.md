# TaiwanArtionV1 翻新工作清單

> **文檔版本**: 1.0.0
> **生成日期**: 2025-11-27
> **預估總工時**: 17-26 工作天

---

## 使用說明

本文檔包含所有翻新工作的詳細清單。每個任務都有：
- 📋 任務描述
- ⏱️ 預估時間
- 🎯 優先級（🔴 緊急 / 🟠 高 / 🟡 中 / 🟢 低）
- ✅ 完成狀態勾選框

---

## 階段一：安全性修復 🔒

**預估時間**: 1-2 天
**優先級**: 🔴 緊急
**開始日期**: ___________
**完成日期**: ___________

### 1.1 移除測試模式設定
- [ ] 找到 `FirebaseAuth.swift` 第 190 行
- [ ] 移除 `Auth.auth().settings?.isAppVerificationDisabledForTesting = true`
- [ ] 確認移除後 Firebase Auth 仍正常運作
- [ ] 測試 Email 驗證功能
- [ ] 測試手機號碼驗證功能

**預估時間**: 30 分鐘
**相關檔案**: `TaiwanArtion/Firebase/FirebaseAuth.swift`

---

### 1.2 保護 API Keys

#### 1.2.1 更新 .gitignore
- [ ] 開啟專案根目錄的 `.gitignore` 檔案
- [ ] 加入以下內容：
  ```gitignore
  # Firebase 配置檔（敏感資訊）
  GoogleService-Info.plist
  GoogleService-Info-Dev.plist
  GoogleService-Info-Staging.plist

  # 環境變數
  .env
  .env.local

  # Xcode 用戶設定
  *.xcuserstate
  xcuserdata/
  ```
- [ ] 儲存檔案

**預估時間**: 10 分鐘

#### 1.2.2 從 Git 歷史移除敏感檔案
- [ ] 執行以下命令移除 `GoogleService-Info.plist`：
  ```bash
  git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch GoogleService-Info.plist" \
  --prune-empty --tag-name-filter cat -- --all
  ```
- [ ] 執行以下命令移除 `Info.plist` 中的敏感資訊
- [ ] 強制推送到遠端：
  ```bash
  git push origin --force --all
  ```
- [ ] ⚠️ **警告**: 這會改寫 Git 歷史，通知所有協作者重新 clone

**預估時間**: 30 分鐘

#### 1.2.3 重新生成 API Keys
- [ ] 登入 [Firebase Console](https://console.firebase.google.com/)
- [ ] 選擇 TaiwanArtion 專案
- [ ] 進入 "專案設定" → "一般"
- [ ] 刪除現有的 iOS App
- [ ] 重新新增 iOS App
- [ ] 下載新的 `GoogleService-Info.plist`
- [ ] 將檔案放到專案目錄（不要加入 Git）
- [ ] 確認檔案已被 `.gitignore` 忽略

**預估時間**: 20 分鐘

- [ ] 登入 [Facebook 開發者平台](https://developers.facebook.com/)
- [ ] 進入 TaiwanArtion 應用程式
- [ ] 進入 "設定" → "基本資料"
- [ ] 重新生成 Client Token
- [ ] 記錄新的 App ID 和 Client Token
- [ ] 更新 `Info.plist`（使用環境變數，見下一步）

**預估時間**: 15 分鐘

---

### 1.3 實作環境變數管理

#### 1.3.1 建立配置管理檔案
- [ ] 在 `TaiwanArtion/Core/Configuration/` 目錄下建立 `AppConfig.swift`
- [ ] 複製以下代碼：
  ```swift
  import Foundation

  struct AppConfig {
      // MARK: - Firebase
      static var googleAPIKey: String {
          return getConfigValue(for: "GOOGLE_API_KEY")
      }

      // MARK: - Facebook
      static var facebookAppID: String {
          return getConfigValue(for: "FACEBOOK_APP_ID")
      }

      static var facebookClientToken: String {
          return getConfigValue(for: "FACEBOOK_CLIENT_TOKEN")
      }

      // MARK: - Helper
      private static func getConfigValue(for key: String) -> String {
          guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
                !value.isEmpty else {
              fatalError("\(key) not found in Info.plist")
          }
          return value
      }
  }
  ```
- [ ] 儲存檔案

**預估時間**: 15 分鐘

#### 1.3.2 更新 Info.plist
- [ ] 開啟 `Info.plist`
- [ ] 修改為使用環境變數：
  ```xml
  <key>GOOGLE_API_KEY</key>
  <string>$(GOOGLE_API_KEY)</string>
  <key>FACEBOOK_APP_ID</key>
  <string>$(FACEBOOK_APP_ID)</string>
  <key>FACEBOOK_CLIENT_TOKEN</key>
  <string>$(FACEBOOK_CLIENT_TOKEN)</string>
  ```
- [ ] 儲存檔案

**預估時間**: 10 分鐘

#### 1.3.3 在 Xcode 設定環境變數
- [ ] 開啟 Xcode 專案
- [ ] 選擇專案 → Target "TaiwanArtion" → "Build Settings"
- [ ] 搜尋 "User-Defined"
- [ ] 點擊 "+" 新增以下變數：
  - `GOOGLE_API_KEY` = (從 Firebase 取得的新 Key)
  - `FACEBOOK_APP_ID` = (從 Facebook 取得的新 App ID)
  - `FACEBOOK_CLIENT_TOKEN` = (從 Facebook 取得的新 Client Token)
- [ ] 建構專案確認無錯誤

**預估時間**: 15 分鐘

---

### 1.4 實作 Keychain 儲存

#### 1.4.1 建立 KeychainManager
- [ ] 在 `TaiwanArtion/Core/Storage/` 目錄下建立 `KeychainManager.swift`
- [ ] 複製 `SPEC_KIT.md` 中的 KeychainManager 代碼
- [ ] 測試 save 和 get 方法

**預估時間**: 30 分鐘

#### 1.4.2 遷移敏感資料到 Keychain
- [ ] 找到所有使用 UserDefaults 儲存 Token 的地方
- [ ] 改用 KeychainManager：
  ```swift
  // 舊代碼
  UserDefaults.standard.set(token, forKey: "authToken")

  // 新代碼
  KeychainManager.shared.save(key: "authToken", value: token)
  ```
- [ ] 測試登入/登出功能

**預估時間**: 1 小時

---

### 1.5 檢查 App Transport Security (ATS)

- [ ] 開啟 `Info.plist`
- [ ] 搜尋 `NSAppTransportSecurity`
- [ ] 如果存在 `NSAllowsArbitraryLoads = YES`，檢查是否必要
- [ ] 如果不需要，移除此設定
- [ ] 如果需要，為特定域名設定例外

**預估時間**: 15 分鐘

---

### 1.6 安全性測試

- [ ] 使用 Charles/Proxyman 檢查網路請求
- [ ] 確認所有請求都使用 HTTPS
- [ ] 確認 Token 不會在 URL 參數中傳遞
- [ ] 測試 Firebase 認證流程
- [ ] 測試 Google 登入
- [ ] 測試 Facebook 登入
- [ ] 確認敏感資訊不會記錄在 Console

**預估時間**: 1 小時

---

## 階段二：代碼清理 🧹

**預估時間**: 3-5 天
**優先級**: 🟠 高
**開始日期**: ___________
**完成日期**: ___________

### 2.1 實作統一日誌系統

#### 2.1.1 安裝 CocoaLumberjack
- [ ] 開啟 `Podfile`
- [ ] 加入 `pod 'CocoaLumberjack/Swift', '~> 3.8'`
- [ ] 執行 `pod install`

**預估時間**: 10 分鐘

#### 2.1.2 建立 AppLogger
- [ ] 在 `TaiwanArtion/Core/Logger/` 目錄下建立 `AppLogger.swift`
- [ ] 複製 `SPEC_KIT.md` 中的 AppLogger 代碼
- [ ] 在 `AppDelegate.swift` 中初始化 Logger

**預估時間**: 30 分鐘

#### 2.1.3 替換所有 print() 語句
**影響檔案**: 20+ 個檔案，72 處 print()

- [ ] `FirebaseAuth.swift` (11 處)
  - [ ] 第 64, 73, 91, 113, 129, 145, 161, 183, 190, 208, 247 行
- [ ] `FirebaseDatabase.swift` (2 處)
- [ ] `LocationInterface.swift` (5 處)
- [ ] `SearchViewController.swift` (8 處)
- [ ] `ExhibitionDetailViewController.swift` (6 處)
- [ ] `FilterViewController.swift` (4 處)
- [ ] `HomeViewController.swift` (3 處)
- [ ] `LoginViewController.swift` (5 處)
- [ ] `RegisterViewController.swift` (4 處)
- [ ] `ProfileViewController.swift` (3 處)
- [ ] `CollectViewController.swift` (2 處)
- [ ] `NotificationViewController.swift` (2 處)
- [ ] `MapViewController.swift` (4 處)
- [ ] `ReviewViewController.swift` (3 處)
- [ ] `ViewModel 檔案` (10 處)

**替換規則**:
```swift
// 舊代碼
print("Debug message")
print("Error: \(error)")

// 新代碼
AppLogger.debug("Debug message")
AppLogger.error("Error: \(error)")
```

**預估時間**: 2-3 小時

---

### 2.2 清理註解掉的代碼

#### 2.2.1 User.swift
- [ ] 開啟 `TaiwanArtion/Model/User.swift`
- [ ] 刪除第 11-17 行的註解代碼
- [ ] 確認沒有其他地方使用這些舊屬性

**預估時間**: 10 分鐘

#### 2.2.2 LoginViewModel.swift
- [ ] 開啟 `TaiwanArtion/ViewModel/LoginViewModel.swift`
- [ ] 檢查第 88, 94 行的驗證邏輯
- [ ] **決策點**: 啟用還是刪除？
  - [ ] 選項 A: 取消註解並修復邏輯（需 30 分鐘）
  - [ ] 選項 B: 完全刪除（需 5 分鐘）
- [ ] 執行選擇的選項

**預估時間**: 5-30 分鐘

#### 2.2.3 LocationInterface.swift
- [ ] 開啟 `TaiwanArtion/Map/LocationInterface.swift`
- [ ] 檢查第 81-84 行的地點搜尋功能
- [ ] **決策點**: 啟用還是刪除？
  - [ ] 選項 A: 取消註解並完成功能（需 1-2 小時）
  - [ ] 選項 B: 刪除（需 5 分鐘）
- [ ] 執行選擇的選項

**預估時間**: 5 分鐘 - 2 小時

#### 2.2.4 CheckLogicInterface.swift
- [ ] 開啟 `TaiwanArtion/Protocol/CheckLogicInterface.swift`
- [ ] 刪除第 21, 38, 81-172 行的測試代碼
- [ ] 確認刪除後不影響功能

**預估時間**: 15 分鐘

#### 2.2.5 TaiwanArtionDateView.swift
- [ ] 開啟 `TaiwanArtion/View/TaiwanArtionDateView.swift`
- [ ] 檢查第 64-81 行的手勢識別功能
- [ ] **決策點**: 啟用還是刪除？
  - [ ] 選項 A: 取消註解並修復（需 30 分鐘）
  - [ ] 選項 B: 刪除（需 5 分鐘）
- [ ] 執行選擇的選項

**預估時間**: 5-30 分鐘

---

### 2.3 Line SDK 決策

#### 2.3.1 評估 Line Login 需求
- [ ] 與產品團隊確認是否需要 Line Login
- [ ] 評估用戶需求和市場數據
- [ ] **做出決策**: 保留 or 移除

**預估時間**: 30 分鐘（會議）

#### 2.3.2 選項 A: 完成 Line Login（如果保留）
- [ ] 研究 LineSDKSwift 文檔
- [ ] 在 `LoginViewController.swift` 加入 Line Login 按鈕
- [ ] 實作 Line Login 流程
- [ ] 整合到 Firebase Auth
- [ ] 測試 Line Login 功能
- [ ] 更新 Info.plist 設定

**預估時間**: 2-3 天

#### 2.3.3 選項 B: 移除 Line SDK（如果不保留）
- [ ] 開啟 `Podfile`
- [ ] 移除 `pod 'LineSDKSwift'`
- [ ] 執行 `pod install`
- [ ] 清理專案並重新建構
- [ ] 確認 App 大小減少

**預估時間**: 15 分鐘

---

### 2.4 統一錯誤處理

#### 2.4.1 建立錯誤類型定義
- [ ] 在 `TaiwanArtion/Core/` 建立 `AppError.swift`
- [ ] 定義統一的錯誤類型：
  ```swift
  enum AppError: Error {
      case networkError
      case authenticationFailed
      case dataNotFound
      case permissionDenied
      case invalidInput(String)
      case unknown(Error)

      var localizedDescription: String {
          // 實作
      }
  }
  ```

**預估時間**: 30 分鐘

#### 2.4.2 更新錯誤處理
- [ ] 在所有 Firebase 操作中使用 AppError
- [ ] 在所有 ViewModel 中統一錯誤處理
- [ ] 建立用戶友好的錯誤提示

**預估時間**: 2-3 小時

---

### 2.5 代碼格式化

#### 2.5.1 安裝 SwiftLint
- [ ] 開啟 `Podfile`
- [ ] 加入 `pod 'SwiftLint'`
- [ ] 執行 `pod install`
- [ ] 在 Xcode Build Phases 加入 SwiftLint Script

**預估時間**: 20 分鐘

#### 2.5.2 建立 .swiftlint.yml
- [ ] 在專案根目錄建立 `.swiftlint.yml`
- [ ] 配置規則
- [ ] 執行 SwiftLint 並修復警告

**預估時間**: 1-2 小時

---

## 階段三：功能完善 ✨

**預估時間**: 5-7 天
**優先級**: 🟡 中
**開始日期**: ___________
**完成日期**: ___________

### 3.1 完成 FirebaseDatabase 未實現方法

#### 3.1.1 實作 getPopularDocument()
- [ ] 開啟 `TaiwanArtion/Firebase/FirebaseDatabase.swift`
- [ ] 找到第 91-93 行的空函數
- [ ] 實作邏輯：
  ```swift
  func getPopularDocument() -> Observable<[Exhibition]> {
      return Observable.create { observer in
          self.db.collection("exhibitions")
              .order(by: "viewCount", descending: true)
              .limit(to: 10)
              .getDocuments { querySnapshot, error in
                  if let error = error {
                      observer.onError(error)
                      return
                  }

                  let exhibitions = querySnapshot?.documents.compactMap { doc -> Exhibition? in
                      try? doc.data(as: Exhibition.self)
                  } ?? []

                  observer.onNext(exhibitions)
                  observer.onCompleted()
              }

          return Disposables.create()
      }
  }
  ```
- [ ] 在 HomeViewModel 中使用
- [ ] 測試功能

**預估時間**: 1-2 小時

#### 3.1.2 實作 getHighEvaluationDocument()
- [ ] 找到第 95-96 行的空函數
- [ ] 實作邏輯（查詢 rating 最高的展覽）
- [ ] 在 HomeViewModel 中使用
- [ ] 測試功能

**預估時間**: 1-2 小時

---

### 3.2 完成 CollectViewModel 未實現方法

#### 3.2.1 實作 fetchFirebaseCollectSearchingData()
- [ ] 開啟 `TaiwanArtion/ViewModel/CollectViewModel.swift`
- [ ] 找到第 144-150 行
- [ ] 實作搜尋歷史功能：
  ```swift
  private func fetchFirebaseCollectSearchingData(by userID: String, completion: @escaping (([String]) -> Void)) {
      db.collection("users")
          .document(userID)
          .getDocument { document, error in
              if let error = error {
                  AppLogger.error("Failed to fetch search history: \(error)")
                  completion([])
                  return
              }

              let searchHistory = document?.data()?["searchHistory"] as? [String] ?? []
              completion(searchHistory)
          }
  }
  ```
- [ ] 測試功能

**預估時間**: 1 小時

#### 3.2.2 實作 fetchFirebaseNewsData()
- [ ] 找到第 152-154 行
- [ ] 實作新聞收藏功能
- [ ] 測試功能

**預估時間**: 1-2 小時

#### 3.2.3 實作 fetchStore()
- [ ] 找到第 156 行
- [ ] 實作資料儲存功能
- [ ] 測試功能

**預估時間**: 1 小時

---

### 3.3 驗證邏輯完善

#### 3.3.1 帳號驗證
- [ ] 開啟 `TaiwanArtion/ViewModel/LoginViewModel.swift`
- [ ] 檢查 `checkAccount()` 方法
- [ ] 啟用驗證邏輯
- [ ] 加入即時驗證反饋
- [ ] 測試各種輸入情況

**預估時間**: 1-2 小時

#### 3.3.2 密碼驗證
- [ ] 檢查 `checkPassword()` 方法
- [ ] 啟用驗證邏輯
- [ ] 加入密碼強度提示
- [ ] 測試各種輸入情況

**預估時間**: 1-2 小時

---

### 3.4 地點搜尋功能

- [ ] 決定是否需要此功能
- [ ] 如果需要，取消 `LocationInterface.swift` 的註解
- [ ] 完善搜尋邏輯
- [ ] 整合到地圖頁面
- [ ] 測試搜尋功能

**預估時間**: 2-3 小時（如果實作）

---

### 3.5 Bug 修復

#### 3.5.1 地標對應問題
- [ ] 重現問題
- [ ] 檢查地圖標記邏輯
- [ ] 修復對應錯誤
- [ ] 測試所有地標

**預估時間**: 2-4 小時

#### 3.5.2 其他已知問題
- [ ] 列出所有已知 Bug
- [ ] 逐一修復
- [ ] 回歸測試

**預估時間**: 視 Bug 數量而定

---

## 階段四：依賴更新 📦

**預估時間**: 2-3 天
**優先級**: 🟡 中
**開始日期**: ___________
**完成日期**: ___________

### 4.1 備份專案

- [ ] 提交所有未提交的變更
- [ ] 建立新分支 `feature/dependency-update`
- [ ] 備份 Podfile.lock

**預估時間**: 10 分鐘

---

### 4.2 更新 CocoaPods

- [ ] 執行 `sudo gem install cocoapods`
- [ ] 確認 CocoaPods 版本

**預估時間**: 15 分鐘

---

### 4.3 更新主要依賴

#### 4.3.1 Firebase
- [ ] 開啟 `Podfile`
- [ ] 將 Firebase 版本改為 `~> 11.0`
- [ ] 執行 `pod update Firebase`
- [ ] 檢查 Breaking Changes
- [ ] 修復不相容的 API
- [ ] 測試所有 Firebase 功能

**預估時間**: 4-6 小時

#### 4.3.2 Kingfisher
- [ ] 將 Kingfisher 版本改為 `~> 7.0`
- [ ] 執行 `pod update Kingfisher`
- [ ] 檢查 API 變更
- [ ] 更新圖片載入代碼
- [ ] 測試圖片載入

**預估時間**: 2-3 小時

#### 4.3.3 RxSwift
- [ ] 將 RxSwift 版本改為 `~> 6.7`
- [ ] 執行 `pod update RxSwift RxCocoa RxRelay`
- [ ] 測試所有 Rx 功能

**預估時間**: 1 小時

#### 4.3.4 GoogleSignIn
- [ ] 更新到最新版本
- [ ] 測試 Google 登入

**預估時間**: 30 分鐘

#### 4.3.5 Facebook SDK
- [ ] 更新到最新版本
- [ ] 測試 Facebook 登入

**預估時間**: 30 分鐘

---

### 4.4 相容性測試

- [ ] 執行完整的回歸測試
- [ ] 測試所有主要功能
- [ ] 修復發現的問題
- [ ] 效能測試

**預估時間**: 4-6 小時

---

### 4.5 考慮遷移到 SPM（可選）

#### 4.5.1 評估
- [ ] 評估遷移成本
- [ ] 列出優缺點
- [ ] 做出決策

**預估時間**: 1 小時

#### 4.5.2 執行遷移（如果決定遷移）
- [ ] 逐步遷移依賴到 SPM
- [ ] 測試建構
- [ ] 完全移除 CocoaPods

**預估時間**: 2-3 天

---

## 階段五：效能優化 ⚡

**預估時間**: 3-4 天
**優先級**: 🟢 低-中
**開始日期**: ___________
**完成日期**: ___________

### 5.1 Firebase 查詢優化

#### 5.1.1 優化 getRandomDocuments
- [ ] 開啟 `FirebaseDatabase.swift`
- [ ] 找到 `getRandomDocuments` 方法
- [ ] 重構為使用更高效的查詢
- [ ] 使用 Firebase 的 `whereField` 和 `limit`
- [ ] 測試效能改善

**預估時間**: 2-3 小時

#### 5.1.2 實作分頁載入
- [ ] 在列表頁面實作分頁
- [ ] 使用 Firestore 的 `startAfter` 和 `limit`
- [ ] 測試分頁功能

**預估時間**: 3-4 小時

#### 5.1.3 設定 Firestore 索引
- [ ] 登入 Firebase Console
- [ ] 進入 Firestore
- [ ] 根據查詢設定複合索引
- [ ] 測試查詢速度

**預估時間**: 1 小時

---

### 5.2 圖片載入優化

#### 5.2.1 配置 Kingfisher
- [ ] 在 AppDelegate 配置全域 Kingfisher 設定
- [ ] 設定記憶體快取限制
- [ ] 設定磁碟快取限制
- [ ] 測試記憶體使用

**預估時間**: 1 小時

#### 5.2.2 實作圖片預載入
- [ ] 在列表將要顯示時預載入圖片
- [ ] 使用 Kingfisher 的 prefetch 功能
- [ ] 測試滾動流暢度

**預估時間**: 2-3 小時

#### 5.2.3 加入載入佔位圖
- [ ] 設計佔位圖
- [ ] 在所有圖片載入處加入佔位圖
- [ ] 測試用戶體驗

**預估時間**: 1-2 小時

---

### 5.3 記憶體管理

#### 5.3.1 使用 Instruments 檢測
- [ ] 開啟 Xcode Instruments
- [ ] 執行 Allocations 工具
- [ ] 執行 Leaks 工具
- [ ] 記錄記憶體洩漏

**預估時間**: 2 小時

#### 5.3.2 修復記憶體洩漏
- [ ] 檢查所有 RxSwift 訂閱
- [ ] 確認 DisposeBag 正確使用
- [ ] 修復循環引用
- [ ] 重新測試

**預估時間**: 2-4 小時

#### 5.3.3 優化列表記憶體
- [ ] 確保 Cell 正確重用
- [ ] 清理不在螢幕上的圖片快取
- [ ] 測試記憶體使用

**預估時間**: 2-3 小時

---

### 5.4 月曆組件優化

#### 5.4.1 快取日期計算
- [ ] 開啟月曆相關檔案
- [ ] 識別重複的日期計算
- [ ] 實作快取機制
- [ ] 測試效能

**預估時間**: 2-3 小時

#### 5.4.2 優化 CollectionView
- [ ] 確保 Cell 重用正確
- [ ] 優化佈局計算
- [ ] 測試滾動流暢度

**預估時間**: 2 小時

---

### 5.5 啟動時間優化

#### 5.5.1 分析啟動流程
- [ ] 使用 Instruments 的 Time Profiler
- [ ] 記錄啟動時間各階段耗時
- [ ] 識別瓶頸

**預估時間**: 1 小時

#### 5.5.2 延遲載入
- [ ] 將非關鍵組件延遲載入
- [ ] 優化 Firebase 初始化
- [ ] 測試啟動時間

**預估時間**: 2-3 小時

---

### 5.6 效能測試

- [ ] 測試啟動時間（目標 < 2 秒）
- [ ] 測試畫面幀率（目標 60 FPS）
- [ ] 測試記憶體使用（目標 < 150 MB）
- [ ] 測試 API 回應時間（目標 < 1 秒）
- [ ] 記錄效能指標

**預估時間**: 2 小時

---

## 階段六：測試和文檔 📝

**預估時間**: 3-5 天
**優先級**: 🟢 低
**開始日期**: ___________
**完成日期**: ___________

### 6.1 單元測試

#### 6.1.1 ViewModel 測試
- [ ] 為 LoginViewModel 撰寫測試
- [ ] 為 RegisterViewModel 撰寫測試
- [ ] 為 ExhibitionViewModel 撰寫測試
- [ ] 為 CollectViewModel 撰寫測試
- [ ] 為 ProfileViewModel 撰寫測試
- [ ] 達到 70% 測試覆蓋率

**預估時間**: 1-2 天

#### 6.1.2 Repository 測試
- [ ] 為 FirebaseDatabase 撰寫測試
- [ ] 為 FirebaseAuth 撰寫測試
- [ ] Mock Firebase 服務

**預估時間**: 1 天

#### 6.1.3 Utility 測試
- [ ] 為工具類撰寫測試
- [ ] 達到 80% 測試覆蓋率

**預估時間**: 4 小時

---

### 6.2 UI 測試

#### 6.2.1 登入流程測試
- [ ] Email 登入測試
- [ ] Google 登入測試
- [ ] Facebook 登入測試
- [ ] 錯誤處理測試

**預估時間**: 3-4 小時

#### 6.2.2 展覽瀏覽測試
- [ ] 列表滾動測試
- [ ] 搜尋功能測試
- [ ] 篩選功能測試
- [ ] 詳情頁測試

**預估時間**: 3-4 小時

#### 6.2.3 收藏功能測試
- [ ] 加入收藏測試
- [ ] 移除收藏測試
- [ ] 收藏列表測試

**預估時間**: 2 小時

---

### 6.3 文檔撰寫

#### 6.3.1 更新 README.md
- [ ] 專案簡介
- [ ] 功能列表
- [ ] 技術棧
- [ ] 安裝指南
- [ ] 建構指南
- [ ] 貢獻指南

**預估時間**: 2-3 小時

#### 6.3.2 API 文檔
- [ ] Firebase 集合結構文檔
- [ ] 數據模型文檔
- [ ] API 使用範例

**預估時間**: 2-3 小時

#### 6.3.3 架構說明文檔
- [ ] MVVM 架構說明
- [ ] 目錄結構說明
- [ ] 模組依賴圖
- [ ] 數據流程圖

**預估時間**: 3-4 小時

#### 6.3.4 開發環境設定指南
- [ ] Xcode 設定
- [ ] Firebase 設定
- [ ] CocoaPods 安裝
- [ ] 環境變數配置

**預估時間**: 2 小時

---

### 6.4 Code Review

#### 6.4.1 SwiftLint 檢查
- [ ] 執行 SwiftLint
- [ ] 修復所有警告
- [ ] 優化代碼風格

**預估時間**: 2-3 小時

#### 6.4.2 團隊 Code Review
- [ ] 建立 Pull Request
- [ ] 團隊審查代碼
- [ ] 回應審查意見
- [ ] 修改代碼

**預估時間**: 視團隊而定

---

## 進度追蹤

### 總體進度

- [ ] 階段一：安全性修復（1-2 天）
- [ ] 階段二：代碼清理（3-5 天）
- [ ] 階段三：功能完善（5-7 天）
- [ ] 階段四：依賴更新（2-3 天）
- [ ] 階段五：效能優化（3-4 天）
- [ ] 階段六：測試和文檔（3-5 天）

**總進度**: _____ / 100%

### 重要里程碑

- [ ] 安全性問題全部修復
- [ ] 代碼品質達標（無 print，無註解代碼）
- [ ] 所有規劃功能完成
- [ ] 依賴套件全部更新
- [ ] 效能指標達標
- [ ] 測試覆蓋率 > 60%
- [ ] 文檔完整

---

## 備註

### 決策記錄

| 日期 | 決策項目 | 決策結果 | 原因 |
|------|---------|---------|------|
| ___ | Line SDK | 保留/移除 | ___ |
| ___ | 驗證邏輯 | 啟用/移除 | ___ |
| ___ | 地點搜尋 | 實作/移除 | ___ |
| ___ | SPM 遷移 | 執行/延後 | ___ |

### 問題追蹤

| 日期 | 問題描述 | 嚴重程度 | 狀態 | 解決方案 |
|------|---------|---------|------|---------|
| ___ | ___ | 🔴/🟡/🟢 | ___ | ___ |

---

*本清單會隨著工作進度持續更新*

**最後更新**: ___________
**更新者**: ___________
