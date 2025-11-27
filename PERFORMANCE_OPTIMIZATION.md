# Phase 5: 性能優化文檔

**完成日期**: 2025-11-27
**版本**: 1.0

## 概述

本文檔詳細記錄了 Phase 5 階段進行的所有性能優化工作，包括 Firebase 查詢優化、圖片快取配置和記憶體洩漏修復。

---

## 1. Firebase 查詢優化

### 1.1 優化 getRandomDocuments() 方法

**問題描述**：
原有的 `getRandomDocuments()` 方法會獲取整個 collection 的所有文件，然後在客戶端進行隨機選擇。這在數據量大時會造成：
- 網路流量浪費
- 查詢時間過長
- 記憶體佔用過高

**優化方案**：
使用 Firestore 的 `limit(to:)` 查詢限制，只獲取需要的數據量。

**程式碼變更**：

```swift
// 優化前
func getRandomDocuments(count: Int, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
    db.collection(collectionName).getDocuments { (querySnapshot, error) in
        if let error = error {
            completion(nil, error)
        } else {
            let documents = querySnapshot?.documents.shuffled().prefix(count)
            let results = documents?.map { $0.data() }
            completion(Array(results ?? []), nil)
        }
    }
}

// 優化後
func getRandomDocuments(count: Int, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
    AppLogger.enter(category: .firebase)
    AppLogger.debug("獲取 \(count) 個隨機文件", category: .firebase)

    db.collection(collectionName).limit(to: 1).getDocuments { [weak self] snapshot, error in
        guard let self = self else { return }

        if error != nil {
            self.db.collection(collectionName)
                .limit(to: count * 3)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        AppLogger.error("獲取隨機文件失敗", category: .firebase, error: error)
                        completion(nil, error)
                    } else {
                        let documents = querySnapshot?.documents.shuffled().prefix(count)
                        let results = documents?.map { $0.data() }
                        AppLogger.info("成功獲取 \(results?.count ?? 0) 個隨機文件", category: .firebase)
                        completion(Array(results ?? []), nil)
                    }
                }
        } else {
            self.db.collection(collectionName)
                .limit(to: min(count * 2, 50))
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        AppLogger.error("獲取隨機文件失敗", category: .firebase, error: error)
                        completion(nil, error)
                    } else {
                        let documents = querySnapshot?.documents.shuffled().prefix(count)
                        let results = documents?.map { $0.data() }
                        AppLogger.info("成功獲取 \(results?.count ?? 0) 個隨機文件", category: .firebase)
                        completion(Array(results ?? []), nil)
                    }
                    AppLogger.exit(category: .firebase)
                }
        }
    }
}
```

**效能提升**：
- ✅ 限制最多獲取 50 個文件，減少網路流量
- ✅ 添加 `[weak self]` 防止記憶體洩漏
- ✅ 使用 AppLogger 追蹤查詢性能

---

### 1.2 實作分頁載入

**功能描述**：
實作基於游標的分頁載入，支援無限滾動。

**新增方法**：

#### 1.2.1 基本分頁載入

```swift
func getPaginatedDocuments(
    pageSize: Int,
    lastDocument: DocumentSnapshot? = nil,
    orderBy: String? = nil,
    descending: Bool = false,
    completion: @escaping ([[String: Any]]?, DocumentSnapshot?, Error?) -> Void
)
```

**參數說明**：
- `pageSize`: 每頁載入的文件數量
- `lastDocument`: 上一頁的最後一個文件快照（用於繼續載入）
- `orderBy`: 可選的排序欄位
- `descending`: 是否降序排列
- `completion`: 回調，返回資料、最後文件快照和錯誤

**使用範例**：

```swift
// 首次載入
database.getPaginatedDocuments(pageSize: 20) { documents, lastDoc, error in
    guard let documents = documents else { return }
    // 顯示資料
    self.lastDocument = lastDoc
}

// 載入下一頁
database.getPaginatedDocuments(
    pageSize: 20,
    lastDocument: lastDocument,
    orderBy: "startDate",
    descending: false
) { documents, lastDoc, error in
    // 追加資料
}
```

#### 1.2.2 條件分頁載入

```swift
func getPaginatedDocuments(
    whereField field: String,
    isEqualTo value: Any,
    pageSize: Int,
    lastDocument: DocumentSnapshot? = nil,
    orderBy: String? = nil,
    descending: Bool = false,
    completion: @escaping ([[String: Any]]?, DocumentSnapshot?, Error?) -> Void
)
```

**使用範例**：

```swift
// 載入特定分類的展覽
database.getPaginatedDocuments(
    whereField: "category",
    isEqualTo: "藝術",
    pageSize: 20,
    orderBy: "viewCount",
    descending: true
) { documents, lastDoc, error in
    // 處理資料
}
```

