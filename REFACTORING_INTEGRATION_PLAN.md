# TaiwanArtion 重構整合計劃

> **建立日期**: 2025-11-28
> **策略**: 在實作 AI 推薦系統的同時，分階段重構現有代碼
> **總工時**: ~177 小時 (分散在 6 個 Phase 中)

---

## 📊 重構總覽

### 發現的主要問題

| 類別 | 問題數量 | 總工時 | 影響程度 |
|------|---------|--------|---------|
| **RxSwift 記憶體洩漏** | 19 個 ViewController | 55h | 🔴 Critical |
| **過長的 ViewController** | 4 個核心 VC (> 250行) | 60h | 🔴 High |
| **Cell 記憶體管理** | 24 個 Cell 缺少 prepareForReuse | 8h | 🟡 Medium |
| **Singleton 過度使用** | 6 個 shared instance | 25h | 🟡 Medium |
| **缺少 Repository 層** | 直接使用 Firebase | 20h | 🟡 Medium |
| **代碼重複** | Cell 佈局重複 ~80% | 15h | 🟢 Low |

**總計**: 177 小時，分散在 12-15 個工作天中

---

## 🎯 重構策略

### 核心原則

1. **不影響新功能開發** - 重構與新功能並行
2. **分階段進行** - 每個 Phase 只重構相關模組
3. **優先修復 Critical 問題** - RxSwift 記憶體洩漏優先
4. **可測試性優先** - 重構後的代碼必須可測試

### 分配策略

```
Phase A (安全性)     → 重構 Auth 相關 (15h)
Phase B (Supabase)   → 重構 Repository 層 (20h)
Phase C (資料源)     → 重構 ViewModel (25h)
Phase D (AI 推薦)    → 重構 Cell 和 UI (30h)
Phase E (省錢優化)   → 重構效能相關 (15h)
Phase F (測試上線)   → 完成剩餘重構 (12h)
```

---

## 📅 Phase A: 安全性修復 + Auth 重構

> **Phase 原始工期**: 2 天 (16h)
> **新增重構**: 2 天 (15h)
> **總工期**: 4 天 (31h)

### 原有任務
- ✅ Task A.1: 實作 KeychainManager (3h)
- ✅ Task A.2: 遷移 Token 儲存 (2h)
- ✅ Task A.3: 環境變數配置 (1h)

### 新增重構任務

#### Task A.4: 重構 LoginViewController ✨ NEW

**工時**: 4 小時
**優先級**: 🔴 高

**問題**:
- 缺少 [weak self] (5 處)
- 直接訂閱 Observable without withUnretained
- UI 邏輯與業務邏輯混合

**重構內容**:

```swift
// 修改檔案: TaiwanArtion/ViewController/LoginViewController.swift

// BEFORE (現狀):
loginView.loginButton.rx.tap
    .subscribe(onNext: {
        self.viewModel.handleLoginButtonTapped.accept(true)
    })
    .disposed(by: disposeBag)

// AFTER (重構後):
loginView.loginButton.rx.tap
    .withUnretained(self)
    .subscribe(onNext: { (self, _) in
        self.viewModel.handleLoginButtonTapped.accept(true)
    })
    .disposed(by: disposeBag)
```

**影響範圍**:
- LoginViewController.swift
- RegisterViewController.swift
- ForgotPasswordViewController.swift

---

#### Task A.5: 重構 FirebaseAuth + 建立 AuthRepository ✨ NEW

**工時**: 8 小時
**優先級**: 🟡 中

**問題**:
- FirebaseAuth.swift 直接在 ViewModel 中使用
- 缺少協議抽象
- Google/Facebook 登入邏輯混在一起

**重構內容**:

**新增檔案**: `TaiwanArtion/Repository/AuthRepository.swift`

```swift
// 1. 定義 AuthRepository 協議
protocol AuthRepository {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signInWithGoogle() async throws -> User
    func signInWithFacebook() async throws -> User
    func signOut() throws
    func getCurrentUser() -> User?
}

// 2. Firebase 實作
class FirebaseAuthRepository: AuthRepository {
    private let auth = Auth.auth()

    func signIn(email: String, password: String) async throws -> User {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        return User(firebaseUser: authResult.user)
    }

    func signInWithGoogle() async throws -> User {
        // 封裝 Google Sign-In 邏輯
        let user = try await GoogleSignIn.sharedInstance.signIn(...)
        let credential = GoogleAuthProvider.credential(...)
        let authResult = try await auth.signIn(with: credential)
        return User(firebaseUser: authResult.user)
    }

    // ... 其他方法
}
```

