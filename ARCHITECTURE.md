# TaiwanArtion 架構說明文檔

**版本**: 1.0
**最後更新**: 2025-11-27

## 目錄

1. [架構概述](#架構概述)
2. [MVVM 架構模式](#mvvm-架構模式)
3. [專案結構](#專案結構)
4. [數據流程](#數據流程)
5. [依賴管理](#依賴管理)
6. [最佳實踐](#最佳實踐)

---

## 架構概述

TaiwanArtion 採用 **MVVM (Model-View-ViewModel)** 架構模式，結合 **RxSwift** 響應式編程框架，實現業務邏輯與 UI 的完全分離，提供可測試、可維護的代碼結構。

### 核心技術棧

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│    (ViewControllers + Views)        │
├─────────────────────────────────────┤
│         ViewModel Layer             │
│     (Business Logic + RxSwift)      │
├─────────────────────────────────────┤
│         Repository Layer            │
│   (Data Access + Firebase)          │
├─────────────────────────────────────┤
│          Data Layer                 │
│     (Models + Firebase SDK)         │
└─────────────────────────────────────┘
```

---

## MVVM 架構模式

### 架構圖

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│              │         │              │         │              │
│     View     │◄───────►│  ViewModel   │◄───────►│    Model     │
│              │ Binding │              │  Data   │              │
│ (ViewController)       │              │         │              │
└──────────────┘         └──────────────┘         └──────────────┘
       │                        │                         │
       │                        │                         │
   UI Events              Business Logic           Data Structure
   (Button Tap)           (Validation)             (Exhibition)
   UI Updates             (Formatting)             (User)
```

### 各層職責

#### 1. Model（模型層）

**職責**：
- 定義數據結構
- 數據驗證
- 業務規則

**範例**：

```swift
// TaiwanArtion/Model/Exhibition.swift
struct Exhibition: Codable {
    let id: String
    let title: String
    let imageUrl: String
    let startDate: String
    let endDate: String
    let location: String
    let viewCount: Int
    let rating: Double

    // 計算屬性 - 業務邏輯
    var isActive: Bool {
        // 判斷展覽是否進行中
        return Date() >= startDate.toDate() && Date() <= endDate.toDate()
    }
}
```

#### 2. View（視圖層）

**職責**：
- 顯示 UI
- 接收用戶輸入
- 將事件傳遞給 ViewModel
- 不包含業務邏輯

**範例**：

```swift
// TaiwanArtion/ViewController/HomeViewController.swift
class HomeViewController: UIViewController {
    private let homeView = HomeView()
    private let viewModel = HomeViewModel.shared
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    private func setupBindings() {
        // 綁定 ViewModel 的數據到 UI
        viewModel.outputs.hotExhibitionRelay
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: "cell")) { index, model, cell in
                // 配置 cell
            }
            .disposed(by: disposeBag)

        // 綁定 UI 事件到 ViewModel
        searchButton.rx.tap
            .bind(to: viewModel.inputs.searchTapped)
            .disposed(by: disposeBag)
    }
}
```

#### 3. ViewModel（視圖模型層）

**職責**：
- 業務邏輯處理
- 數據轉換和格式化
- 狀態管理
- 與 Repository 交互

**設計模式**：Input/Output 模式

```swift
// TaiwanArtion/ViewModel/HomeViewModel.swift

// 定義 Input 協議
protocol HomeViewModelInput {
    var monthSelected: PublishSubject<IndexPath> { get }
    var habbySelected: PublishSubject<IndexPath> { get }
    var searchTapped: PublishSubject<Void> { get }
}

// 定義 Output 協議
protocol HomeViewModelOutput {
    var hotExhibitionRelay: BehaviorRelay<[Exhibition]> { get }
    var newsRelay: BehaviorRelay<[News]> { get }
    var isLoading: BehaviorRelay<Bool> { get }
}

// ViewModel 實作
class HomeViewModel: HomeViewModelInput, HomeViewModelOutput {
    // Singleton
    static let shared = HomeViewModel()

    // Input
    let monthSelected = PublishSubject<IndexPath>()
    let habbySelected = PublishSubject<IndexPath>()
    let searchTapped = PublishSubject<Void>()

    // Output
    let hotExhibitionRelay = BehaviorRelay<[Exhibition]>(value: [])
    let newsRelay = BehaviorRelay<[News]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)

    // Dependencies
    private let database = FirebaseDatabase(collectionName: "exhibitions")
    private let disposeBag = DisposeBag()

    init() {
        setupBindings()
        fetchInitialData()
    }

    private func setupBindings() {
        // 處理月份選擇
        monthSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.fetchExhibitions(for: indexPath)
            })
            .disposed(by: disposeBag)
    }

    private func fetchInitialData() {
        isLoading.accept(true)

        database.getHotDocument(count: 10) { [weak self] data, error in
            self?.isLoading.accept(false)

            guard let data = data else { return }
            let exhibitions = data.compactMap { Exhibition(dictionary: $0) }
            self?.hotExhibitionRelay.accept(exhibitions)
        }
    }
}
```

---

## 專案結構

### 目錄結構

```
TaiwanArtion/
├── Application/
│   ├── AppDelegate.swift          # 應用程式入口
│   └── SceneDelegate.swift        # 場景管理
│
├── Model/                         # 數據模型
│   ├── Exhibition.swift
│   ├── User.swift
│   ├── News.swift
│   └── ExhibitionInfo.swift
│
├── ViewModel/                     # 業務邏輯層
│   ├── HomeViewModel.swift
│   ├── LoginViewModel.swift
│   ├── RegisterViewModel.swift
│   ├── ExhibitionViewModel.swift
│   ├── CollectViewModel.swift
│   └── ProfileViewModel.swift
│
├── ViewController/                # 視圖控制器
│   ├── Home/
│   │   ├── HomeViewController.swift
│   │   └── SearchViewController.swift
│   ├── Authentication/
│   │   ├── LoginViewController.swift
│   │   ├── RegisterViewController.swift
│   │   └── ResetPasswordViewController.swift
│   ├── Exhibition/
│   │   ├── ExhibitionCardViewController.swift
│   │   └── ExhibitionDetailViewController.swift
│   └── Profile/
│       ├── ProfileViewController.swift
│       └── SettingViewController.swift
│
├── View/                          # 自訂視圖組件
│   ├── HomeView.swift
│   ├── LoginView.swift
│   ├── ExhibitionCardView.swift
│   └── CalendarView.swift
│
├── TableViewCell/                 # TableView Cell
│   ├── ExhibitionTableViewCell.swift
│   ├── NewsTableViewCell.swift
│   └── CommentTableViewCell.swift
│
├── CollectionViewCell/            # CollectionView Cell
│   ├── ExhibitionCollectionViewCell.swift
│   ├── CategoryCollectionViewCell.swift
│   └── PhotoCollectionViewCell.swift
│
├── Firebase/                      # Firebase 整合層
│   ├── FirebaseAuth.swift        # 認證服務
│   └── FirebaseDatabase.swift    # 資料庫服務
│
├── UserFeature/                   # 用戶管理
│   ├── UserManager.swift
│   └── UserDefaultInterface.swift
│
├── Map/                           # 地圖功能
│   ├── MapViewController.swift
│   └── LocationManager.swift
│
├── Extension/                     # 擴展
│   ├── UIColor+Extension.swift
│   ├── UIView+Extension.swift
│   └── Date+Extension.swift
│
├── Enum/                          # 枚舉定義
│   ├── Month.swift
│   ├── Items.swift
│   └── HabbyItem.swift
│
└── Protocol/                      # 協議定義
    └── ReusableView.swift
```

### 模組劃分

#### 1. Core 核心模組
- **Firebase**: 數據存取層
- **UserFeature**: 用戶管理
- **Extension**: 通用擴展

#### 2. Feature 功能模組
- **Home**: 首頁功能
- **Authentication**: 認證功能
- **Exhibition**: 展覽相關功能
- **Profile**: 個人資料功能
- **Map**: 地圖導航功能

#### 3. UI 組件模組
- **View**: 自訂視圖
- **TableViewCell**: 表格 Cell
- **CollectionViewCell**: 集合 Cell

---

## 數據流程

### 1. 數據流向圖

```
User Interaction
       ↓
┌──────────────────┐
│  ViewController  │
└──────────────────┘
       ↓ (User Events)
┌──────────────────┐
│   ViewModel      │◄────── RxSwift Binding
│   (Input)        │
└──────────────────┘
       ↓ (Business Logic)
┌──────────────────┐
│   ViewModel      │
│   (Processing)   │
└──────────────────┘
       ↓ (Data Request)
┌──────────────────┐
│   Repository     │
│  (FirebaseDB)    │
└──────────────────┘
       ↓ (API Call)
┌──────────────────┐
│    Firebase      │
│    Backend       │
└──────────────────┘
       ↓ (Response)
┌──────────────────┐
│   ViewModel      │
│   (Output)       │
└──────────────────┘
       ↓ (Data Binding)
┌──────────────────┐
│  ViewController  │
└──────────────────┘
       ↓ (UI Update)
  Display to User
```

### 2. 詳細流程示例：載入展覽列表

```swift
// 步驟 1: 用戶進入首頁
HomeViewController.viewDidLoad()

// 步驟 2: ViewController 訂閱 ViewModel 的數據
viewModel.outputs.hotExhibitionRelay
    .asDriver(onErrorJustReturn: [])
    .drive(tableView.rx.items...)
    .disposed(by: disposeBag)

// 步驟 3: ViewModel 初始化時自動獲取數據
HomeViewModel.init() {
    fetchHotExhibitions()
}

// 步驟 4: ViewModel 調用 Repository
database.getHotDocument(count: 10) { data, error in
    // 處理返回的數據
}

// 步驟 5: Firebase Repository 執行查詢
db.collection("exhibitions")
    .order(by: "viewCount", descending: true)
    .limit(to: 10)
    .getDocuments()

// 步驟 6: 數據返回後，ViewModel 處理並更新 Relay
hotExhibitionRelay.accept(exhibitions)

// 步驟 7: RxSwift 自動通知 ViewController 更新 UI
// TableView 自動重新載入
```

### 3. 分頁載入流程

```swift
// 首次載入
┌─────────────┐
│  View Load  │
└─────────────┘
       ↓
┌─────────────────────────┐
│ Fetch First Page (20)   │
│ lastDoc = nil           │
└─────────────────────────┘
       ↓
┌─────────────────────────┐
│ Display Data            │
│ Store lastDocument      │
└─────────────────────────┘

// 滾動到底部
┌─────────────────────────┐
│ User Scrolls to Bottom  │
└─────────────────────────┘
       ↓
┌─────────────────────────┐
│ Fetch Next Page (20)    │
│ startAfter: lastDoc     │
└─────────────────────────┘
       ↓
┌─────────────────────────┐
│ Append Data             │
│ Update lastDocument     │
└─────────────────────────┘
```

---

## RxSwift 使用模式

### 1. Subject vs Relay

#### PublishSubject / PublishRelay
用於事件流，不保存狀態

```swift
// 用戶輸入事件
let searchTextSubject = PublishSubject<String>()

// 按鈕點擊事件
let loginButtonTapped = PublishSubject<Void>()
```

#### BehaviorSubject / BehaviorRelay
用於狀態管理，保存當前值

```swift
// 展覽列表狀態
let exhibitions = BehaviorRelay<[Exhibition]>(value: [])

// 載入狀態
let isLoading = BehaviorRelay<Bool>(value: false)

// 當前選中的月份
let currentMonth = BehaviorSubject<Month>(value: .jan)
```

### 2. Operators 常用運算子

```swift
// map - 資料轉換
searchText
    .map { $0.lowercased() }
    .subscribe(onNext: { ... })

// filter - 過濾
searchText
    .filter { $0.count > 2 }
    .subscribe(onNext: { ... })

// debounce - 防抖動（搜尋優化）
searchText
    .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
    .subscribe(onNext: { ... })

// distinctUntilChanged - 去除重複
searchText
    .distinctUntilChanged()
    .subscribe(onNext: { ... })

// flatMapLatest - 最新請求優先
searchText
    .flatMapLatest { text -> Observable<[Exhibition]> in
        return api.search(text)
    }
    .subscribe(onNext: { ... })

// combineLatest - 組合多個流
Observable.combineLatest(
    categorySelected,
    monthSelected,
    locationSelected
) { category, month, location in
    return FilterCriteria(category, month, location)
}
.subscribe(onNext: { ... })
```

### 3. Driver - UI 綁定專用

Driver 確保：
- 在主線程執行
- 不會產生錯誤
- 共享訂閱（share）

```swift
// ViewModel
let exhibitions: Driver<[Exhibition]>

// ViewController
viewModel.exhibitions
    .drive(tableView.rx.items(cellIdentifier: "cell")) { index, model, cell in
        // 配置 cell
    }
    .disposed(by: disposeBag)
```

### 4. 記憶體管理

```swift
// ✅ 正確做法
button.rx.tap
    .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.handleTap()
    })
    .disposed(by: disposeBag)

// ❌ 錯誤做法 - 造成 retain cycle
button.rx.tap
    .subscribe(onNext: {
        self.handleTap()  // 強引用 self
    })
    .disposed(by: disposeBag)
```

---

## 依賴管理

### CocoaPods 配置

```ruby
platform :ios, '13.0'
use_frameworks!

target 'TaiwanArtion' do
  # UI 框架
  pod 'SnapKit', '~> 5.7'
  pod 'Kingfisher', '~> 7.0'

  # 響應式編程
  pod 'RxSwift', '~> 6.7'
  pod 'RxCocoa', '~> 6.7'
  pod 'RxRelay', '~> 6.7'
  pod 'RxGesture', '~> 4.0'
  pod 'RxDataSources', '~> 5.0'

  # Firebase
  pod 'FirebaseAnalytics', '~> 11.0'
  pod 'FirebaseAuth', '~> 11.0'
  pod 'FirebaseFirestore', '~> 11.0'

  # 第三方登入
  pod 'GoogleSignIn', '~> 8.0'
  pod 'FBSDKCoreKit', '~> 17.0'
  pod 'FBSDKLoginKit', '~> 17.0'
end
```

### 依賴關係圖

```
ViewController
    ↓ depends on
ViewModel
    ↓ depends on
Repository (FirebaseDatabase)
    ↓ depends on
Firebase SDK
```

---

## 最佳實踐

### 1. ViewModel 設計原則

#### ✅ 單一職責原則

```swift
// ✅ 好的做法 - 每個 ViewModel 負責單一功能
class LoginViewModel {
    // 只處理登入相關邏輯
}

class RegisterViewModel {
    // 只處理註冊相關邏輯
}

// ❌ 避免
class AuthViewModel {
    // 混合登入、註冊、重設密碼等多個功能
}
```

#### ✅ Input/Output 明確分離

```swift
protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    var input: Input { get }
    var output: Output { get }
}

class LoginViewModel: ViewModelType {
    struct Input {
        let emailText: PublishSubject<String>
        let passwordText: PublishSubject<String>
        let loginButtonTapped: PublishSubject<Void>
    }

    struct Output {
        let isLoginEnabled: Driver<Bool>
        let loginSuccess: Driver<Bool>
        let errorMessage: Driver<String?>
    }

    let input: Input
    let output: Output
}
```

### 2. Repository 模式

```swift
protocol ExhibitionRepository {
    func getExhibitions(page: Int) -> Observable<[Exhibition]>
    func getExhibition(id: String) -> Observable<Exhibition>
    func search(keyword: String) -> Observable<[Exhibition]>
}

class FirebaseExhibitionRepository: ExhibitionRepository {
    private let database: FirebaseDatabase

    func getExhibitions(page: Int) -> Observable<[Exhibition]> {
        return Observable.create { observer in
            self.database.getPaginatedDocuments(pageSize: 20) { data, lastDoc, error in
                if let error = error {
                    observer.onError(error)
                } else if let data = data {
                    let exhibitions = data.compactMap { Exhibition(dictionary: $0) }
                    observer.onNext(exhibitions)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
```

### 3. 錯誤處理

```swift
enum AppError: Error {
    case networkError
    case invalidData
    case unauthorized
    case unknown(Error)

    var localizedDescription: String {
        switch self {
        case .networkError:
            return "網路連線錯誤"
        case .invalidData:
            return "資料格式錯誤"
        case .unauthorized:
            return "請重新登入"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// 使用
viewModel.errorMessage
    .drive(onNext: { [weak self] message in
        self?.showAlert(message: message)
    })
    .disposed(by: disposeBag)
```

### 4. 測試友好設計

```swift
// 使用協議定義依賴，方便 Mock
protocol DatabaseService {
    func getExhibitions() -> Observable<[Exhibition]>
}

class HomeViewModel {
    private let database: DatabaseService

    init(database: DatabaseService = FirebaseDatabase()) {
        self.database = database
    }
}

// 測試時注入 Mock
class MockDatabase: DatabaseService {
    func getExhibitions() -> Observable<[Exhibition]> {
        return .just([mockExhibition1, mockExhibition2])
    }
}

// Unit Test
func testFetchExhibitions() {
    let mockDB = MockDatabase()
    let viewModel = HomeViewModel(database: mockDB)

    // 驗證邏輯
}
```

---

## 性能優化要點

### 1. RxSwift 優化

```swift
// ✅ 使用 Driver 避免重複訂閱
let exhibitions = exhibitionsRelay
    .asDriver(onErrorJustReturn: [])

exhibitions.drive(tableView.rx.items...)
exhibitions.drive(collectionView.rx.items...)

// ❌ 避免 - 會產生多個訂閱
exhibitionsRelay.subscribe(...)
exhibitionsRelay.subscribe(...)
```

### 2. Firebase 查詢優化

```swift
// ✅ 使用分頁和限制
db.collection("exhibitions")
    .limit(to: 20)
    .startAfter(lastDocument)

// ❌ 避免 - 獲取所有資料
db.collection("exhibitions")
    .getDocuments()
```

### 3. 圖片載入優化

```swift
// ✅ 使用降採樣
imageView.kf.setImage(
    with: url,
    options: [
        .processor(DownsamplingImageProcessor(size: targetSize)),
        .backgroundDecode
    ]
)

// ❌ 避免 - 載入原始大小
imageView.kf.setImage(with: url)
```

---

## 相關資源

### 官方文檔
- [RxSwift 文檔](https://github.com/ReactiveX/RxSwift)
- [Firebase iOS SDK](https://firebase.google.com/docs/ios/setup)
- [MVVM 設計模式](https://www.raywenderlich.com/34-design-patterns-by-tutorials-mvvm)

### 推薦閱讀
- [Advanced RxSwift](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/Tips.md)
- [Clean Architecture in iOS](https://clean-swift.com)

---

**文檔版本**: 1.0
**維護者**: 開發團隊
**最後更新**: 2025-11-27
