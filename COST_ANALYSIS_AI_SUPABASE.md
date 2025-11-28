# TaiwanArtion 成本分析：AI + Supabase 方案

> **建立日期**: 2025-11-28
> **方案**: Claude Haiku + Supabase + Google Places API
> **目的**: 評估真實成本，避免意外帳單

---

## 📊 成本總覽

### 快速結論 (TL;DR)

| 用戶規模 | 月成本 (USD) | 月成本 (TWD) | 說明 |
|---------|-------------|-------------|------|
| **測試階段** (50 用戶) | **$0-5** | **$0-150** | 幾乎免費 ✅ |
| **小規模** (100-500 用戶) | **$10-25** | **$300-750** | 非常便宜 ✅ |
| **中規模** (1000 用戶) | **$30-50** | **$900-1500** | 可接受 ✅ |
| **大規模** (5000 用戶) | **$80-150** | **$2400-4500** | 需優化 ⚠️ |

**對比現有 Firebase 方案**:
- 100 用戶: Firebase ~$10/月 vs 新方案 ~$15/月 (多 $5)
- 1000 用戶: Firebase ~$40/月 vs 新方案 ~$40/月 (幾乎相同)
- 5000 用戶: Firebase ~$200/月 vs 新方案 ~$120/月 (省 $80) ✅

---

## 💰 詳細成本拆解

### 1. Supabase 成本

#### 方案選擇

| 方案 | 價格 | 適用規模 | 包含內容 |
|------|------|---------|---------|
| **Free** | $0/月 | 0-100 用戶 | 500MB DB, 1GB 儲存, 2GB 流量 |
| **Pro** | $25/月 | 100-5000 用戶 | 8GB DB, 100GB 儲存, 250GB 流量 |
| **Team** | $599/月 | 5000+ 用戶 | 更大容量 (暫不考慮) |

#### 詳細計算

**資料庫儲存**:
```
每筆展覽約 2KB
1000 筆展覽 = 2MB
10000 筆展覽 = 20MB
用戶資料 (1000 用戶) = 5MB

總計: 約 25-50MB (遠低於 8GB 限制) ✅
```

**流量消耗**:
```
每次 API 請求平均 10KB
每用戶每月 100 次請求
1000 用戶 = 100,000 請求 = 1GB 流量

總計: 1-5GB/月 (遠低於 250GB 限制) ✅
```

**結論**:
- 0-100 用戶: **免費方案即可** ✅
- 100-5000 用戶: **Pro 方案 $25/月** 足夠

---

### 2. Claude API 成本

#### 定價

```
Claude 3 Haiku:
- 輸入: $0.25 / 1M tokens
- 輸出: $1.25 / 1M tokens
```

#### 使用場景分析

**場景 1: 資料標準化 (每日執行一次)**

```
假設每日新增/更新 50 筆展覽
每筆展覽處理:
  - 輸入: 500 tokens (原始資料 + prompt)
  - 輸出: 300 tokens (標準化 JSON)

每日成本:
  - 輸入: 50 × 500 = 25,000 tokens × $0.25/1M = $0.00625
  - 輸出: 50 × 300 = 15,000 tokens × $1.25/1M = $0.01875
  - 每日小計: $0.025

月成本: $0.025 × 30 = $0.75/月 ✅
```

**場景 2: AI 推薦生成**

這是成本的關鍵！有兩種實作方式：

**方式 A: 即時 AI 推薦 (每次登入都調用 AI)**
```
每用戶每日登入 2 次
每次推薦:
  - 輸入: 2000 tokens (用戶資料 + 100 筆展覽摘要)
  - 輸出: 200 tokens (推薦結果)

1000 用戶/月:
  - 請求次數: 1000 × 2 × 30 = 60,000 次
  - 輸入: 60,000 × 2000 = 120M tokens × $0.25 = $30
  - 輸出: 60,000 × 200 = 12M tokens × $1.25 = $15
  - 月成本: $45/月 ⚠️ (太貴!)
```