**修改檔案**: `TaiwanArtion/ViewModel/LoginViewModel.swift`

```swift
// BEFORE:
class LoginViewModel {
    let firebaseAuth = FirebaseAuth.shared

    func login() {
        firebaseAuth.signIn(email: ..., password: ...)
    }
}

// AFTER:
class LoginViewModel {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository = FirebaseAuthRepository()) {
        self.authRepository = authRepository
    }

    func login() async throws {
        let user = try await authRepository.signIn(email: ..., password: ...)
        // ...
    }
}
```

**好處**:
- ✅ 可測試性：可以 mock AuthRepository
- ✅ 解耦：ViewModel 不依賴具體實作
- ✅ 為 Supabase 遷移做準備

---

#### Task A.6: 修復 UserManager 記憶體洩漏 ✨ NEW

**工時**: 3 小時
**優先級**: 🔴 高

**問題**:
- UserManager.swift L88: closure 自引用
- L145: handleSelectedIndex callback 無 weak self
- Singleton 模式導致難以測試

**重構內容**:

```swift
// 修改檔案: TaiwanArtion/UserFeature/UserManager.swift

// BEFORE:
settingHeadViewController.selectedHeadPhoto = { photo in
    self.personFileView.headImageView.image = photo
    // ... 無 [weak self]
}

// AFTER:
settingHeadViewController.selectedHeadPhoto = { [weak self] photo in
    guard let self = self else { return }
    self.personFileView.headImageView.image = photo
    // ...
}
```

**成功標準**:
- [ ] 所有 closure 加入 [weak self]
- [ ] Xcode Instruments 無記憶體洩漏
- [ ] 測試覆蓋率 > 60%

---

## 📅 Phase B: Supabase 建設 + Repository 重構

> **Phase 原始工期**: 3 天 (24h)
> **新增重構**: 2.5 天 (20h)
> **總工期**: 5.5 天 (44h)

### 原有任務
- ✅ Task B.1: Supabase 專案設置 (1h)
- ✅ Task B.2: iOS Supabase SDK 整合 (2h)
- ✅ Task B.3: 資料模型定義 (2h)

### 新增重構任務

#### Task B.4: 建立 Repository 層架構 ✨ NEW

**工時**: 12 小時
**優先級**: 🟡 中

**目標**: 將 Firebase 直接調用替換為 Repository 模式

**新增檔案**:

1. **ExhibitionRepository.swift**

```swift
protocol ExhibitionRepository {
    func getExhibitions(limit: Int) async throws -> [Exhibition]
    func getHotExhibitions(count: Int) async throws -> [Exhibition]
    func getExhibitionById(_ id: String) async throws -> Exhibition
    func searchExhibitions(keyword: String) async throws -> [Exhibition]
}

class SupabaseExhibitionRepository: ExhibitionRepository {
    private let supabase = SupabaseClient.shared.client

    func getExhibitions(limit: Int = 20) async throws -> [Exhibition] {
        let response: [Exhibition] = try await supabase
            .from("exhibitions")
            .select()
            .limit(limit)
            .execute()
            .value

        return response
    }

    // ... 其他方法
}

// Firebase 實作 (過渡期保留)
class FirebaseExhibitionRepository: ExhibitionRepository {
    private let db = Firestore.firestore()

    func getExhibitions(limit: Int = 20) async throws -> [Exhibition] {
        let snapshot = try await db.collection("exhibitions")
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Exhibition.self) }
    }
}
```

2. **UserRepository.swift**

```swift
protocol UserRepository {
    func getUser(id: String) async throws -> User
    func updateUser(_ user: User) async throws
    func getFavoriteExhibitions(userId: String) async throws -> [Exhibition]
    func addFavorite(userId: String, exhibitionId: String) async throws
    func removeFavorite(userId: String, exhibitionId: String) async throws
}

class SupabaseUserRepository: UserRepository {
    // 實作...
}
```

3. **VenueRepository.swift**

```swift
protocol VenueRepository {
    func getVenues() async throws -> [Venue]
    func getVenueById(_ id: String) async throws -> Venue
    func getNearbyVenues(latitude: Double, longitude: Double, radius: Double) async throws -> [Venue]
}
```

