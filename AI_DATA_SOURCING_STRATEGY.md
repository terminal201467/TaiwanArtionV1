# TaiwanArtion AI 驅動資料架構設計

> **建立日期**: 2025-11-28
> **目標**: 設計 AI 驅動的展覽推薦資料系統，取代固定 Firebase 資料
> **原則**: 不使用爬蟲，使用合法資料源 + AI 智能推薦

---

## 🎯 核心概念

### 當前問題
- ❌ 使用固定資料儲存在 Firebase
- ❌ 無法即時更新展覽資訊
- ❌ 推薦系統不智能
- ❌ 資料維護成本高

### 目標架構
- ✅ 自動獲取台灣展覽資訊
- ✅ AI 智能推薦展覽給用戶
- ✅ 資料自動更新
- ✅ 合法且可靠的資料源

---

## 📊 資料來源方案

### 方案一：台灣政府開放資料平台 ⭐⭐⭐⭐⭐

**資料源**: [政府資料開放平臺](https://data.gov.tw/)

**優點**:
- ✅ 完全合法且免費
- ✅ 官方資料，可靠性高
- ✅ 提供 REST API
- ✅ 涵蓋全台灣展覽資訊
- ✅ 定期更新

**可用 API**:
1. **文化部展覽活動資訊**
   - API: `https://cloud.culture.tw/frontsite/trans/SearchShowAction.do?method=doFindTypeJ&category=6`
   - 格式: JSON
   - 內容: 展覽名稱、時間、地點、簡介、圖片

2. **各縣市藝文活動**
   - 台北市藝文活動: `https://data.taipei/api/v1/dataset/...`
   - 新北市藝文活動: `https://data.ntpc.gov.tw/api/...`
   - 高雄市藝文活動: `https://data.kcg.gov.tw/api/...`

**資料結構範例**:
```json
{
  "title": "印象派大師展",
  "startDate": "2025-12-01",
  "endDate": "2026-03-31",
  "location": "國立故宮博物院",
  "category": "西洋美術",
  "description": "展出莫內、雷諾瓦等印象派大師作品",
  "imageUrl": "https://...",
  "price": "NT$350",
  "website": "https://..."
}
```

---

### 方案二：文化部文化資料開放服務網 ⭐⭐⭐⭐⭐

**資料源**: [文化資料開放服務網](https://opendata.culture.tw/)

**優點**:
- ✅ 專門針對藝文活動
- ✅ 資料最完整
- ✅ 包含展覽館資訊
- ✅ 提供 OData API

**API 端點**:
```
https://cloud.culture.tw/frontsite/trans/SearchShowAction.do?method=doFindTypeJ&category=6
```

**資料類型**:
- 展覽活動
- 表演活動
- 藝文場館
- 文化資產

---

### 方案三：Google Places API + 展覽館官網 ⭐⭐⭐

**用途**: 補充方案一、二缺少的資訊

**實施方式**:
1. 用 Google Places API 獲取展覽館基本資訊
2. 獲取展覽館官網連結
3. AI 分析官網內容提取展覽資訊

**成本**:
- Google Places API: 每 1000 次請求 $17 USD
- 月成本估算: ~$10-30 USD (取決於使用量)

---

## 🤖 AI 整合策略

### AI 的三大角色

#### 1️⃣ 資料清洗與標準化 (Data Enrichment)

**問題**: 政府開放資料格式不統一、資訊不完整

**AI 解決方案**:
```swift
// AI 清洗資料流程
政府 API 原始資料
    ↓
AI 分析與標準化
    ↓ (使用 Claude API 或 OpenAI)
標準化 Exhibition 物件
    ↓
儲存到 Firebase/Supabase
```

**AI Prompt 範例**:
```
從以下展覽資訊中提取並標準化資料，回傳 JSON 格式:
- title (展覽名稱)
- category (分類: 當代藝術/古典藝術/攝影/雕塑等)
- tags (標籤陣列: 如 ["印象派", "法國", "19世紀"])
- difficulty (適合對象: 入門/進階/專業)
- estimatedDuration (建議參觀時間，分鐘)

原始資料:
{raw_data}
```

**成本估算**:
- Claude API (Haiku): $0.25 / 1M tokens
- 每筆展覽約 500 tokens
- 處理 1000 筆展覽 ≈ $0.125

---

#### 2️⃣ 智能推薦系統 (Recommendation Engine)

**核心概念**: 基於用戶偏好的個人化推薦

**實施方式**:

**選項 A: 基於規則的 AI 推薦 (簡單快速)**
```swift
// 用戶資料
用戶喜好 (habby): ["當代藝術", "攝影"]
用戶歷史: [已收藏展覽 ID 陣列]
用戶位置: 台北市

// AI Prompt
請基於以下用戶資料推薦 10 個展覽:
用戶喜好: {habby}
已收藏: {favorited}
位置: {location}
可用展覽清單: {exhibitions}

回傳格式: [展覽ID陣列，依推薦度排序]
```

**成本**: 每次推薦 ~$0.001 USD

---

**選項 B: 向量嵌入推薦系統 (進階)**
```swift
// 1. 預先處理：將所有展覽轉為向量
展覽描述 → OpenAI Embeddings API → 向量儲存 (Pinecone/Supabase Vector)

// 2. 用戶查詢時
用戶偏好 → 向量 → 相似度搜尋 → 推薦結果

// 3. 優點
- 推薦速度快 (向量搜尋)
- 可擴展到數萬筆資料
- 語意理解更準確
```

**成本**:
- OpenAI Embeddings: $0.0001 / 1K tokens
- Pinecone (向量資料庫): $70/month (Starter)
- Supabase Vector (免費) ✅ **推薦**

---

#### 3️⃣ 內容生成 (Content Generation)

**用途**: 為資訊不完整的展覽生成摘要、標籤

**範例**:
```swift
// 某些展覽只有名稱和時間，缺少描述
let exhibition = Exhibition(
    title: "梵谷特展",
    startDate: "2025-12-01",
    description: nil  // 缺少描述
)

// AI 生成描述
AI.generateDescription(for: exhibition) { result in
    // "梵谷特展展出後印象派大師文森·梵谷的經典作品，
    //  包括《星夜》、《向日葵》等，適合對西洋美術有興趣的觀眾。"
}
```

**注意**:
- ⚠️ AI 生成內容需標註「AI 生成」
- ⚠️ 優先使用官方資料，AI 僅作補充

---

## 🏗️ 技術架構設計

### 整體資料流

```
┌─────────────────────────────────────────────────────────────┐
│                     資料獲取層 (Data Fetching)                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  政府開放資料 API     文化部 API      Google Places API      │
│         │                │                  │                │
│         └────────────────┴──────────────────┘                │
│                          │                                   │
└──────────────────────────┼───────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                     AI 處理層 (AI Processing)                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ 資料標準化    │  │ 標籤生成      │  │ 摘要生成      │      │
│  │ (Claude API) │  │ (Claude API) │  │ (Claude API) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                │                  │                │
│         └────────────────┴──────────────────┘                │
│                          │                                   │
└──────────────────────────┼───────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                   資料儲存層 (Data Storage)                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Firebase Firestore / Supabase PostgreSQL                   │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ exhibitions  │  │ venues       │  │ user_prefs   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                              │
└──────────────────────────┬───────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                     推薦引擎 (Recommendation)                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Supabase Vector Search / AI-based Recommendation           │
│                                                              │
│  輸入: 用戶偏好 + 位置 + 歷史行為                             │
│  輸出: 個人化推薦展覽列表                                     │
│                                                              │
└──────────────────────────┬───────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                      iOS App (UIKit)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  首頁展示 AI 推薦展覽 → ExhibitionRepository → ViewModel     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 💻 實作細節

### 1. 建立資料獲取服務

**DataFetchingService.swift** (新增)
```swift
import Foundation
import RxSwift

protocol DataSourceProtocol {
    func fetchExhibitions() -> Observable<[RawExhibition]>
}

// 政府開放資料源
class CultureGovDataSource: DataSourceProtocol {
    private let apiURL = "https://cloud.culture.tw/frontsite/trans/SearchShowAction.do?method=doFindTypeJ&category=6"

    func fetchExhibitions() -> Observable<[RawExhibition]> {
        return Observable.create { observer in
            // 實作 API 請求
            URLSession.shared.dataTask(with: URL(string: self.apiURL)!) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }

                guard let data = data else {
                    observer.onError(AppError.dataNotFound)
                    return
                }

                do {
                    let exhibitions = try JSONDecoder().decode([RawExhibition].self, from: data)
                    observer.onNext(exhibitions)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }.resume()

            return Disposables.create()
        }
    }
}

// Google Places 資料源 (補充)
class GooglePlacesDataSource: DataSourceProtocol {
    // 實作 Google Places API
}
```

---

### 2. AI 處理服務

**AIProcessingService.swift** (新增)
```swift
import Foundation
import RxSwift

class AIProcessingService {
    private let apiKey: String  // Claude API Key 或 OpenAI API Key

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // 資料標準化
    func standardizeExhibition(_ raw: RawExhibition) -> Observable<Exhibition> {
        let prompt = """
        請將以下展覽資訊標準化為 JSON 格式，包含:
        - title: 展覽名稱
        - category: 分類 (當代藝術/古典藝術/攝影/雕塑/其他)
        - tags: 標籤陣列 (例: ["印象派", "法國", "19世紀"])
        - difficulty: 適合對象 (入門/進階/專業)
        - estimatedDuration: 建議參觀時間 (分鐘)

        原始資料:
        標題: \(raw.title)
        描述: \(raw.description ?? "無")
        類別: \(raw.category ?? "無")

        只回傳 JSON，不要其他說明文字。
        """

        return callClaudeAPI(prompt: prompt)
            .map { response in
                // 解析 AI 回應並建立 Exhibition 物件
                return try self.parseExhibitionFromJSON(response)
            }
    }

    // 生成推薦
    func generateRecommendations(
        for user: User,
        from exhibitions: [Exhibition],
        limit: Int = 10
    ) -> Observable<[Exhibition]> {
        let prompt = """
        請基於以下用戶資料，從展覽清單中推薦 \(limit) 個最適合的展覽:

        用戶喜好: \(user.habby.joined(separator: ", "))
        已收藏: \(user.favoriteExhibitions.count) 個展覽
        位置: \(user.location ?? "台北市")

        展覽清單:
        \(exhibitions.enumerated().map { "[\($0.offset)] \($0.element.title) - \($0.element.category)" }.joined(separator: "\n"))

        請回傳推薦的展覽編號陣列，例: [3, 7, 1, 9, ...]
        """

        return callClaudeAPI(prompt: prompt)
            .map { response in
                // 解析 AI 回傳的編號陣列
                let indices = try self.parseRecommendationIndices(response)
                return indices.compactMap { exhibitions[safe: $0] }
            }
    }

    // 呼叫 Claude API
    private func callClaudeAPI(prompt: String) -> Observable<String> {
        return Observable.create { observer in
            var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(self.apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

            let body: [String: Any] = [
                "model": "claude-3-haiku-20240307",  // 使用 Haiku 最便宜
                "max_tokens": 1024,
                "messages": [
                    ["role": "user", "content": prompt]
                ]
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let content = json["content"] as? [[String: Any]],
                      let text = content.first?["text"] as? String else {
                    observer.onError(AppError.serverError("AI API 回應格式錯誤"))
                    return
                }

                observer.onNext(text)
                observer.onCompleted()
            }.resume()

            return Disposables.create()
        }
    }

    private func parseExhibitionFromJSON(_ json: String) throws -> Exhibition {
        // 實作 JSON 解析
        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(Exhibition.self, from: data)
    }

    private func parseRecommendationIndices(_ response: String) throws -> [Int] {
        // 解析 AI 回傳的編號陣列
        // 例: "[3, 7, 1, 9]" → [3, 7, 1, 9]
        let cleaned = response.replacingOccurrences(of: "[", with: "")
                              .replacingOccurrences(of: "]", with: "")
        return cleaned.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
    }
}
```

---

### 3. 資料同步排程

**DataSyncScheduler.swift** (新增)
```swift
import Foundation

class DataSyncScheduler {
    private let dataSources: [DataSourceProtocol]
    private let aiService: AIProcessingService
    private let repository: ExhibitionRepository

    init(
        dataSources: [DataSourceProtocol],
        aiService: AIProcessingService,
        repository: ExhibitionRepository
    ) {
        self.dataSources = dataSources
        self.aiService = aiService
        self.repository = repository
    }

    // 每日自動同步 (建議在背景執行)
    func scheduleDailySync() {
        // 使用 BackgroundTasks framework
        // 或 Firebase Cloud Functions (伺服器端執行更好)

        syncData()
    }

    func syncData() {
        AppLogger.info("開始同步展覽資料", category: .database)

        // 1. 從所有資料源獲取原始資料
        let allSources = Observable.merge(dataSources.map { $0.fetchExhibitions() })

        allSources
            .flatMap { rawExhibitions in
                // 2. 使用 AI 標準化每一筆資料
                return Observable.from(rawExhibitions)
                    .flatMap { self.aiService.standardizeExhibition($0) }
                    .toArray()
            }
            .flatMap { standardizedExhibitions in
                // 3. 儲存到資料庫
                return self.repository.batchUpdate(standardizedExhibitions)
            }
            .subscribe(
                onNext: { count in
                    AppLogger.info("成功同步 \(count) 筆展覽資料", category: .database)
                },
                onError: { error in
                    AppLogger.error("同步失敗", category: .database, error: error)
                }
            )
    }
}
```

---

### 4. Repository 層整合

**ExhibitionRepository.swift** (修改現有檔案)
```swift
protocol ExhibitionRepository {
    // 原有方法
    func getExhibitions(limit: Int) async throws -> [Exhibition]

    // 新增：AI 推薦方法
    func getRecommendedExhibitions(for user: User, limit: Int) async throws -> [Exhibition]

    // 新增：批次更新
    func batchUpdate(_ exhibitions: [Exhibition]) -> Observable<Int>
}

class FirebaseExhibitionRepository: ExhibitionRepository {
    private let aiService: AIProcessingService

    // 實作 AI 推薦
    func getRecommendedExhibitions(for user: User, limit: Int = 10) async throws -> [Exhibition] {
        // 1. 從 Firebase 獲取所有展覽
        let allExhibitions = try await getExhibitions(limit: 100)

        // 2. 使用 AI 生成個人化推薦
        return try await aiService
            .generateRecommendations(for: user, from: allExhibitions, limit: limit)
            .toAsync()
    }
}
```

---

### 5. ViewModel 整合

**HomeViewModel.swift** (修改)
```swift
class HomeViewModel {
    // 輸出：AI 推薦的展覽
    let recommendedExhibitions = BehaviorRelay<[Exhibition]>(value: [])

    private let repository: ExhibitionRepository
    private let userManager: UserManager

    func loadRecommendations() {
        guard let currentUser = userManager.currentUser else {
            AppLogger.warning("用戶未登入，無法生成推薦", category: .viewModel)
            return
        }

        Task {
            do {
                let recommendations = try await repository.getRecommendedExhibitions(
                    for: currentUser,
                    limit: 10
                )

                await MainActor.run {
                    recommendedExhibitions.accept(recommendations)
                    AppLogger.debug("AI 推薦載入成功: \(recommendations.count) 筆", category: .viewModel)
                }
            } catch {
                AppLogger.error("AI 推薦載入失敗", category: .viewModel, error: error)
            }
        }
    }
}
```

---

## 💰 成本分析

### 月成本估算 (1000 活躍用戶)

| 項目 | 用量 | 單價 | 月成本 |
|------|------|------|--------|
| **資料獲取** | | | |
| 政府開放資料 API | 無限 | 免費 | $0 |
| Google Places API | 1000 請求 | $17/1K | $17 |
| **AI 處理** | | | |
| Claude API (Haiku) | 500K tokens | $0.25/1M | $0.13 |
| 資料標準化 | 1000 筆/日 | | $3.90 |
| 推薦生成 | 1000 次/日 | | $1.00 |
| **資料儲存** | | | |
| Firebase (Blaze) | 10GB | 見現有分析 | $10 |
| Supabase (Pro) | 8GB | $25/月 | $25 |
| **總計** | | | **$32-57** |

**結論**: 月成本約 $32-57 USD，相比完全手動維護資料，這是可接受的成本。

---

## 🚀 實施計畫

### Phase 1: 資料源整合 (3-4 天)

**Day 1-2: 串接政府開放資料 API**
```markdown
□ 創建 DataFetchingService
□ 實作 CultureGovDataSource
□ 測試資料獲取
□ 建立 RawExhibition 模型
```

**Day 3-4: AI 資料標準化**
```markdown
□ 申請 Claude API Key / OpenAI API Key
□ 創建 AIProcessingService
□ 實作 standardizeExhibition()
□ 測試 AI 資料清洗
```

---

### Phase 2: 推薦引擎 (3-4 天)

**Day 5-6: 實作推薦邏輯**
```markdown
□ 實作 generateRecommendations()
□ 設計推薦演算法提示詞
□ 測試推薦準確度
□ 調整提示詞優化
```

**Day 7-8: Repository 整合**
```markdown
□ 修改 ExhibitionRepository
□ 實作 getRecommendedExhibitions()
□ 整合到現有 ViewModel
□ UI 顯示 AI 推薦結果
```

---

### Phase 3: 自動化與優化 (2-3 天)

**Day 9-10: 資料同步排程**
```markdown
□ 實作 DataSyncScheduler
□ 設定每日自動同步
□ 錯誤處理與重試機制
□ 監控與日誌
```

**Day 11: 效能優化**
```markdown
□ 快取機制 (避免重複 AI 請求)
□ 批次處理優化
□ API 呼叫限流
```

---

## ⚠️ 注意事項

### 1. 為什麼不需要爬蟲？

您的直覺是對的！原因：

✅ **合法性**: 政府開放資料完全合法，爬蟲可能違反網站服務條款
✅ **穩定性**: 官方 API 穩定可靠，爬蟲容易因網站改版而失效
✅ **維護成本**: API 不需要維護，爬蟲需要持續更新選擇器
✅ **資料品質**: 官方資料結構化且準確，爬蟲資料需要大量清洗

**結論**: 台灣政府開放資料已提供足夠的展覽資訊，無需爬蟲。

---

### 2. AI API 選擇建議

| API | 優點 | 缺點 | 建議使用場景 |
|-----|------|------|--------------|
| **Claude (Haiku)** | 便宜、快速、中文好 | 需要 API Key | ✅ **推薦**: 資料標準化 |
| **OpenAI (GPT-3.5)** | 成熟、文檔完整 | 較貴 | 推薦生成 |
| **OpenAI (Embeddings)** | 向量搜尋專用 | 需要向量資料庫 | 進階推薦系統 |

**成本對比**:
- Claude Haiku: $0.25 / 1M tokens (最便宜) ✅
- OpenAI GPT-3.5: $0.50 / 1M tokens
- OpenAI GPT-4: $30 / 1M tokens (太貴)

---

### 3. 後端選擇 (Firebase vs Supabase)

**如果選擇 Supabase** (推薦):
- ✅ 內建 Vector Search (免費方案即可用)
- ✅ PostgreSQL 更適合結構化資料
- ✅ Row Level Security 更安全
- ✅ 可直接用 SQL 查詢和分析

**如果保持 Firebase**:
- ✅ 目前已整合，無需遷移
- ⚠️ 需要自己實作向量搜尋
- ⚠️ NoSQL 對複雜查詢較不友善

**建議**: 由於要做 AI 推薦，Supabase 的 Vector Search 是很大的優勢。

---

### 4. 資料更新頻率

**建議策略**:
- 📅 **每日同步**: 自動獲取新展覽資料
- 🔄 **即時推薦**: 用戶登入時即時生成推薦
- 💾 **快取機制**: 推薦結果快取 24 小時

---

## 📝 總結

### ✅ 這個方案的優勢

1. **完全合法**: 使用政府開放資料，無法律風險
2. **低成本**: 月成本約 $30-50 USD
3. **可擴展**: 輕鬆處理數千筆展覽資料
4. **智能化**: AI 驅動的個人化推薦
5. **低維護**: 自動化同步，無需手動更新

### 🎯 下一步行動

1. **確認技術決策**:
   - [ ] 確認使用 Claude API (Haiku) 進行 AI 處理
   - [ ] 確認後端選擇 (Firebase vs Supabase)
   - [ ] 確認是否需要 Google Places API 補充

2. **申請 API Keys**:
   - [ ] 申請 Claude API Key (https://console.anthropic.com/)
   - [ ] 申請政府資料開放平臺帳號
   - [ ] (可選) 申請 Google Places API Key

3. **開始實作**:
   - 按照 Phase 1-3 計畫執行
   - 預估總時程: 8-11 天

---

**建立者**: Claude Code
**最後更新**: 2025-11-28
**狀態**: Ready for Implementation