**方式 B: 智能快取推薦 (推薦) ✅**
```
策略:
1. 每用戶每 24 小時才重新生成推薦
2. 推薦結果快取在 Supabase
3. 24 小時內直接讀取快取

1000 用戶/月:
  - 請求次數: 1000 × 1 × 30 = 30,000 次 (減少 50%)
  - 輸入: 30,000 × 2000 = 60M tokens × $0.25 = $15
  - 輸出: 30,000 × 200 = 6M tokens × $1.25 = $7.5
  - 月成本: $22.5/月 ✅ (可接受)
```

**更激進的優化: 方式 C: 批次推薦 (最省錢) ✅✅**
```
策略:
1. 每日凌晨批次處理所有用戶推薦
2. 用戶只讀取預先計算的結果
3. 新用戶才即時生成推薦

1000 用戶/月:
  - 每日批次: 1000 用戶 × 1 次 = 1000 次/日
  - 月請求: 1000 × 30 = 30,000 次
  - 輸入: 60M tokens × $0.25 = $15
  - 輸出: 6M tokens × $1.25 = $7.5
  - 月成本: $22.5/月

  但可以優化:
  - 只為活躍用戶生成 (假設 30% 活躍)
  - 實際成本: $22.5 × 0.3 = $6.75/月 ✅✅
```

**Claude API 月成本總結**:
- 資料標準化: $0.75/月
- AI 推薦 (方式 C): $6.75/月
- **總計: $7.5/月** ✅

---

### 3. Google Places API 成本

#### 定價

```
Place Details API: $17 / 1000 requests
```

#### 使用場景

**展覽館資訊獲取**:
```
假設台灣有 200 個展覽館
每個展覽館呼叫 1 次 Place Details API

初始成本:
  - 200 × $17/1000 = $3.4 (一次性)

每月更新:
  - 假設每月新增 5 個展覽館
  - 5 × $17/1000 = $0.085/月 ≈ $0.1/月
```

**優化策略**:
```
1. 展覽館資訊快取在 Supabase (永久儲存)
2. 同一展覽館只調用一次 API
3. 每月只為新展覽館調用

實際月成本: $0.1-0.5/月 ✅
```

---

### 4. 政府開放資料 API

```
成本: $0 (完全免費) ✅
限制: 無 (政府公開資料)
```

---

## 📈 不同規模成本試算

### 測試階段 (50 用戶)

| 項目 | 成本 |
|------|------|
| Supabase Free | $0 |
| Claude API | $1.5 |
| Google Places | $0.1 |
| **總計** | **$1.6/月** ≈ **NT$48** |

---

### 小規模 (500 用戶)

| 項目 | 成本 |
|------|------|
| Supabase Pro | $25 |
| Claude API (資料標準化) | $0.75 |
| Claude API (AI 推薦，30% 活躍) | $3.38 |
| Google Places | $0.2 |
| **總計** | **$29.33/月** ≈ **NT$880** |

---

### 中規模 (1000 用戶)

| 項目 | 成本 |
|------|------|
| Supabase Pro | $25 |
| Claude API (資料標準化) | $0.75 |
| Claude API (AI 推薦，30% 活躍) | $6.75 |
| Google Places | $0.5 |
| **總計** | **$33/月** ≈ **NT$990** |

**對比 Firebase 方案**: $40/月
**節省**: $7/月 ✅

---

### 大規模 (5000 用戶)

| 項目 | 成本 |
|------|------|
| Supabase Pro | $25 |
| Supabase 超額費用 (估算) | $10 |
| Claude API (資料標準化) | $0.75 |
| Claude API (AI 推薦，30% 活躍) | $33.75 |
| Google Places | $1 |
| **總計** | **$70.5/月** ≈ **NT$2115** |

**對比 Firebase 方案**: $200/月
**節省**: $129.5/月 ✅✅

---

## 🎯 成本優化策略