**修改範圍**:
- HomeViewModel.swift - 替換 FirebaseDatabase 為 ExhibitionRepository
- CollectViewModel.swift - 替換為 UserRepository
- NearViewModel.swift - 替換為 VenueRepository
- ExhibitionCardViewModel.swift - 替換為 ExhibitionRepository

**好處**:
- ✅ 統一資料存取介面
- ✅ 可輕鬆切換 Firebase ↔ Supabase
- ✅ 可測試性大幅提升

---

#### Task B.5: 依賴注入容器 ✨ NEW

**工時**: 8 小時
**優先級**: 🟡 中

**目標**: 移除 Singleton，使用依賴注入

**新增檔案**: `TaiwanArtion/Core/DI/DIContainer.swift`

```swift
class DIContainer {
    static let shared = DIContainer()

    // Repositories
    lazy var authRepository: AuthRepository = FirebaseAuthRepository()
    lazy var exhibitionRepository: ExhibitionRepository = SupabaseExhibitionRepository()
    lazy var userRepository: UserRepository = SupabaseUserRepository()
    lazy var venueRepository: VenueRepository = SupabaseVenueRepository()

    // Services
    lazy var aiService: AIProcessingService = AIProcessingService(
        apiKey: AppConfig.claudeAPIKey
    )

    // ViewModels (工廠方法)
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            exhibitionRepository: exhibitionRepository,
            userRepository: userRepository
        )
    }

    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(authRepository: authRepository)
    }
}
```

**修改範例**: HomeViewController

```swift
// BEFORE:
class HomeViewController: UIViewController {
    let viewModel = HomeViewModel.shared  // Singleton
}

// AFTER:
class HomeViewController: UIViewController {
    let viewModel: HomeViewModel

    init(viewModel: HomeViewModel = DIContainer.shared.makeHomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
}
```

**影響範圍**:
- 6 個 ViewModel (移除 .shared)
- 19 個 ViewController (使用 DI)

---

## 📅 Phase C: 資料源整合 + ViewModel 重構

> **Phase 原始工期**: 3 天 (24h)
> **新增重構**: 3 天 (25h)
> **總工期**: 6 天 (49h)

### 原有任務
- ✅ Task C.1: 政府開放資料 API 整合 (4h)
- ✅ Task C.2: Google Places API 整合 (3h)
- ✅ Task C.3: 資料同步服務 (4h)

### 新增重構任務

#### Task C.4: 重構 HomeViewModel (Input/Output 模式) ✨ NEW

**工時**: 8 小時
**優先級**: 🟡 中

**問題**:
- 286 行代碼，邏輯複雜
- 缺少明確的 input/output 定義
- 多個 PublishSubject 訂閱在 init 中
- 缺少 Driver 最佳實踐

**重構內容**:

```swift
// 修改檔案: TaiwanArtion/ViewModel/HomeViewModel.swift

// BEFORE (現狀):
class HomeViewModel {
    // 混亂的 input/output
    let handleYearAndMonthTapped = PublishSubject<Void>()
    let outputExhibitions = BehaviorRelay<[Exhibition]>(value: [])

    init() {
        // 大量訂閱邏輯在 init 中
        handleYearAndMonthTapped.subscribe(onNext: { ... })
    }
}

// AFTER (重構後):
class HomeViewModel {
    // MARK: - Input
    struct Input {
        let viewDidLoad: Driver<Void>
        let yearMonthTapped: Driver<Void>
        let refreshTriggered: Driver<Void>
        let exhibitionSelected: Driver<Int>
    }

    // MARK: - Output
    struct Output {
        let exhibitions: Driver<[Exhibition]>
        let hotExhibitions: Driver<[Exhibition]>
        let isLoading: Driver<Bool>
        let error: Driver<String?>
    }

    // MARK: - Dependencies
    private let exhibitionRepository: ExhibitionRepository
    private let userRepository: UserRepository

    init(
        exhibitionRepository: ExhibitionRepository,
        userRepository: UserRepository
    ) {
        self.exhibitionRepository = exhibitionRepository
        self.userRepository = userRepository
    }

    // MARK: - Transform
    func transform(input: Input) -> Output {
        // 清晰的轉換邏輯
        let isLoading = PublishRelay<Bool>()
        let error = PublishRelay<String?>()

        let exhibitions = input.viewDidLoad
            .flatMapLatest { [weak self] _ -> Driver<[Exhibition]> in
                guard let self = self else { return .empty() }
                isLoading.accept(true)

                return Task {
                    try await self.exhibitionRepository.getExhibitions(limit: 20)
                }
                .asDriver(onErrorJustReturn: [])
                .do(onNext: { _ in isLoading.accept(false) })
            }

        return Output(
            exhibitions: exhibitions,
            hotExhibitions: .empty(),
            isLoading: isLoading.asDriver(onErrorJustReturn: false),
            error: error.asDriver(onErrorJustReturn: nil)
        )
    }
}
```

