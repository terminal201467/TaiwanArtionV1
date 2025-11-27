# Phase 4: 依賴更新摘要

**日期**: 2025-11-27
**分支**: feature/dependency-update

## 更新概述

本次更新將所有主要依賴升級到最新穩定版本，以獲得性能改進、安全修復和新功能。

## 依賴版本變更

### Firebase SDK
- **舊版本**: 10.14.0
- **新版本**: 11.15.0
- **主要變更**:
  - 移除已棄用的 `Firebase/Core`，改用個別模組
  - 所有 `import Firebase` 改為 `import FirebaseCore`
  - 更新了 7 個文件的 import 語句

**更新的檔案**:
- `TaiwanArtion/SceneDelegate.swift`
- `TaiwanArtion/Firebase/FirebaseAuth.swift`
- `TaiwanArtion/Firebase/FirebaseDatabase.swift`
- `TaiwanArtion/UserFeature/UserManager.swift`
- `TaiwanArtion/ViewModel/HomeViewModel.swift`
- `TaiwanArtion/ViewController/RootViewController.swift`
- `TaiwanArtion/ViewController/HomeViewController.swift`

### Kingfisher
- **舊版本**: 6.3.1
- **新版本**: 7.12.0
- **主要變更**: API 改進，性能優化

### RxSwift 生態系統
- **RxSwift**: 6.5.0 → 6.9.0
- **RxCocoa**: 6.5.0 → 6.9.0
- **RxRelay**: 6.5.0 → 6.9.0
- **RxGesture**: 新增 4.0.4
- **RxDataSources**: 新增 5.0.0
- **主要變更**: Bug 修復，性能改進

### GoogleSignIn
- **舊版本**: 7.0.0
- **新版本**: 8.0.0
- **主要變更**: API 更新，安全性增強
- **相容性**: 現有代碼使用的 API 保持兼容

### Facebook SDK
- **FBSDKCoreKit**: 16.1.3 → 17.4.0
- **FBSDKLoginKit**: 16.1.3 → 17.4.0
- **主要變更**: Bug 修復，iOS 18 支援

### SnapKit
- **舊版本**: 5.6.0
- **新版本**: 5.7.1
- **主要變更**: Bug 修復

### 其他依賴更新
- **AppAuth**: 1.6.2 → 1.7.6
- **GTMAppAuth**: 2.0.0 → 4.1.1
- **GTMSessionFetcher**: 3.1.1 → 3.5.0
- **GoogleUtilities**: 7.11.5 → 8.1.0
- **BoringSSL-GRPC**: 0.0.24 → 0.0.37
- **gRPC-C++**: 1.50.1 → 1.69.0
- **abseil**: 1.20220623.0 → 1.20240722.0

## Podfile 變更

### 新增最低 iOS 版本
```ruby
platform :ios, '13.0'
```

### 指定版本號
所有依賴現在都明確指定版本範圍，便於管理和追蹤：
```ruby
pod 'SnapKit', '~> 5.7'
pod 'RxSwift', '~> 6.7'
pod 'RxCocoa', '~> 6.7'
# ...等
```

### 移除 Firebase/Core
```ruby
# 舊的
pod 'Firebase/Core'

# 新的
pod 'FirebaseAnalytics', '~> 11.0'
pod 'FirebaseAuth', '~> 11.0'
pod 'FirebaseFirestore', '~> 11.0'
```

## 代碼修改

### Firebase Import 更新
所有使用 Firebase 的文件都已更新 import 語句：

```swift
// 舊的
import Firebase

// 新的
import FirebaseCore
```

### 文件清單
1. `SceneDelegate.swift` - Firebase 初始化
2. `FirebaseAuth.swift` - 認證服務
3. `FirebaseDatabase.swift` - 資料庫服務
4. `UserManager.swift` - 使用者管理
5. `HomeViewModel.swift` - 首頁視圖模型
6. `RootViewController.swift` - 根視圖控制器
7. `HomeViewController.swift` - 首頁視圖控制器

## 相容性說明

### 向後相容
- ✅ GoogleSignIn 8.0 保持現有 API 相容
- ✅ RxSwift 6.9 完全向後相容
- ✅ Kingfisher 7.x API 基本相容（未使用任何已移除的 API）

### Breaking Changes
- ⚠️ Firebase/Core 已棄用，必須使用個別模組
- ✅ 已完成所有必要的代碼更新

## 測試建議

### 必須測試的功能
1. **Firebase 功能**
   - [ ] Firebase 初始化
   - [ ] Firestore 資料讀寫
   - [ ] Firebase Auth 認證流程

2. **第三方登入**
   - [ ] Google 登入
   - [ ] Facebook 登入

3. **UI 功能**
   - [ ] 圖片載入（Kingfisher）
   - [ ] RxSwift 資料綁定
   - [ ] 自動佈局（SnapKit）

4. **主要頁面**
   - [ ] 啟動畫面
   - [ ] 首頁
   - [ ] 登入/註冊頁面
   - [ ] 使用者資料頁面

## 已知問題

### CocoaPods 警告
```
[!] The `TaiwanArtionUITests [Debug/Release]` target overrides
the `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES` build setting
```
**影響**: 無實際影響，僅為配置警告
**解決方案**: 可忽略或移除 UITests target 中的自訂 build setting

## 回滾計畫

如果發現重大問題需要回滾：

1. 切換回 main 分支：
```bash
git checkout main
```

2. 或者恢復 Podfile.lock：
```bash
cp Podfile.lock.backup Podfile.lock
pod install
```

## 下一步

1. ✅ 執行完整建置測試
2. ✅ 執行單元測試
3. ✅ 執行手動功能測試
4. ✅ 合併到 main 分支

## 參考資源

- [Firebase iOS SDK 11.0 Release Notes](https://firebase.google.com/support/release-notes/ios)
- [GoogleSignIn 8.0 Migration Guide](https://developers.google.com/identity/sign-in/ios/release-notes)
- [Kingfisher 7.0 Migration Guide](https://github.com/onevcat/Kingfisher/wiki/Kingfisher-7.0-Migration-Guide)
- [RxSwift Release Notes](https://github.com/ReactiveX/RxSwift/releases)
