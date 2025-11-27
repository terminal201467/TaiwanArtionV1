# TaiwanArtionV1 Spec-Kit 開發規範文檔

> **文檔版本**: 1.0.0
> **生成日期**: 2025-11-27
> **適用範圍**: TaiwanArtionV1 專案翻新與後續開發

---

## 目錄

1. [專案概述](#專案概述)
2. [技術規範](#技術規範)
3. [架構設計](#架構設計)
4. [開發環境](#開發環境)
5. [編碼規範](#編碼規範)
6. [API 設計](#api-設計)
7. [數據模型](#數據模型)
8. [UI/UX 規範](#uiux-規範)
9. [測試策略](#測試策略)
10. [部署流程](#部署流程)
11. [安全性規範](#安全性規範)
12. [效能標準](#效能標準)

---

## 專案概述

### 專案資訊
- **專案名稱**: 早找展覽 (TaiwanArtion)
- **專案類型**: iOS 原生應用程式
- **目標用戶**: 台灣地區對藝術展覽感興趣的用戶
- **核心功能**: 展覽資訊瀏覽、收藏、評價、地圖導航

### 專案目標
1. 提供便捷的展覽資訊查詢平台
2. 整合地圖功能幫助用戶找到展覽地點
3. 建立用戶評價系統提升展覽品質
4. 支援多種登入方式提升用戶體驗

### 技術特色
- MVVM 架構模式
- RxSwift 響應式編程
- Firebase 後端服務
- 自訂月曆組件
- 地圖整合

---

## 技術規範

### 開發語言與版本

| 項目 | 版本要求 | 備註 |
|------|---------|------|
| Swift | 5.0+ | 使用最新語言特性 |
| iOS Deployment Target | 13.0+ | 支援主流設備 |
| Xcode | 14.0+ | 使用最新穩定版 |

### 依賴管理

#### 套件管理器
- **主要**: CocoaPods 1.12.1+
- **考慮遷移**: Swift Package Manager (SPM)

#### 核心依賴

```ruby
# Podfile
platform :ios, '13.0'
use_frameworks!

target 'TaiwanArtion' do
  # UI 佈局
  pod 'SnapKit', '~> 5.6.0'

  # 響應式編程
  pod 'RxSwift', '~> 6.7.0'
  pod 'RxCocoa', '~> 6.7.0'
  pod 'RxRelay', '~> 6.7.0'
  pod 'RxGesture'
  pod 'RxDataSources', '~> 5.0'

  # 圖片處理
  pod 'Kingfisher', '~> 7.0'

  # Firebase
  pod 'Firebase/Core', '~> 11.0'
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'

  # 第三方登入
  pod 'GoogleSignIn', '~> 7.0'
  pod 'FBSDKCoreKit', '~> 16.0'
  pod 'FBSDKLoginKit', '~> 16.0'

  # 日誌系統（新增）
  pod 'CocoaLumberjack/Swift', '~> 3.8'
end

target 'TaiwanArtionTests' do
  inherit! :search_paths
  # 測試框架
  pod 'RxTest'
  pod 'RxBlocking'
end
```

### 移除的依賴
- ❌ **LineSDKSwift**: 未使用，建議移除以減少 App 大小

---

## 架構設計

### MVVM 架構模式

```
┌─────────────────────────────────────────┐
│              View Layer                  │
│  (ViewController + View + Cell)          │
│  - 負責 UI 顯示和用戶交互                │
│  - 不包含業務邏輯                        │
└──────────────┬──────────────────────────┘
               │ Binding (RxSwift)
┌──────────────▼──────────────────────────┐
│           ViewModel Layer                │
│  - 處理業務邏輯                          │
│  - 數據轉換和格式化                      │
│  - 狀態管理                              │
└──────────────┬──────────────────────────┘
               │ Data Request
┌──────────────▼──────────────────────────┐
│            Model Layer                   │
│  (Repository + Service)                  │
│  - Firebase 數據存取                     │
│  - 本地數據緩存                          │
│  - 網路請求                              │
└─────────────────────────────────────────┘
```

### 目錄結構規範

```
TaiwanArtion/
│
├── Application/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
│
├── Modules/                    # 按功能模組組織
│   ├── Auth/                   # 認證模組
│   │   ├── ViewControllers/
│   │   ├── ViewModels/
│   │   ├── Views/
│   │   └── Models/
│   │
│   ├── Exhibition/             # 展覽模組
│   │   ├── ViewControllers/
│   │   ├── ViewModels/
│   │   ├── Views/
│   │   └── Models/
│   │
│   ├── Map/                    # 地圖模組
│   ├── Profile/                # 個人資料模組
│   └── Collection/             # 收藏模組
│
├── Core/                       # 核心功能
│   ├── Network/
│   │   ├── Firebase/
│   │   │   ├── FirebaseAuth.swift
│   │   │   └── FirebaseDatabase.swift
│   │   └── APIManager.swift
│   │
│   ├── Storage/
│   │   ├── UserDefaultsManager.swift
│   │   ├── KeychainManager.swift      # 新增
│   │   └── CacheManager.swift
│   │
│   ├── Logger/                 # 新增：統一日誌系統
│   │   └── AppLogger.swift
│   │
│   └── Configuration/          # 新增：配置管理
│       ├── Environment.swift
│       └── AppConfig.swift
│
├── Shared/                     # 共用組件
│   ├── Extensions/
│   ├── Protocols/
│   ├── Enums/
│   ├── Constants/
│   └── Utilities/
│
├── UIComponents/               # 通用 UI 組件
│   ├── CustomViews/
│   │   ├── Calendar/
│   │   └── LoadingView/
│   ├── TableViewCells/
│   ├── CollectionViewCells/
│   └── Alerts/
│
└── Resources/                  # 資源檔案
    ├── Assets.xcassets/
    ├── Localizations/
    └── Configurations/
        ├── GoogleService-Info.plist    # ⚠️ 加入 .gitignore
        └── Info.plist
```

### 命名規範

#### 檔案命名
```
- ViewController: {功能名}ViewController.swift
  例: ExhibitionDetailViewController.swift

- ViewModel: {功能名}ViewModel.swift
  例: ExhibitionDetailViewModel.swift

- View: {功能名}View.swift
  例: ExhibitionCardView.swift

- Model: {名稱}.swift
  例: Exhibition.swift

- Cell: {功能名}Cell.swift
  例: ExhibitionListCell.swift

- Protocol: {名稱}Protocol.swift 或 {名稱}able.swift
  例: DataFetchable.swift
```

#### 類別命名
```swift
// ViewController
class ExhibitionDetailViewController: UIViewController { }

// ViewModel
class ExhibitionDetailViewModel { }

// View
class ExhibitionCardView: UIView { }

// Model
struct Exhibition: Codable { }

// Protocol
protocol DataFetchable { }
```

#### 變數命名
```swift
// 屬性使用 camelCase
let exhibitionTitle: String
var isLoading: Bool

// 常數使用 UPPER_SNAKE_CASE
let MAX_RETRY_COUNT = 3
let API_TIMEOUT_INTERVAL: TimeInterval = 30

// RxSwift Subject/Relay 使用 Relay 後綴
let loadingRelay = BehaviorRelay<Bool>(value: false)
let dataSubject = PublishSubject<[Exhibition]>()

// DisposeBag 統一命名
private let disposeBag = DisposeBag()
```

---

## 開發環境

### 環境配置

#### 開發環境 (Development)
```swift
// Environment.swift
enum Environment {
    case development
    case staging
    case production

    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    var firebaseConfig: String {
        switch self {
        case .development:
            return "GoogleService-Info-Dev"
        case .staging:
            return "GoogleService-Info-Staging"
        case .production:
            return "GoogleService-Info"
        }
    }
}
```

#### .gitignore 設定
```gitignore
# Firebase 配置檔（敏感資訊）
GoogleService-Info.plist
GoogleService-Info-Dev.plist
GoogleService-Info-Staging.plist

# 環境變數
.env
.env.local

# Xcode
*.xcuserstate
xcuserdata/
DerivedData/

# CocoaPods
Pods/
Podfile.lock

# Swift Package Manager
.build/
.swiftpm/

# macOS
.DS_Store
```

### 開發工具

#### 必備工具
- **Xcode** 14.0+
- **CocoaPods** 1.12.1+
- **Git** 2.30+

#### 推薦工具
- **SwiftLint**: 代碼風格檢查
- **Sourcery**: 代碼生成
- **Fastlane**: 自動化部署
- **Charles/Proxyman**: 網路除錯

---

## 編碼規範

### Swift 代碼風格

#### 基本規則
```swift
// ✅ 推薦
class ExhibitionViewModel {
    private let repository: ExhibitionRepository
    private let disposeBag = DisposeBag()

    init(repository: ExhibitionRepository) {
        self.repository = repository
    }
}

// ❌ 避免
class ExhibitionViewModel {
    var repository: ExhibitionRepository!  // 避免隱式解包
}
```

#### 可選值處理
```swift
// ✅ 使用 guard let
func processExhibition(_ exhibition: Exhibition?) {
    guard let exhibition = exhibition else { return }
    // 處理邏輯
}

// ✅ 使用 if let（簡單情況）
if let title = exhibition?.title {
    print(title)
}

// ❌ 避免強制解包
let title = exhibition!.title  // 避免！
```

#### 錯誤處理
```swift
// ✅ 完整的錯誤處理
func fetchExhibitions() {
    repository.getExhibitions()
        .observe(on: MainScheduler.instance)
        .subscribe(
            onNext: { [weak self] exhibitions in
                self?.handleSuccess(exhibitions)
            },
            onError: { [weak self] error in
                self?.handleError(error)
            }
        )
        .disposed(by: disposeBag)
}

private func handleError(_ error: Error) {
    AppLogger.error("Failed to fetch exhibitions: \(error)")
    // 顯示用戶友好的錯誤訊息
}
```

### RxSwift 使用規範

#### DisposeBag 管理
```swift
// ✅ 每個 ViewController/ViewModel 有自己的 DisposeBag
class ExhibitionViewController: UIViewController {
    private let disposeBag = DisposeBag()

    deinit {
        AppLogger.debug("ExhibitionViewController deinit")
    }
}
```

#### 避免記憶體洩漏
```swift
// ✅ 使用 [weak self]
button.rx.tap
    .subscribe(onNext: { [weak self] in
        self?.handleButtonTap()
    })
    .disposed(by: disposeBag)

// ❌ 避免強引用
button.rx.tap
    .subscribe(onNext: {
        self.handleButtonTap()  // 記憶體洩漏
    })
    .disposed(by: disposeBag)
```

#### Observable 命名規範
```swift
// ✅ 使用清晰的名稱
let exhibitionListObservable: Observable<[Exhibition]>
let loadingStateRelay = BehaviorRelay<Bool>(value: false)
let errorSubject = PublishSubject<Error>()

// 輸入/輸出結構
struct Input {
    let viewDidLoad: Observable<Void>
    let refreshTrigger: Observable<Void>
}

struct Output {
    let exhibitions: Driver<[Exhibition]>
    let isLoading: Driver<Bool>
    let error: Driver<Error>
}
```

### 日誌系統

#### 統一日誌介面
```swift
// AppLogger.swift
import CocoaLumberjack

class AppLogger {
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        DDLogDebug("[\(sourceFileName(filePath: file))]:\(line) \(function) - \(message)")
    }

    static func info(_ message: String) {
        DDLogInfo(message)
    }

    static func warning(_ message: String) {
        DDLogWarn(message)
    }

    static func error(_ message: String) {
        DDLogError(message)
    }

    private static func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

// 使用範例
AppLogger.debug("View did load")
AppLogger.error("Failed to fetch data: \(error)")
```

#### 禁止使用 print()
```swift
// ❌ 禁止
print("Debug message")

// ✅ 使用 AppLogger
AppLogger.debug("Debug message")
```

---

## API 設計

### Firebase Firestore 結構

#### 集合結構
```
exhibitions/                    # 展覽集合
  └── {exhibitionId}/
      ├── title: String
      ├── description: String
      ├── startDate: Timestamp
      ├── endDate: Timestamp
      ├── location: GeoPoint
      ├── address: String
      ├── category: String
      ├── imageURL: String
      ├── rating: Number
      └── createdAt: Timestamp

users/                          # 用戶集合
  └── {userId}/
      ├── email: String
      ├── displayName: String
      ├── photoURL: String
      ├── favorites: Array<String>  # Exhibition IDs
      ├── searchHistory: Array<String>
      └── createdAt: Timestamp

reviews/                        # 評價集合
  └── {reviewId}/
      ├── exhibitionId: String
      ├── userId: String
      ├── rating: Number
      ├── content: Map
      │   ├── richness: Number
      │   ├── equipment: Number
      │   ├── location: Number
      │   ├── price: Number
      │   └── service: Number
      ├── comment: String
      └── createdAt: Timestamp
```

### Firebase 操作規範

#### Repository Pattern
```swift
protocol ExhibitionRepository {
    func getExhibitions() -> Observable<[Exhibition]>
    func getExhibition(id: String) -> Observable<Exhibition>
    func searchExhibitions(keyword: String) -> Observable<[Exhibition]>
    func getPopularExhibitions() -> Observable<[Exhibition]>
    func getHighRatedExhibitions() -> Observable<[Exhibition]>
}

class FirebaseExhibitionRepository: ExhibitionRepository {
    private let db = Firestore.firestore()

    func getExhibitions() -> Observable<[Exhibition]> {
        return Observable.create { observer in
            let listener = self.db.collection("exhibitions")
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }

                    guard let documents = querySnapshot?.documents else {
                        observer.onNext([])
                        return
                    }

                    let exhibitions = documents.compactMap { document -> Exhibition? in
                        try? document.data(as: Exhibition.self)
                    }

                    observer.onNext(exhibitions)
                }

            return Disposables.create {
                listener.remove()
            }
        }
    }

    // 實作熱門展覽查詢
    func getPopularExhibitions() -> Observable<[Exhibition]> {
        return Observable.create { observer in
            self.db.collection("exhibitions")
                .order(by: "viewCount", descending: true)
                .limit(to: 10)
                .getDocuments { querySnapshot, error in
                    // 處理邏輯
                }

            return Disposables.create()
        }
    }
}
```

#### 錯誤處理
```swift
enum FirebaseError: Error {
    case networkError
    case authenticationFailed
    case documentNotFound
    case permissionDenied
    case unknown(Error)

    var localizedDescription: String {
        switch self {
        case .networkError:
            return "網路連線失敗，請檢查您的網路設定"
        case .authenticationFailed:
            return "身份驗證失敗，請重新登入"
        case .documentNotFound:
            return "找不到資料"
        case .permissionDenied:
            return "權限不足"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
```

---

## 數據模型

### 模型定義

#### Exhibition Model
```swift
struct Exhibition: Codable {
    let id: String
    let title: String
    let description: String
    let startDate: Date
    let endDate: Date
    let location: Location
    let address: String
    let category: ExhibitionCategory
    let imageURL: String
    let rating: Double
    let viewCount: Int
    let createdAt: Date

    struct Location: Codable {
        let latitude: Double
        let longitude: Double
    }
}

enum ExhibitionCategory: String, Codable {
    case art = "藝術展覽"
    case design = "設計展覽"
    case photography = "攝影展覽"
    case sculpture = "雕塑展覽"
    case multimedia = "多媒體展覽"
}
```

#### User Model
```swift
struct User: Codable {
    let id: String
    let email: String
    let displayName: String
    let photoURL: String?
    let favorites: [String]  // Exhibition IDs
    let searchHistory: [String]
    let createdAt: Date
}
```

#### Review Model
```swift
struct Review: Codable {
    let id: String
    let exhibitionId: String
    let userId: String
    let rating: Double
    let content: ReviewContent
    let comment: String
    let createdAt: Date

    struct ReviewContent: Codable {
        let richness: Int      // 內容豐富度 (1-5)
        let equipment: Int     // 設備 (1-5)
        let location: Int      // 地理位置 (1-5)
        let price: Int         // 價格 (1-5)
        let service: Int       // 服務 (1-5)

        var averageRating: Double {
            Double(richness + equipment + location + price + service) / 5.0
        }
    }
}
```

---

## UI/UX 規範

### 設計系統

#### 顏色規範
```swift
// ColorManager.swift
enum AppColor {
    // 主色
    static let primary = UIColor(hex: "#YOUR_PRIMARY_COLOR")
    static let secondary = UIColor(hex: "#YOUR_SECONDARY_COLOR")

    // 語意顏色
    static let success = UIColor.systemGreen
    static let warning = UIColor.systemOrange
    static let error = UIColor.systemRed

    // 中性色
    static let background = UIColor.systemBackground
    static let secondaryBackground = UIColor.secondarySystemBackground
    static let text = UIColor.label
    static let secondaryText = UIColor.secondaryLabel
}
```

#### 字體規範
```swift
// FontManager.swift
enum AppFont {
    static func regular(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func medium(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func bold(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

    // 預設字體大小
    static let title1 = bold(size: 28)
    static let title2 = bold(size: 22)
    static let title3 = bold(size: 20)
    static let headline = medium(size: 17)
    static let body = regular(size: 17)
    static let callout = regular(size: 16)
    static let subheadline = regular(size: 15)
    static let footnote = regular(size: 13)
    static let caption = regular(size: 12)
}
```

#### 間距規範
```swift
enum Spacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
}
```

### UI 組件規範

#### 按鈕
```swift
// PrimaryButton.swift
class PrimaryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = AppColor.primary
        setTitleColor(.white, for: .normal)
        titleLabel?.font = AppFont.headline
        layer.cornerRadius = 8

        // 添加陰影
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
    }
}
```

#### 載入指示器
```swift
// LoadingView.swift
class LoadingView: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()

    func show(message: String = "載入中...") {
        // 顯示邏輯
    }

    func hide() {
        // 隱藏邏輯
    }
}
```

---

## 測試策略

### 單元測試

#### ViewModel 測試
```swift
import XCTest
import RxSwift
import RxTest
@testable import TaiwanArtion

class ExhibitionViewModelTests: XCTestCase {
    var viewModel: ExhibitionViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var mockRepository: MockExhibitionRepository!

    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        mockRepository = MockExhibitionRepository()
        viewModel = ExhibitionViewModel(repository: mockRepository)
    }

    func testFetchExhibitions_Success() {
        // Given
        let expectedExhibitions = [Exhibition.mock()]
        mockRepository.exhibitionsToReturn = expectedExhibitions

        // When
        let observer = scheduler.createObserver([Exhibition].self)
        viewModel.exhibitions
            .bind(to: observer)
            .disposed(by: disposeBag)

        viewModel.fetchExhibitions()
        scheduler.start()

        // Then
        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer.events.first?.value.element?.count, expectedExhibitions.count)
    }
}

// Mock Repository
class MockExhibitionRepository: ExhibitionRepository {
    var exhibitionsToReturn: [Exhibition] = []
    var errorToThrow: Error?

    func getExhibitions() -> Observable<[Exhibition]> {
        if let error = errorToThrow {
            return Observable.error(error)
        }
        return Observable.just(exhibitionsToReturn)
    }
}
```

#### 測試覆蓋率目標
- **ViewModel**: 70%+
- **Repository**: 60%+
- **Utility**: 80%+
- **整體**: 60%+

### UI 測試

#### 關鍵流程測試
```swift
class LoginFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testLoginWithEmail_Success() {
        // Given
        let emailTextField = app.textFields["email"]
        let passwordTextField = app.secureTextFields["password"]
        let loginButton = app.buttons["login"]

        // When
        emailTextField.tap()
        emailTextField.typeText("test@example.com")

        passwordTextField.tap()
        passwordTextField.typeText("password123")

        loginButton.tap()

        // Then
        XCTAssertTrue(app.navigationBars["首頁"].exists)
    }
}
```

---

## 部署流程

### 版本號管理

#### 語意化版本
```
主版本.次版本.修訂號 (build)
例: 1.2.3 (100)

- 主版本: 重大功能變更或不相容的 API 變更
- 次版本: 新增功能，向下相容
- 修訂號: Bug 修復，向下相容
- build: 自動遞增的建構號
```

### CI/CD 流程

#### Fastlane 配置
```ruby
# Fastfile
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    scan(
      scheme: "TaiwanArtion",
      clean: true
    )
  end

  desc "Build for testing"
  lane :build_for_testing do
    gym(
      scheme: "TaiwanArtion",
      configuration: "Debug",
      clean: true
    )
  end

  desc "Deploy to TestFlight"
  lane :beta do
    # 確保代碼最新
    ensure_git_status_clean

    # 執行測試
    test

    # 增加 build number
    increment_build_number

    # 建構
    gym(
      scheme: "TaiwanArtion",
      configuration: "Release",
      clean: true,
      export_method: "app-store"
    )

    # 上傳到 TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )

    # 提交版本變更
    commit_version_bump
    push_to_git_remote
  end
end
```

### 發布檢查清單

#### Pre-Release Checklist
- [ ] 所有測試通過
- [ ] 代碼審查完成
- [ ] 無 TODO/FIXME 註解
- [ ] 移除所有 print() 語句
- [ ] 移除測試代碼和 debug 設定
- [ ] 更新版本號和 Changelog
- [ ] 更新 README 和文檔
- [ ] 檢查敏感資訊是否已移除
- [ ] 效能測試通過
- [ ] 記憶體洩漏檢查
- [ ] App Store 截圖和描述更新

---

## 安全性規範

### API Key 管理

#### 環境變數設定
```swift
// AppConfig.swift
struct AppConfig {
    static let googleAPIKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_API_KEY") as? String else {
            fatalError("GOOGLE_API_KEY not found in Info.plist")
        }
        return key
    }()

    static let facebookAppID: String = {
        guard let id = Bundle.main.object(forInfoDictionaryKey: "FACEBOOK_APP_ID") as? String else {
            fatalError("FACEBOOK_APP_ID not found in Info.plist")
        }
        return id
    }()
}

// Info.plist (使用環境變數)
<key>GOOGLE_API_KEY</key>
<string>$(GOOGLE_API_KEY)</string>
```

#### Keychain 使用
```swift
// KeychainManager.swift
import Security

class KeychainManager {
    static let shared = KeychainManager()

    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }
}

// 使用範例
KeychainManager.shared.save(key: "authToken", value: token)
let token = KeychainManager.shared.get(key: "authToken")
```

### Firebase 安全規則

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 展覽集合 - 所有人可讀，只有管理員可寫
    match /exhibitions/{exhibitionId} {
      allow read: if true;
      allow write: if request.auth != null &&
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // 用戶集合 - 只能讀寫自己的資料
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // 評價集合 - 已登入用戶可讀可寫
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
                               resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 效能標準

### 效能指標

| 指標 | 目標值 | 測量方式 |
|------|--------|---------|
| 啟動時間 | < 2 秒 | Xcode Instruments |
| 畫面幀率 | 60 FPS | Core Animation Instrument |
| 記憶體使用 | < 150 MB | Memory Instrument |
| API 回應時間 | < 1 秒 | Network Profiler |
| 圖片載入時間 | < 500 ms | Kingfisher Metrics |

### 效能優化策略

#### 圖片優化
```swift
// Kingfisher 配置
let cache = ImageCache.default
cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024  // 100 MB
cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024  // 500 MB

// 圖片載入
imageView.kf.setImage(
    with: URL(string: imageURL),
    placeholder: UIImage(named: "placeholder"),
    options: [
        .transition(.fade(0.2)),
        .cacheOriginalImage,
        .scaleFactor(UIScreen.main.scale)
    ]
)
```

#### 列表優化
```swift
// Cell 重用
tableView.register(ExhibitionCell.self, forCellReuseIdentifier: "cell")

// 預估高度（避免計算所有 cell 高度）
tableView.estimatedRowHeight = 100
tableView.rowHeight = UITableView.automaticDimension

// 分頁載入
func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == exhibitions.count - 5 {
        loadMoreExhibitions()
    }
}
```

#### Firebase 查詢優化
```swift
// 使用限制和分頁
db.collection("exhibitions")
    .order(by: "createdAt", descending: true)
    .limit(to: 20)
    .getDocuments()

// 使用索引（在 Firebase Console 設定）
// Composite Index: category + createdAt
db.collection("exhibitions")
    .whereField("category", isEqualTo: "art")
    .order(by: "createdAt", descending: true)
    .getDocuments()
```

---

## 附錄

### 相關文檔
- [PROJECT_ANALYSIS_REPORT.md](PROJECT_ANALYSIS_REPORT.md) - 詳細專案分析
- [TODO_CHECKLIST.md](TODO_CHECKLIST.md) - 完整待辦事項
- [PHASE_1_SECURITY.md](PHASE_1_SECURITY.md) - 安全性修復指南

### 常見問題

#### Q: 為什麼不使用 SwiftUI？
A: 專案開始時使用 UIKit，遷移成本較高。新功能可以考慮使用 SwiftUI。

#### Q: 為什麼選擇 RxSwift 而不是 Combine？
A: 專案開始時 Combine 尚不成熟。後續可考慮逐步遷移到 Combine。

#### Q: 如何處理 Firebase 配額限制？
A: 實作本地快取、限制查詢頻率、使用分頁載入。

---

*本文檔會隨著專案發展持續更新*

**文檔維護者**: 開發團隊
**最後更新**: 2025-11-27