**使用範例**: HomeViewController

```swift
// AFTER:
override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
}

private func bindViewModel() {
    let input = HomeViewModel.Input(
        viewDidLoad: rx.viewDidLoad.asDriver(),
        yearMonthTapped: homeView.yearMonthButton.rx.tap.asDriver(),
        refreshTriggered: homeView.tableView.refreshControl!.rx.controlEvent(.valueChanged).asDriver(),
        exhibitionSelected: homeView.tableView.rx.itemSelected.map(\.row).asDriver(onErrorJustReturn: 0)
    )

    let output = viewModel.transform(input: input)

    output.exhibitions
        .drive(homeView.tableView.rx.items) { tableView, index, exhibition in
            // Configure cell
        }
        .disposed(by: disposeBag)

    output.isLoading
        .drive(onNext: { [weak self] isLoading in
            self?.showLoading(isLoading)
        })
        .disposed(by: disposeBag)
}
```

**影響範圍**:
- HomeViewModel.swift (286 行)
- SearchViewModel.swift (218 行)
- CollectViewModel.swift (333 行)
- ExhibitionCardViewModel.swift (237 行)
- NearViewModel.swift (238 行)

---

#### Task C.5: 重構 SearchViewModel (防抖動 + 性能) ✨ NEW

**工時**: 6 小時
**優先級**: 🟡 中

**問題**:
- 搜尋邏輯複雜，無防抖動
- 多個 filter 和 map chain
- 缺少搜尋歷史管理

**重構內容**:

```swift
// 修改檔案: TaiwanArtion/ViewModel/SearchViewModel.swift

func transform(input: Input) -> Output {
    // 搜尋防抖動
    let searchResults = input.searchText
        .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
        .distinctUntilChanged()
        .flatMapLatest { [weak self] keyword -> Driver<[Exhibition]> in
            guard let self = self, !keyword.isEmpty else {
                return .just([])
            }

            return Task {
                try await self.exhibitionRepository.searchExhibitions(keyword: keyword)
            }
            .asDriver(onErrorJustReturn: [])
        }

    // 搜尋歷史
    let searchHistory = input.searchText
        .filter { !$0.isEmpty }
        .scan(into: [String]()) { history, keyword in
            if !history.contains(keyword) {
                history.insert(keyword, at: 0)
                if history.count > 10 {
                    history.removeLast()
                }
            }
        }
        .asDriver(onErrorJustReturn: [])

    return Output(
        searchResults: searchResults,
        searchHistory: searchHistory,
        isSearching: input.searchText.map { !$0.isEmpty }.asDriver(onErrorJustReturn: false)
    )
}
```

---

#### Task C.6: 修復所有 ViewController 記憶體洩漏 ✨ NEW

**工時**: 11 小時
**優先級**: 🔴 Critical

**影響範圍**: 19 個 ViewController

**統一修復模式**:

```swift
// 檢查所有 ViewController 的 RxSwift 訂閱
// 確保所有 subscribe/bind/drive 都有 [weak self] 或 withUnretained

// 修復清單:
✅ ExhibitionCardViewController.swift (6 處)
✅ SearchViewController.swift (8 處)
✅ HomeViewController.swift (5 處)
✅ PersonalInfoViewController.swift (4 處)
✅ AccountSettingViewController.swift (3 處)
// ... 其他 14 個 ViewController
```

**驗證方式**:
```bash
# 檢查所有未使用 weak self 的 subscribe
grep -r "\.subscribe(onNext: {" TaiwanArtion/ViewController --include="*.swift" | grep -v "weak self"
```

---

## 📅 Phase D: AI 推薦引擎 + UI 重構

> **Phase 原始工期**: 3 天 (24h)
> **新增重構**: 4 天 (30h)
> **總工期**: 7 天 (54h)

### 原有任務
- ✅ Task D.1: Claude API 服務 (4h)
- ✅ Task D.2: 推薦快取系統 (3h)
- ✅ Task D.3: Repository 層整合 (2h)

