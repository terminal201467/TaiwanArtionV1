<div align="center">
  <img src="app_icon.png" alt="早找展覽 App Icon" width="200"/>

  # 早找展覽 TaiwanArtion

  **台灣藝術展覽資訊平台**

  [![Platform](https://img.shields.io/badge/Platform-iOS%2013.0+-blue.svg)](https://www.apple.com/ios/)
  [![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
  [![License](https://img.shields.io/badge/License-Private-red.svg)](LICENSE)

</div>

---

## 專案簡介

早找展覽（TaiwanArtion）是一個專為台灣地區設計的藝術展覽資訊平台，採用 iOS 原生開發，提供便捷的展覽查詢、收藏、評價和地圖導航功能。應用程式使用現代化的 MVVM 架構和響應式編程，為用戶帶來流暢的使用體驗。

## 主要功能

### 🎨 展覽瀏覽
- **多維度展覽列表**：熱門展覽、最新資訊、完整列表
- **智能搜尋**：快速找到感興趣的展覽
- **進階篩選**：依日期、地點、類別篩選
- **月曆視圖**：自訂月曆組件，直觀查看展覽檔期
- **展覽詳情**：完整的展覽資訊和高解析度圖片

### 🔐 用戶認證
- **Email 登入/註冊**：傳統帳號密碼登入
- **Google 第三方登入**：快速便捷
- **Facebook 第三方登入**：社交帳號整合
- **Email 驗證**：確保帳號安全
- **密碼重置**：忘記密碼快速找回

### 🗺️ 地圖導航
- **展覽地點標記**：在地圖上查看所有展覽位置
- **地標高亮**：重要展覽館特別標示
- **導航整合**：一鍵導航到展覽地點

### ⭐ 個人功能
- **收藏展覽**：保存喜愛的展覽
- **收藏新聞**：收藏藝術相關新聞
- **搜尋歷史**：快速查看過往搜尋
- **個人資料管理**：編輯個人資訊
- **通知中心**：接收展覽提醒

### 📊 評價系統
- **星級評分**：為參觀過的展覽評分
- **多維度評價**：
  - 內容豐富度
  - 設備品質
  - 地理位置
  - 價格合理性
  - 服務品質

## 技術架構

### 核心技術棧

| 技術 | 版本 | 用途 |
|------|------|------|
| **Swift** | 5.0+ | 開發語言 |
| **iOS** | 13.0+ | 目標平台 |
| **Xcode** | 14.0+ | 開發工具 |

### 架構與框架

#### 架構模式
- **MVVM (Model-View-ViewModel)**: 業務邏輯與 UI 完全分離
- **RxSwift**: 響應式編程，優雅的事件處理
- **Repository Pattern**: 統一的數據存取介面

#### UI 框架
- **SnapKit 5.7.1**: 聲明式 Auto Layout
- **Kingfisher 7.12.0**: 高效圖片緩存和下載
  - 全域配置：100MB 記憶體快取、500MB 磁碟快取
  - 自動降採樣和背景解碼優化

#### 後端服務
- **Firebase 11.15.0**:
  - FirebaseCore: 核心服務
  - FirebaseAnalytics: 數據分析
  - FirebaseAuth: 身份認證
  - FirebaseFirestore: NoSQL 雲端數據庫
  - 支援分頁載入和查詢優化

#### 響應式編程
- **RxSwift 6.9.0**: 核心響應式庫
- **RxCocoa 6.9.0**: UIKit 擴展
- **RxRelay 6.9.0**: Subject 包裝
- **RxDataSources 5.0.0**: TableView/CollectionView 數據源
- **RxGesture 4.0.4**: 手勢識別擴展

#### 第三方登入
- **Google Sign-In 8.0.0**: Google 帳號登入
- **Facebook SDK 17.4.0**: Facebook 帳號登入
  - FBSDKCoreKit
  - FBSDKLoginKit

## 專案結構

```
TaiwanArtion/
├── ViewController/      (29 個檔案) - 頁面控制器
│   ├── LoginViewController.swift
│   ├── RegisterViewController.swift
│   ├── HomeViewController.swift
│   ├── ExhibitionDetailViewController.swift
│   └── ...
│
├── ViewModel/          (18 個檔案) - 業務邏輯層
│   ├── LoginViewModel.swift
│   ├── ExhibitionViewModel.swift
│   └── ...
│
├── View/              (54 個檔案) - 自訂視圖組件
│   ├── ExhibitionCardView.swift
│   ├── CalendarView.swift
│   └── ...
│
├── Model/             (5 個檔案) - 數據模型
│   ├── Exhibition.swift
│   ├── User.swift
│   └── ...
│
├── TableViewCell/     (38 個檔案) - TableView Cell
├── CollectionViewCell/ (24 個檔案) - CollectionView Cell
│
├── Firebase/          (2 個檔案) - Firebase 整合
│   ├── FirebaseAuth.swift
│   └── FirebaseDatabase.swift
│
├── Map/               (4 個檔案) - 地圖功能
├── Alerts/            (4 個檔案) - 彈窗組件
├── CustomObject/      (7 個檔案) - 自訂月曆組件
├── UserFeature/       (4 個檔案) - 用戶管理
├── Extension/         (3 個檔案) - 擴展
├── Enum/              (5 個檔案) - 枚舉定義
└── Protocol/          (1 個檔案) - 協議定義
```

## 開發環境設定

### 環境要求

```
- macOS 12.0+
- Xcode 14.0+
- Swift 5.0+
- CocoaPods 1.12.1+
```

### 安裝步驟

1. **Clone 專案**
```bash
git clone https://github.com/yourusername/TaiwanArtionV1.git
cd TaiwanArtionV1
```

2. **安裝依賴**
```bash
pod install
```

3. **開啟專案**
```bash
open TaiwanArtion.xcworkspace
```

4. **配置 Firebase**
- 在 [Firebase Console](https://console.firebase.google.com/) 創建專案
- 下載 `GoogleService-Info.plist`
- 將檔案放到專案目錄（不要提交到 Git）
- 更新 `.gitignore` 確保敏感檔案不被追蹤

5. **配置第三方登入**

**Google Sign-In:**
- 在 Firebase Console 啟用 Google 登入
- 配置 OAuth 2.0 Client ID

**Facebook Login:**
- 在 [Facebook 開發者平台](https://developers.facebook.com/) 創建應用
- 取得 App ID 和 Client Token
- 在 Info.plist 中配置（使用環境變數）

6. **運行專案**
- 選擇目標設備或模擬器
- 按 `⌘ + R` 運行

## 建構與發布

### 開發建構
```bash
# 使用 Xcode 或命令列
xcodebuild -workspace TaiwanArtion.xcworkspace \
           -scheme TaiwanArtion \
           -configuration Debug \
           -sdk iphonesimulator
```

### 發布建構
```bash
xcodebuild -workspace TaiwanArtion.xcworkspace \
           -scheme TaiwanArtion \
           -configuration Release \
           -sdk iphoneos \
           archive
```

## 專案翻新計劃

> **注意**: 本專案目前正在進行系統性翻新，以提升代碼品質、安全性和效能。

### 翻新文檔
- 📊 [專案分析報告](PROJECT_ANALYSIS_REPORT.md) - 詳細的現狀分析
- 📐 [開發規範 (Spec-Kit)](SPEC_KIT.md) - 完整的開發規範
- ✅ [待辦清單](TODO_CHECKLIST.md) - 詳細的任務列表
- 📖 [翻新指南](REFACTORING_GUIDE.md) - 快速入門指南

### 翻新進度

| 階段 | 狀態 | 說明 |
|------|------|------|
| **Phase 1: 安全性修復** | ⏸️ 待開始 | API Keys 保護、Keychain 整合 |
| **Phase 2: 代碼清理** | ⏸️ 待開始 | 移除 debug 代碼、統一日誌系統 |
| **Phase 3: 功能完善** | ⏸️ 待開始 | 完成未實現的功能 |
| **Phase 4: 依賴更新** | ✅ 已完成 | Firebase 11.x、RxSwift 6.9、Kingfisher 7.x |
| **Phase 5: 效能優化** | ✅ 已完成 | Firebase 分頁、Kingfisher 配置、記憶體優化 |
| **Phase 6: 測試與文檔** | 🔄 進行中 | 增加測試覆蓋率、完善文檔 |

### 最近更新 (Phase 4 & 5)

#### Phase 4: 依賴更新 ✅
- ✅ 更新 Firebase SDK 至 11.15.0
- ✅ 更新 RxSwift 生態系至 6.9.0
- ✅ 更新 Kingfisher 至 7.12.0
- ✅ 更新 Google Sign-In 至 8.0.0
- ✅ 更新 Facebook SDK 至 17.4.0
- ✅ 修復所有 `import Firebase` 改為 `import FirebaseCore`

#### Phase 5: 效能優化 ✅
- ✅ Firebase 查詢優化
  - `getRandomDocuments()` 使用 limit 查詢
  - 實作分頁載入 `getPaginatedDocuments()`
  - 添加 AppLogger 性能追蹤
- ✅ Kingfisher 全域配置
  - 記憶體快取: 100 MB
  - 磁碟快取: 500 MB
  - 快取過期: 7 天
- ✅ 修復 RxSwift 記憶體洩漏
  - 5 處 closure 記憶體洩漏修復
  - 添加 `[weak self]` 防止 retain cycle

詳細計劃請參考：
- [翻新指南](REFACTORING_GUIDE.md)
- [依賴更新摘要](DEPENDENCY_UPDATE_SUMMARY.md)

## 代碼規範

### 命名規範
```swift
// ViewController
class ExhibitionDetailViewController: UIViewController { }

// ViewModel
class ExhibitionDetailViewModel { }

// View
class ExhibitionCardView: UIView { }

// Model
struct Exhibition: Codable { }
```

### RxSwift 使用規範
```swift
// 避免記憶體洩漏
button.rx.tap
    .subscribe(onNext: { [weak self] in
        self?.handleButtonTap()
    })
    .disposed(by: disposeBag)

// 使用 Driver 確保主線程
viewModel.exhibitions
    .asDriver(onErrorJustReturn: [])
    .drive(tableView.rx.items(cellIdentifier: "cell")) { index, model, cell in
        // 配置 cell
    }
    .disposed(by: disposeBag)
```

## 測試

### 運行測試
```bash
# 運行所有測試
xcodebuild test -workspace TaiwanArtion.xcworkspace \
                -scheme TaiwanArtion \
                -sdk iphonesimulator \
                -destination 'platform=iOS Simulator,name=iPhone 14'

# 使用 Xcode
⌘ + U
```

### 測試覆蓋率
目標測試覆蓋率：
- ViewModel: 70%+
- Repository: 60%+
- Utility: 80%+

## 貢獻指南

### 分支策略
- `main` - 穩定版本
- `develop` - 開發版本
- `feature/*` - 功能分支
- `bugfix/*` - Bug 修復分支

### 提交規範
```
[類型] 簡短描述

詳細說明（可選）

類型：
- feat: 新功能
- fix: Bug 修復
- docs: 文檔更新
- style: 代碼格式調整
- refactor: 代碼重構
- test: 測試相關
- chore: 建構/工具變更
```

### Pull Request 流程
1. Fork 專案
2. 創建功能分支
3. 提交變更
4. 推送到分支
5. 創建 Pull Request
6. 等待代碼審查

## 相關資源

### 官方文檔
- [Swift 官方文檔](https://swift.org/documentation/)
- [Firebase iOS 文檔](https://firebase.google.com/docs/ios/setup)
- [RxSwift 文檔](https://github.com/ReactiveX/RxSwift)
- [SnapKit 文檔](https://github.com/SnapKit/SnapKit)

### 設計資源
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [iOS Design Themes](https://developer.apple.com/design/human-interface-guidelines/ios/overview/themes/)

## 授權

本專案為私有專案，未經授權不得使用、複製或散佈。

## 聯絡資訊

- **專案維護者**: 開發團隊
- **問題回報**: GitHub Issues
- **文檔更新**: Pull Request

---

<div align="center">

**Built with ❤️ for Taiwan's Art Community**

*讓藝術展覽資訊觸手可及*

</div>