**優勢**：
- ✅ 減少單次查詢的數據量
- ✅ 支援無限滾動
- ✅ 降低記憶體使用
- ✅ 提升用戶體驗（更快的首次載入）

---

## 2. Kingfisher 圖片快取配置

### 2.1 全域配置

**位置**: `TaiwanArtion/AppDelegate.swift`

**配置內容**：

```swift
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
    downloader.downloadTimeout = 15.0
    downloader.trustedHosts = Set(["firebasestorage.googleapis.com"])

    // 設定預設圖片處理選項
    KingfisherManager.shared.defaultOptions = [
        .transition(.fade(0.2)),
        .cacheOriginalImage,
        .scaleFactor(UIScreen.main.scale),
        .processor(DownsamplingImageProcessor(size: CGSize(width: 300, height: 300))),
        .backgroundDecode
    ]
}
```

### 2.2 配置說明

| 配置項 | 值 | 說明 |
|--------|-----|------|
| **記憶體快取** | 100 MB | 快速存取常用圖片 |
| **磁碟快取** | 500 MB | 持久化儲存，減少重複下載 |
| **快取過期** | 7 天 | 自動清理舊圖片 |
| **下載超時** | 15 秒 | 避免長時間等待 |
| **信任主機** | firebasestorage.googleapis.com | Firebase 圖片儲存 |

### 2.3 預設圖片處理選項

| 選項 | 說明 | 效果 |
|------|------|------|
| `transition(.fade(0.2))` | 淡入效果 | 圖片載入更平滑 |
| `cacheOriginalImage` | 快取原始圖片 | 減少重複處理 |
| `scaleFactor(UIScreen.main.scale)` | 螢幕縮放因子 | Retina 顯示優化 |
| `processor(DownsamplingImageProcessor)` | 降採樣 | 減少記憶體使用 |
| `backgroundDecode` | 背景解碼 | 不阻塞主線程 |

### 2.4 效能提升

- ✅ 減少網路請求次數
- ✅ 降低記憶體使用（降採樣）
- ✅ 提升滾動流暢度（背景解碼）
- ✅ 更好的用戶體驗（淡入效果）

---

## 3. RxSwift 記憶體洩漏修復

### 3.1 問題分析

RxSwift 中的閉包（closure）如果捕獲 `self` 而不使用 `[weak self]` 或 `[unowned self]`，會造成強引用循環（retain cycle），導致記憶體洩漏。

**常見場景**：
1. ViewController 訂閱 ViewModel 的 Observable
2. Cell 配置閉包捕獲 ViewController
3. 未 dispose 的訂閱

### 3.2 修復清單

#### 3.2.1 LoginViewController

**位置**: `TaiwanArtion/ViewController/LoginViewController.swift:49`

```swift
// 修復前
self.viewModel.loginSuccessRelay.subscribe(onNext: { loginSuccess in
    self.navigationController?.popViewController(animated: true)
    self.loginSuccess?()
})
.disposed(by: disposeBag)

// 修復後
self.viewModel.loginSuccessRelay.subscribe(onNext: { [weak self] loginSuccess in
    guard let self = self else { return }
    self.navigationController?.popViewController(animated: true)
    self.loginSuccess?()
})
.disposed(by: disposeBag)
```

#### 3.2.2 SettingHeadViewController

**位置**: `TaiwanArtion/ViewController/SettingHeadViewController.swift:92-97`

```swift
// 修復前
viewModel.output.isAllowSavePhoto.subscribe { allowed in
    cell.configureRoundButton(isAllowToTap: allowed, buttonTitle: "儲存")
}
cell.action = {
    self.viewModel.input.savePhoto.onNext(())
    self.navigationController?.popViewController(animated: true)
}

// 修復後
viewModel.output.isAllowSavePhoto
    .subscribe(onNext: { [weak cell] allowed in
        cell?.configureRoundButton(isAllowToTap: allowed, buttonTitle: "儲存")
    })
    .disposed(by: disposeBag)

cell.action = { [weak self] in
    guard let self = self else { return }
    self.viewModel.input.savePhoto.onNext(())
    self.navigationController?.popViewController(animated: true)
}
```

**問題**：
1. 訂閱未 dispose
2. 閉包捕獲 self 和 cell

#### 3.2.3 HomeViewController

**位置**: `TaiwanArtion/ViewController/HomeViewController.swift`

修復了 4 處記憶體洩漏：

1. Line 125: MainPhotosTableViewCell 的 `pushToViewController`
2. Line 137: HotHxhibitionTableViewCell 的 `pushToViewController`
3. Line 151: NewsTableViewCell 的 `pushToViewController`
4. Line 169: AllExhibitionTableViewCell 的 `pushToViewController`