### 新增重構任務

#### Task D.4: 拆分 ExhibitionCardViewController ✨ NEW

**工時**: 12 小時
**優先級**: 🔴 高

**問題**:
- 424 行代碼，超複雜
- 5 個不同的 TableView section
- 責任過多

**重構方案**:

**1. 提取 DataSource**

新增檔案: `TaiwanArtion/DataSource/ExhibitionCardDataSource.swift`

```swift
class ExhibitionCardDataSource: NSObject {
    enum Section: Int, CaseIterable {
        case photos
        case title
        case location
        case time
        case comment
    }

    var exhibition: Exhibition?

    func numberOfSections() -> Int {
        return Section.allCases.count
    }

    func numberOfRows(in section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }

        switch sectionType {
        case .photos: return 1
        case .title: return 1
        case .location: return 1
        case .time: return 1
        case .comment: return exhibition?.comments.count ?? 0
        }
    }

    func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch sectionType {
        case .photos:
            let cell = tableView.dequeueReusableCell(withIdentifier: MainPhotosTableViewCell.reuseIdentifier, for: indexPath) as! MainPhotosTableViewCell
            cell.configure(with: exhibition)
            return cell

        case .title:
            // ...
        }
    }
}
```

**2. 簡化 ViewController**

```swift
// 修改檔案: TaiwanArtion/ViewController/ExhibitionCardViewController.swift

// BEFORE: 424 行
class ExhibitionCardViewController: UIViewController {
    // 大量的 tableView delegate 方法
}

// AFTER: ~150 行
class ExhibitionCardViewController: UIViewController {
    private let dataSource = ExhibitionCardDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
    }

    private func setupTableView() {
        exhibitionCardView.tableView.dataSource = dataSource
        exhibitionCardView.tableView.delegate = self
    }

    private func bindViewModel() {
        let input = ExhibitionCardViewModel.Input(
            viewDidLoad: rx.viewDidLoad.asDriver()
        )

        let output = viewModel.transform(input: input)

        output.exhibition
            .drive(onNext: { [weak self] exhibition in
                self?.dataSource.exhibition = exhibition
                self?.exhibitionCardView.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// 簡化的 delegate
extension ExhibitionCardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 簡單的邏輯
    }
}
```

---

#### Task D.5: 統一 Cell 設計 (BaseCell + prepareForReuse) ✨ NEW

**工時**: 10 小時
**優先級**: 🟡 中

**問題**:
- 24 個 Cell 中只有 2 個實現 prepareForReuse
- 圖片載入邏輯重複
- 80% 的 Cell 有相同的佈局模式

**重構方案**:

**1. 建立 BaseCollectionViewCell**

新增檔案: `TaiwanArtion/CollectionViewCell/BaseCollectionViewCell.swift`

```swift
class BaseCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    // MARK: - Image Loading
    private var imageLoadingTask: DownloadTask?

    func loadImage(
        url: URL?,
        into imageView: UIImageView,
        placeholder: UIImage? = UIImage(named: "placeholder")
    ) {
        imageLoadingTask = imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage,
                .processor(DownsamplingImageProcessor(size: imageView.bounds.size)),
                .scaleFactor(UIScreen.main.scale)
            ]
        )
    }

    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadingTask?.cancel()
        imageLoadingTask = nil
    }
}
```

**2. 重構所有 Cell**

```swift
// 修改檔案: TaiwanArtion/CollectionViewCell/AllExhibitionCollectionViewCell.swift

// BEFORE:
class AllExhibitionCollectionViewCell: UICollectionViewCell {
    func configure(exhibition: Exhibition) {
        if let urlString = exhibition.imageUrl,
           let url = URL(string: urlString) {
            cardImageView.kf.setImage(with: url)  // 無 prepareForReuse
        }
    }
}

// AFTER:
class AllExhibitionCollectionViewCell: BaseCollectionViewCell {
    func configure(exhibition: Exhibition) {
        if let urlString = exhibition.imageUrl,
           let url = URL(string: urlString) {
            loadImage(url: url, into: cardImageView)  // 自動處理 prepareForReuse
        }
    }

    // prepareForReuse 由 BaseCell 處理
}
```

**影響範圍**:
- 24 個 CollectionViewCell
- 38 個 TableViewCell

---

#### Task D.6: 重構 SearchViewController (簡化) ✨ NEW