### 立即可做 (省 60-70% 成本)

#### 1. AI 推薦快取策略 ✅

```swift
// ViewModel 中實作快取
func loadRecommendations() {
    // 1. 先檢查快取
    if let cached = getCachedRecommendations(),
       cached.timestamp.isWithin24Hours {
        AppLogger.debug("使用快取推薦", category: .viewModel)
        self.recommendations.accept(cached.exhibitions)
        return
    }

    // 2. 快取過期才調用 AI
    AppLogger.debug("快取過期，生成新推薦", category: .viewModel)
    generateNewRecommendations()
}
```

**省錢效果**: 減少 50% AI 請求

---

#### 2. 批次處理 + 活躍用戶過濾 ✅

```swift
// 每日凌晨執行 (Firebase Cloud Functions 或 Supabase Edge Functions)
func dailyBatchRecommendation() {
    // 只為最近 7 天活躍的用戶生成推薦
    let activeUsers = getActiveUsers(days: 7)  // 假設 30% 用戶

    for user in activeUsers {
        let recommendations = await generateRecommendations(for: user)
        await saveToCache(user.id, recommendations)
    }
}
```

**省錢效果**: 減少 70% AI 請求

---

#### 3. Google Places 一次性抓取 ✅

```swift
// 初始化時一次抓取所有展覽館
func initializeVenues() {
    let venues = getAllVenuesFromGovernmentAPI()

    for venue in venues {
        // 檢查是否已有資料
        if !venueExistsInDB(venue.name) {
            let placeDetails = await googlePlacesAPI.getDetails(venue.name)
            await saveVenueToDB(placeDetails)
        }
    }
}
```

**省錢效果**: Google Places 成本 < $1/月

---

### 進階優化 (未來可做)

#### 4. 使用 Supabase Edge Functions 減少 AI 調用

```typescript
// Supabase Edge Function (在伺服器端執行)
// 好處: 可以批次處理，減少重複計算

export async function generateRecommendations(userId: string) {
  // 檢查相似用戶的推薦 (協同過濾)
  const similarUsers = await findSimilarUsers(userId)

  if (similarUsers.length > 0) {
    // 直接使用相似用戶的推薦，無需調用 AI
    return similarUsers[0].recommendations
  }

  // 沒有相似用戶才調用 AI
  return await callClaudeAPI(userId)
}
```

**省錢效果**: 額外減少 30% AI 請求

---

#### 5. 向量嵌入 (一次性成本，長期省錢)

```swift
// 一次性將所有展覽轉為向量
展覽描述 → OpenAI Embeddings → Supabase Vector

// 之後推薦只需向量搜尋 (幾乎免費)
用戶偏好向量 → Vector Search → 推薦結果

成本:
  - 初始化: 1000 展覽 × $0.0001 = $0.1 (一次性)
  - 每月新增: 50 展覽 × $0.0001 = $0.005
  - 推薦成本: $0 (向量搜尋免費)
```

**省錢效果**: AI 推薦成本 → $0

---

## 💡 建議方案

### 階段性策略 (最省錢)

#### Phase 1: 上線初期 (0-100 用戶)

```
✅ Supabase Free 方案 ($0)
✅ 基礎 AI 推薦 (方式 C - 批次處理)
✅ Google Places 一次性抓取

月成本: $1-2 ✅
```

#### Phase 2: 成長期 (100-1000 用戶)

```
✅ 升級 Supabase Pro ($25)
✅ 加入快取策略
✅ 活躍用戶過濾

月成本: $30-35 ✅
```

#### Phase 3: 擴展期 (1000-5000 用戶)

```
✅ 考慮向量嵌入推薦 (降低 AI 成本)
✅ 協同過濾策略
✅ 更激進的快取

月成本: $50-70 ✅
(對比 Firebase $200，省 60%)
```

---

## ⚠️ 成本風險控制

### 設定預算警告

#### 1. Supabase 預算控制