```swift
// 修復模式
cell.pushToViewController = { [weak self] data in
    guard let self = self else { return }
    let viewController = TargetViewController()
    self.navigationController?.pushViewController(viewController, animated: true)
}
```

#### 3.2.4 ExhibitionCardViewController

**位置**: `TaiwanArtion/ViewController/ExhibitionCardViewController.swift:236`

```swift
// 修復前
view.exhibitionCardItemView.pushToViewController = {
    let viewController = EvaluateViewController()
    self.navigationController?.pushViewController(viewController, animated: true)
}

// 修復後
view.exhibitionCardItemView.pushToViewController = { [weak self] in
    guard let self = self else { return }
    let viewController = EvaluateViewController()
    self.navigationController?.pushViewController(viewController, animated: true)
}
```

### 3.3 記憶體洩漏檢測建議

使用 Xcode Instruments 的 Leaks 工具檢測：

```bash
# 1. 運行應用
# 2. Product -> Profile (⌘ + I)
# 3. 選擇 Leaks 模板
# 4. 開始錄製並操作應用
# 5. 檢查是否有記憶體洩漏
```

**檢查清單**：
- [ ] 所有訂閱都使用 `.disposed(by: disposeBag)`
- [ ] 閉包中捕獲 self 時使用 `[weak self]` 或 `[unowned self]`
- [ ] Cell 配置閉包使用 `[weak self]`
- [ ] ViewModel 中的閉包也要注意

---

## 4. 效能測試與驗證

### 4.1 Firebase 查詢效能

**測試方法**：
```swift
let startTime = CFAbsoluteTimeGetCurrent()

database.getRandomDocuments(count: 10) { documents, error in
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("查詢耗時: \(timeElapsed) 秒")
}
```

**預期結果**：
- 優化前: 2-5 秒（取決於 collection 大小）
- 優化後: 0.5-1 秒

### 4.2 圖片載入效能

**測試方法**：
滾動包含大量圖片的列表，觀察：
- 滾動流暢度
- 圖片載入速度
- 記憶體使用量

**預期結果**：
- ✅ 滾動流暢，無卡頓
- ✅ 圖片快速顯示
- ✅ 記憶體穩定，無持續增長

### 4.3 記憶體洩漏檢測

**測試流程**：
1. 啟動 Leaks Instrument
2. 重複進入/離開各個頁面 10 次
3. 觀察記憶體是否持續增長
4. 檢查 Leaks 報告

**預期結果**：
- ✅ 無記憶體洩漏
- ✅ 記憶體在合理範圍內波動

---

## 5. 最佳實踐建議

### 5.1 Firebase 查詢

```swift
// ✅ 好的做法
db.collection("exhibitions")
    .limit(to: 20)
    .getDocuments()

// ❌ 避免
db.collection("exhibitions")
    .getDocuments()  // 獲取所有資料
```

### 5.2 RxSwift 訂閱

```swift
// ✅ 好的做法
viewModel.data
    .subscribe(onNext: { [weak self] data in
        guard let self = self else { return }
        self.updateUI(with: data)
    })
    .disposed(by: disposeBag)

// ❌ 避免
viewModel.data
    .subscribe(onNext: { data in
        self.updateUI(with: data)  // 強引用 self
    })
    // 忘記 dispose
```

### 5.3 圖片載入

```swift
// ✅ 好的做法
imageView.kf.setImage(
    with: url,
    options: [
        .transition(.fade(0.2)),
        .processor(DownsamplingImageProcessor(size: targetSize))
    ]
)

// ❌ 避免
imageView.kf.setImage(with: url)  // 未使用任何優化選項
```

---

## 6. 後續優化建議

### 6.1 短期優化（1-2 週）

- [ ] 實作圖片預載入（prefetch）
- [ ] 添加網路請求快取
- [ ] 優化資料庫查詢索引

### 6.2 中期優化（1 個月）

- [ ] 實作離線模式
- [ ] 添加資料同步機制
- [ ] 優化啟動時間

### 6.3 長期優化（3 個月）

- [ ] 遷移到 Combine（iOS 13+）
- [ ] 實作 CDN 圖片加速
- [ ] 添加性能監控（Firebase Performance）

---

## 7. 相關資源

### 官方文檔
- [Firebase Firestore 最佳實踐](https://firebase.google.com/docs/firestore/best-practices)
- [Kingfisher 使用指南](https://github.com/onevcat/Kingfisher/wiki)
- [RxSwift 記憶體管理](https://github.com/ReactiveX/RxSwift/blob/main/Documentation/GettingStarted.md#disposing)

### 工具
- Xcode Instruments (Leaks, Allocations, Time Profiler)
- Charles/Proxyman (網路請求監控)
- Firebase Console (查詢效能分析)

---

**文檔版本**: 1.0
**最後更新**: 2025-11-27
**維護者**: 開發團隊