**工時**: 8 小時
**優先級**: 🟡 中

**問題**:
- 389 行代碼
- 混合搜尋邏輯、篩選邏輯、UI 狀態管理
- 兩個不同的 CollectionView 邏輯複雜

**重構方案**:

**1. 提取 SearchResultsDataSource**

新增檔案: `TaiwanArtion/DataSource/SearchResultsDataSource.swift`

```swift
class SearchResultsDataSource: NSObject, UICollectionViewDataSource {
    var exhibitions: [Exhibition] = []
    var isGridMode: Bool = true

    func configure(exhibitions: [Exhibition], gridMode: Bool) {
        self.exhibitions = exhibitions
        self.isGridMode = gridMode
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exhibitions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isGridMode {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AllExhibitionCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as! AllExhibitionCollectionViewCell
            cell.configure(exhibition: exhibitions[indexPath.item])
            return cell
        } else {
            // List mode cell
        }
    }
}
```

**2. 簡化 ViewController**

```swift
// AFTER: ~200 行
class SearchViewController: UIViewController {
    private let dataSource = SearchResultsDataSource()

    private func bindViewModel() {
        let input = SearchViewModel.Input(
            searchText: searchView.searchBar.rx.text.orEmpty.asDriver(),
            displayModeToggled: searchView.gridToggleButton.rx.tap.asDriver()
        )

        let output = viewModel.transform(input: input)

        output.searchResults
            .drive(onNext: { [weak self] exhibitions in
                self?.dataSource.configure(
                    exhibitions: exhibitions,
                    gridMode: output.isGridMode
                )
                self?.searchView.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}
```

---

## 📅 Phase E: 省錢優化 + 效能重構

> **Phase 原始工期**: 2 天 (16h)
> **新增重構**: 2 天 (15h)
> **總工期**: 4 天 (31h)

### 原有任務
- ✅ Task E.1: 批次推薦處理 (3h)
- ✅ Task E.2: 成本監控與預算控制 (2h)

### 新增重構任務

#### Task E.3: Kingfisher 圖片載入最佳化 ✨ NEW

**工時**: 5 小時
**優先級**: 🟡 中

**目標**: 統一圖片載入策略，減少記憶體使用

**修改檔案**: `TaiwanArtion/AppDelegate.swift`

```swift
// BEFORE:
func application(_ application: UIApplication, didFinishLaunchingWithOptions...) {
    let cache = ImageCache.default
    cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024
    cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
}

// AFTER:
func configureKingfisher() {
    let cache = ImageCache.default

    // Memory cache: 100 MB
    cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024
    cache.memoryStorage.config.countLimit = 100

    // Disk cache: 500 MB, 7 天過期
    cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
    cache.diskStorage.config.expiration = .days(7)

    // 預設選項
    KingfisherManager.shared.defaultOptions = [
        .transition(.fade(0.2)),
        .cacheOriginalImage,
        .backgroundDecode,
        .callbackQueue(.mainAsync)
    ]

    // 圖片處理器
    let processor = DownsamplingImageProcessor(size: CGSize(width: 400, height: 400))
        |> RoundCornerImageProcessor(cornerRadius: 8)

    KingfisherManager.shared.defaultOptions.append(.processor(processor))
}
```

**統一使用模式**:

```swift
// 在 BaseCollectionViewCell 中
func loadImage(url: URL?, into imageView: UIImageView) {
    imageView.kf.setImage(
        with: url,
        placeholder: UIImage(named: "placeholder"),
        options: [
            .processor(DownsamplingImageProcessor(size: imageView.bounds.size)),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ],
        completionHandler: { [weak self] result in
            switch result {
            case .success(let value):
                AppLogger.debug("圖片載入成功: \(value.source.url?.absoluteString ?? "")", category: .ui)
            case .failure(let error):
                AppLogger.error("圖片載入失敗", category: .ui, error: error)
            }
        }
    )
}
```

---

#### Task E.4: TableView/CollectionView 效能優化 ✨ NEW

**工時**: 6 小時
**優先級**: 🟡 中

**問題**:
- 頻繁的 reloadData()
- 缺少行高緩存
- 未設置 estimatedRowHeight

**重構內容**:

**1. 高度緩存**

新增檔案: `TaiwanArtion/Utilities/HeightCache.swift`