```
1. 登入 Supabase Dashboard
2. Settings → Billing
3. 設定月預算上限: $50
4. 超過 80% 發送警告
```

#### 2. Claude API 預算控制

```
1. Anthropic Console → Usage
2. 設定每月 Token 上限
3. 超過閾值自動停止 (或降級到快取模式)
```

#### 3. Google API 預算控制

```
1. Google Cloud Console → Billing
2. 設定每月預算: $10
3. 設定配額: 500 requests/day
```

---

### 應急降級方案

```swift
// 當成本超標時，自動降級
func getRecommendations() -> [Exhibition] {
    // 檢查本月 AI 使用量
    if monthlyAIUsage > budgetLimit {
        AppLogger.warning("AI 預算超標，使用備用推薦", category: .viewModel)

        // 降級方案 1: 基於規則的推薦 (不用 AI)
        return getRuleBasedRecommendations()

        // 降級方案 2: 熱門展覽
        return getPopularExhibitions()
    }

    // 正常使用 AI
    return getAIRecommendations()
}
```

---

## 📊 成本對比總結

### 現有 Firebase 方案

| 用戶數 | 月成本 | 年成本 |
|-------|--------|--------|
| 100 | $10 | $120 |
| 500 | $25 | $300 |
| 1000 | $40 | $480 |
| 5000 | $200 | $2400 |

### 新方案：Claude + Supabase + Google Places

| 用戶數 | 月成本 (未優化) | 月成本 (優化後) | 年成本 (優化後) |
|-------|----------------|----------------|----------------|
| 100 | $15 | **$2** ✅ | $24 |
| 500 | $50 | **$30** ✅ | $360 |
| 1000 | $75 | **$35** ✅ | $420 |
| 5000 | $150 | **$70** ✅ | $840 |

### 成本差異

| 用戶數 | Firebase | 新方案 (優化) | 差異 |
|-------|---------|--------------|------|
| 100 | $120/年 | $24/年 | **省 $96** ✅ |
| 500 | $300/年 | $360/年 | 多 $60 ⚠️ |
| 1000 | $480/年 | $420/年 | **省 $60** ✅ |
| 5000 | $2400/年 | $840/年 | **省 $1560** ✅✅ |

---

## ✅ 最終建議

### 值得採用嗎？

**是的！** ✅ 但要注意以下幾點：

#### 優點
1. ✅ **初期成本極低** (0-100 用戶幾乎免費)
2. ✅ **用戶規模大時省更多** (5000 用戶省 $1560/年)
3. ✅ **功能更強大** (AI 個人化推薦 + Vector Search)
4. ✅ **可控性高** (清楚知道每一分錢花在哪)

#### 需注意
1. ⚠️ 500 用戶時稍微貴一點 (多 $60/年，但有 AI 推薦功能)
2. ⚠️ 需要實作快取和優化策略
3. ⚠️ 需要設定預算警告

---

### 實施建議

#### 立即可做
1. ✅ 申請 Supabase Free 帳號 (測試用)
2. ✅ 申請 Claude API Key ($5 免費額度)
3. ✅ 實作基礎推薦功能 (批次 + 快取)

#### 上線前
1. ✅ 設定所有預算警告
2. ✅ 實作降級方案
3. ✅ 測試成本控制機制

#### 上線後
1. 📊 每週監控成本
2. 📊 根據實際使用調整策略
3. 📊 優先實作向量嵌入 (長期省錢)

---

## 🎯 結論

**總成本 (1000 用戶，優化後)**:
```
月成本: $35 ≈ NT$1050
年成本: $420 ≈ NT$12,600

每用戶成本: $0.035/月 ≈ NT$1/月
```

**對比星巴克**: 一杯拿鐵 = 支撐 120 位用戶一個月 ☕

**這個價格，值得！** ✅

---

**建立者**: Claude Code
**最後更新**: 2025-11-28
**匯率**: 1 USD ≈ 30 TWD