```swift
class HeightCache {
    private var cache: [String: CGFloat] = [:]

    func height(for key: String) -> CGFloat? {
        return cache[key]
    }

    func setHeight(_ height: CGFloat, for key: String) {
        cache[key] = height
    }

    func clear() {
        cache.removeAll()
    }
}
```

**2. 使用範例**:

```swift
// 在 ViewController 中
class HomeViewController: UIViewController {
    private let heightCache = HeightCache()

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cacheKey = "\(indexPath.section)-\(indexPath.row)"

        if let cachedHeight = heightCache.height(for: cacheKey) {
            return cachedHeight
        }

        let height = calculateHeight(for: indexPath)
        heightCache.setHeight(height, for: cacheKey)
        return height
    }
}
```

**3. estimatedRowHeight 設置**:

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    tableView.estimatedRowHeight = 120
    tableView.rowHeight = UITableView.automaticDimension
}
```

**4. 減少 reloadData**:

```swift
// BEFORE:
viewModel.exhibitions.subscribe(onNext: { _ in
    self.tableView.reloadData()
})

// AFTER:
viewModel.exhibitions.subscribe(onNext: { [weak self] exhibitions in
    guard let self = self else { return }

    // 計算變更
    let changes = self.calculateChanges(old: self.currentExhibitions, new: exhibitions)

    self.tableView.performBatchUpdates({
        self.tableView.insertRows(at: changes.inserts, with: .fade)
        self.tableView.deleteRows(at: changes.deletes, with: .fade)
        self.tableView.reloadRows(at: changes.updates, with: .none)
    })

    self.currentExhibitions = exhibitions
})
```

---

#### Task E.5: 記憶體洩漏全面檢查 ✨ NEW

**工時**: 4 小時
**優先級**: 🔴 高

**工具**: Xcode Instruments (Leaks & Allocations)

**檢查清單**:
```markdown
□ 所有 ViewController deinit 正常調用
□ 所有 ViewModel deinit 正常調用
□ 所有 RxSwift subscription 正確 disposed
□ 所有 closure 使用 [weak self] 或 [unowned self]
□ 所有 delegate 使用 weak var
□ 所有 Timer 正確 invalidate
□ 所有 NotificationCenter observer 正確移除
```

**自動化檢測腳本**:

```bash
#!/bin/bash
# check_memory_leaks.sh

echo "檢查缺少 weak self 的 subscribe..."
grep -r "\.subscribe(onNext: {" TaiwanArtion --include="*.swift" | grep -v "weak self" | grep -v "unowned self"

echo "\n檢查缺少 weak 的 delegate..."
grep -r "var.*delegate.*:" TaiwanArtion --include="*.swift" | grep -v "weak" | grep -v "protocol"

echo "\n檢查 Timer..."
grep -r "Timer.scheduledTimer" TaiwanArtion --include="*.swift"
```

---

## 📅 Phase F: 測試與上線 + 最終重構

> **Phase 原始工期**: 2 天 (16h)
> **新增重構**: 1.5 天 (12h)
> **總工期**: 3.5 天 (28h)

### 原有任務
- ✅ Task F.1: 完整功能測試 (4h)
- ✅ Task F.2: 效能優化 (2h)
- ✅ Task F.3: 上線前檢查 (2h)

### 新增重構任務

#### Task F.4: 代碼去重與組件化 ✨ NEW

**工時**: 8 小時
**優先級**: 🟢 低

**目標**: 提取重複的 UI 組件

**1. 建立可復用組件**

新增檔案: `TaiwanArtion/View/Components/ExhibitionCardView.swift`

```swift
class ExhibitionCardView: UIView {
    // 統一的展覽卡片設計
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    private let collectButton = UIButton()

    func configure(exhibition: Exhibition) {
        titleLabel.text = exhibition.title
        locationLabel.text = exhibition.location

        if let urlString = exhibition.imageUrl,
           let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        }
    }
}
```

**2. 在 Cell 中使用**:

```swift
// AllExhibitionCollectionViewCell, MainPhotosCollectionViewCell 都可使用
class AllExhibitionCollectionViewCell: BaseCollectionViewCell {
    private let cardView = ExhibitionCardView()

    func configure(exhibition: Exhibition) {
        cardView.configure(exhibition: exhibition)
    }
}
```

---

#### Task F.5: 單元測試覆蓋關鍵模組 ✨ NEW

**工時**: 4 小時
**優先級**: 🟡 中

**測試目標**:

1. **Repository 測試**

新增檔案: `TaiwanArtionTests/Repository/ExhibitionRepositoryTests.swift`

```swift
class ExhibitionRepositoryTests: XCTestCase {
    var sut: ExhibitionRepository!

    override func setUp() {
        super.setUp()
        // 使用 Mock repository
        sut = MockExhibitionRepository()
    }

    func testGetExhibitions() async throws {
        let exhibitions = try await sut.getExhibitions(limit: 10)

        XCTAssertEqual(exhibitions.count, 10)
        XCTAssertNotNil(exhibitions.first?.title)
    }

    func testSearchExhibitions() async throws {
        let results = try await sut.searchExhibitions(keyword: "印象派")

        XCTAssertGreaterThan(results.count, 0)
        XCTAssertTrue(results.first!.title.contains("印象派"))
    }
}
```

2. **ViewModel 測試**

```swift
class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockRepository: MockExhibitionRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockExhibitionRepository()
        sut = HomeViewModel(exhibitionRepository: mockRepository)
    }

    func testLoadExhibitions() {
        let expectation = XCTestExpectation(description: "Load exhibitions")

        let input = HomeViewModel.Input(
            viewDidLoad: .just(()),
            yearMonthTapped: .empty(),
            refreshTriggered: .empty(),
            exhibitionSelected: .empty()
        )

        let output = sut.transform(input: input)

        output.exhibitions
            .drive(onNext: { exhibitions in
                XCTAssertGreaterThan(exhibitions.count, 0)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 3.0)
    }
}
```

**測試覆蓋率目標**:
- Repository: 80%+
- ViewModel: 70%+
- Utility: 90%+

---

## 📊 重構總工時統計

| Phase | 原始工時 | 重構工時 | 總工時 | 增加 |
|-------|---------|---------|--------|------|
| **Phase A** | 16h | 15h | 31h | +94% |
| **Phase B** | 24h | 20h | 44h | +83% |
| **Phase C** | 24h | 25h | 49h | +104% |
| **Phase D** | 24h | 30h | 54h | +125% |
| **Phase E** | 16h | 15h | 31h | +94% |
| **Phase F** | 16h | 12h | 28h | +75% |
| **總計** | **120h** | **117h** | **237h** | **+98%** |

**總開發時間**: 237 小時 ≈ **30 個工作天** (每天 8 小時)

---

## ✅ 重構成功標準

### 代碼品質指標

```
✅ 平均 ViewController 行數 < 250
✅ 平均 ViewModel 行數 < 200
✅ 沒有 > 500 行的單一文件
✅ RxSwift 記憶體洩漏 = 0
✅ Cell prepareForReuse 實現率 = 100%
✅ Singleton 使用 < 3 個 (僅保留真正需要的)
✅ 測試覆蓋率 > 60%
```

### 效能指標

```
✅ App 啟動時間 < 2 秒
✅ 記憶體使用 < 120MB
✅ TableView scroll FPS > 55
✅ 圖片載入無閃爍
✅ 無明顯卡頓
```

### 架構指標

```
✅ 所有 ViewModel 使用 Input/Output 模式
✅ 所有資料存取通過 Repository
✅ 所有依賴通過 DI 注入
✅ 協議使用率 > 70%
✅ 代碼重複率 < 15%
```

---

## 🎯 執行建議

### 優先級排序

1. **Critical 優先** (必須做):
   - RxSwift 記憶體洩漏修復
   - Cell prepareForReuse 實現
   - AuthRepository 建立

2. **High 優先** (強烈建議):
   - ExhibitionCardViewController 拆分
   - Repository 層建立
   - ViewModel Input/Output 重構

3. **Medium 優先** (建議做):
   - Singleton 轉 DI
   - SearchViewController 簡化
   - 圖片載入優化

4. **Low 優先** (有時間再做):
   - 代碼去重
   - UI 組件提取
   - 文檔完善

### 分工建議

如果有團隊，可以並行：

```
開發者 A: Phase A-B (Auth + Repository)
開發者 B: Phase C-D (ViewModel + UI)
開發者 C: Phase E-F (效能 + 測試)
```

### 風險控制

1. **每個 Phase 結束都 commit**
2. **使用 feature branch 開發**
3. **重構前先寫測試**
4. **定期 code review**
5. **持續集成檢查**

---

**建立者**: Claude Code
**最後更新**: 2025-11-28
**狀態**: Ready for Execution
**預估完成**: 2026-01-27 (30 工作天)
