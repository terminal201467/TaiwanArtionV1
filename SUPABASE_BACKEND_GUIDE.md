# Supabase 後端完全指南 (給新手)

> **建立日期**: 2025-11-28
> **目標**: 手把手教你從零開始建立 TaiwanArtion 的 Supabase 後端
> **適合對象**: 完全沒有後端經驗的 iOS 開發者
> **預估時間**: 4-6 小時 (慢慢來，一步一步做)

---

## 📚 目錄

1. [什麼是 Supabase？](#什麼是-supabase)
2. [為什麼選擇 Supabase？](#為什麼選擇-supabase)
3. [Step 1: 建立 Supabase 帳號](#step-1-建立-supabase-帳號)
4. [Step 2: 創建專案](#step-2-創建專案)
5. [Step 3: 理解資料庫概念](#step-3-理解資料庫概念)
6. [Step 4: 設計資料表](#step-4-設計資料表)
7. [Step 5: 建立第一個資料表](#step-5-建立第一個資料表)
8. [Step 6: 設定安全性 (RLS)](#step-6-設定安全性-rls)
9. [Step 7: 設定認證](#step-7-設定認證)
10. [Step 8: 設定儲存空間](#step-8-設定儲存空間)
11. [Step 9: 測試後端](#step-9-測試後端)
12. [Step 10: 獲取 API Keys](#step-10-獲取-api-keys)
13. [常見問題與錯誤](#常見問題與錯誤)

---

## 什麼是 Supabase？

### 簡單來說

想像 Supabase 是一個**線上的資料庫服務**，就像：

```
你的 App (iOS)  ←→  Supabase (雲端後端)  ←→  PostgreSQL 資料庫

就像你在 App 裡用 UserDefaults 儲存資料，
但 Supabase 是儲存在雲端，所有用戶都能共享！
```

### Supabase 提供什麼？

| 功能 | 說明 | 類比 |
|------|------|------|
| **PostgreSQL 資料庫** | 儲存所有資料 (展覽、用戶、收藏) | 就像 iPhone 的 SQLite，但在雲端 |
| **認證系統** | 用戶登入/註冊 | 就像 Firebase Auth |
| **儲存空間** | 上傳圖片、檔案 | 就像 iCloud Drive |
| **即時訂閱** | 資料更新立即通知 | 就像 WebSocket |
| **Row Level Security** | 用戶只能看自己的資料 | 就像 iOS 的沙盒機制 |

---

## 為什麼選擇 Supabase？

### vs Firebase (你目前使用的)

| 特性 | Firebase | Supabase | 贏家 |
|------|----------|----------|------|
| **資料庫類型** | NoSQL (文檔) | SQL (關聯式) | Supabase ✅ |
| **查詢能力** | 有限 | 非常強大 (SQL) | Supabase ✅ |
| **價格** | $40/月 (1K 用戶) | $35/月 (1K 用戶) | Supabase ✅ |
| **學習曲線** | 簡單 | 中等 | Firebase |
| **開源** | ❌ | ✅ | Supabase ✅ |
| **Vector Search** | ❌ | ✅ (AI 推薦用) | Supabase ✅ |

**結論**: Supabase 更強大、更便宜，但需要學習 SQL (我會教你！)

---

## Step 1: 建立 Supabase 帳號

### 操作步驟 (5 分鐘)

**1.1 前往 Supabase 官網**

```
網址: https://supabase.com
點擊右上角: "Start your project"
```

**1.2 選擇登入方式**

```
推薦使用 GitHub 登入 (最快)
  ↓
點擊 "Continue with GitHub"
  ↓
授權 Supabase 存取你的 GitHub (安全的)
  ↓
完成！
```

**其他登入方式**:
- Google 帳號
- Email + 密碼

**新手提示** 💡:
> 使用 GitHub 登入的好處：
> - 一鍵登入，不用記密碼
> - 可以用 GitHub 管理專案
> - 未來可以用 GitHub Actions 自動部署

**1.3 確認登入成功**

你應該會看到：
```
歡迎畫面
  ↓
"Create a new project" 按鈕
```

---

## Step 2: 創建專案

### 操作步驟 (3 分鐘)

**2.1 點擊 "New Project"**

**2.2 填寫專案資訊**

```
Organization:
  選擇你的名字 (自動創建) 或 "Personal"

Project Name:
  輸入: taiwanartion
  (小寫，不要空格，這很重要！)

Database Password:
  輸入一個強密碼，例如:
  TaiwanArt2025!Secure

Region:
  選擇: Southeast Asia (Singapore)
  (離台灣最近，速度最快！)

Pricing Plan:
  選擇: Free (開始時免費，夠用)
```

**新手提示** 💡:
> **Database Password 很重要！**
> - 這是你的資料庫主密碼
> - 請記在安全的地方 (1Password, Keychain)
> - 不要用 "123456" 這種弱密碼
> - 建議格式: 大小寫 + 數字 + 符號

**2.3 點擊 "Create new project"**

等待 2-3 分鐘，Supabase 會幫你：
```
✅ 創建 PostgreSQL 資料庫
✅ 設定 API 端點
✅ 啟動認證服務
✅ 準備儲存空間
```

**2.4 確認專案建立成功**

你會看到:
```
Dashboard (儀表板)
  ├── Table editor (資料表編輯器)
  ├── SQL Editor (SQL 編輯器)
  ├── Authentication (認證)
  ├── Storage (儲存)
  └── Settings (設定)
```

**恭喜！🎉 你的後端已經啟動了！**

---

## Step 3: 理解資料庫概念

### 給完全新手的解釋

#### 什麼是「資料庫」？

想像資料庫是一個**超級 Excel 檔案**：

```
Excel 試算表:
┌─────────┬──────────┬──────┬────────┐
│ 姓名    │ Email    │ 年齡 │ 城市   │
├─────────┼──────────┼──────┼────────┤
│ 小明    │ ming@... │ 25   │ 台北   │
│ 小華    │ hua@...  │ 30   │ 高雄   │
└─────────┴──────────┴──────┴────────┘

資料庫也是這樣！只是更強大：
- 可以儲存幾百萬筆資料
- 可以快速搜尋
- 可以設定權限 (誰能看、誰能改)
- 可以建立關聯 (像 Excel 的 VLOOKUP)
```

#### 資料庫的基本概念

**1. Table (資料表)**
```
就像一張 Excel 工作表
例如: users 資料表、exhibitions 資料表
```

**2. Column (欄位/列)**
```
就像 Excel 的欄位
例如: 姓名、Email、年齡
```

**3. Row (行/記錄)**
```
就像 Excel 的一行
例如: 一個用戶的完整資料
```

**4. Primary Key (主鍵)**
```
每一行的唯一識別碼
就像身分證字號，不會重複

在 Supabase 通常用 UUID:
例如: 550e8400-e29b-41d4-a716-446655440000
```

**5. Foreign Key (外鍵)**
```
連結到另一個資料表
就像 Excel 的 VLOOKUP

例如:
exhibitions 資料表有 venue_id
  ↓ (連結到)
venues 資料表的 id
```

#### 視覺化範例

```
┌─── exhibitions 資料表 ───────────────────────┐
│ id (UUID)        │ title      │ venue_id   │
├──────────────────┼────────────┼────────────┤
│ aaa-bbb-ccc      │ 印象派展   │ xyz-123    │ ←┐
└──────────────────┴────────────┴────────────┘  │
                                                 │ Foreign Key
┌─── venues 資料表 ───────────────────────────┐  │
│ id (UUID)        │ name           │ city   │  │
├──────────────────┼────────────────┼────────┤  │
│ xyz-123          │ 故宮博物院      │ 台北   │ ←┘
└──────────────────┴────────────────┴────────┘
```

---

## Step 4: 設計資料表

### TaiwanArtion 需要哪些資料表？

#### 核心資料表 (4 個)

**1. exhibitions (展覽資料表)**
```
儲存所有展覽資訊

欄位:
- id: 展覽 ID (主鍵)
- title: 展覽名稱
- description: 展覽描述
- start_date: 開始日期
- end_date: 結束日期
- location: 地點
- image_url: 圖片網址
- price: 票價
- category: 分類
- tags: 標籤 (Array)
- venue_id: 展覽館 ID (外鍵)
```

**2. venues (展覽館資料表)**
```
儲存所有展覽館資訊

欄位:
- id: 展覽館 ID (主鍵)
- name: 展覽館名稱
- address: 地址
- city: 城市
- latitude: 緯度
- longitude: 經度
- phone: 電話
- website: 官網
- google_place_id: Google Place ID
```

**3. user_favorites (用戶收藏表)**
```
儲存用戶收藏的展覽

欄位:
- id: 記錄 ID (主鍵)
- user_id: 用戶 ID (外鍵)
- exhibition_id: 展覽 ID (外鍵)
- created_at: 收藏時間
```

**4. user_recommendations (AI 推薦快取表)**
```
儲存 AI 生成的推薦結果

欄位:
- id: 記錄 ID (主鍵)
- user_id: 用戶 ID
- exhibition_ids: 推薦的展覽 ID 陣列
- generated_at: 生成時間
- expires_at: 過期時間
```

#### 資料表關聯圖

```
┌─────────────┐       ┌──────────────┐
│  venues     │◄──┐   │ exhibitions  │
│             │   └───│ (venue_id)   │
└─────────────┘       └───────┬──────┘
                              │
                              │ Foreign Key
                              ↓
                      ┌───────────────┐
                      │ user_favorites│
                      │ (exhibition_id│
                      └───────┬───────┘
                              │
                              │ Foreign Key
                              ↓
                      ┌───────────────┐
                      │ auth.users    │
                      │ (Supabase內建)│
                      └───────────────┘
```

---

## Step 5: 建立第一個資料表

### 新手友善教學：建立 exhibitions 資料表

#### 方法一：使用圖形介面 (推薦新手) 👶

**5.1 進入 Table Editor**

```
Dashboard 左側選單
  ↓
點擊 "Table Editor"
  ↓
點擊右上角 "New table"
```

**5.2 填寫資料表資訊**

```
Name: exhibitions
Description: 展覽資料表

☑ Enable Row Level Security (RLS)
  (先打勾，我們等等會設定)
```

**5.3 新增欄位 (Columns)**

點擊 "+ Add column"，一個一個新增：

**第 1 個欄位: id (主鍵)**
```
Name: id
Type: uuid
Default value: gen_random_uuid()
☑ Primary
☑ Unique
```

**第 2 個欄位: title (展覽名稱)**
```
Name: title
Type: text
☐ Nullable (不勾選，表示必填)
```

**第 3 個欄位: description (描述)**
```
Name: description
Type: text
☑ Nullable (可以為空)
```

**第 4 個欄位: category (分類)**
```
Name: category
Type: text
☑ Nullable
```

**第 5 個欄位: tags (標籤)**
```
Name: tags
Type: text[] (text array)
☑ Nullable
```

**第 6 個欄位: start_date (開始日期)**
```
Name: start_date
Type: timestamptz (timestamp with timezone)
☑ Nullable
```

**第 7 個欄位: end_date (結束日期)**
```
Name: end_date
Type: timestamptz
☑ Nullable
```

**第 8 個欄位: location (地點)**
```
Name: location
Type: text
☑ Nullable
```

**第 9 個欄位: venue_id (展覽館 ID)**
```
Name: venue_id
Type: uuid
☑ Nullable
(我們等等會設定 Foreign Key)
```

**第 10 個欄位: image_url (圖片網址)**
```
Name: image_url
Type: text
☑ Nullable
```

**第 11 個欄位: price (票價)**
```
Name: price
Type: text
☑ Nullable
```

**第 12 個欄位: website (官網)**
```
Name: website
Type: text
☑ Nullable
```

**第 13 個欄位: source (資料來源)**
```
Name: source
Type: text
☑ Nullable
```

**第 14 個欄位: ai_generated (AI 生成標記)**
```
Name: ai_generated
Type: boolean
Default value: false
```

**第 15 個欄位: created_at (建立時間)**
```
Name: created_at
Type: timestamptz
Default value: now()
```

**第 16 個欄位: updated_at (更新時間)**
```
Name: updated_at
Type: timestamptz
Default value: now()
```

**5.4 點擊 "Save" 儲存**

**恭喜！🎉 你的第一個資料表建立完成了！**

---

#### 方法二：使用 SQL (進階) 🚀

如果你想學 SQL (推薦！)，可以用這個方法：

**5.1 進入 SQL Editor**

```
Dashboard 左側選單
  ↓
點擊 "SQL Editor"
  ↓
點擊 "New query"
```

**5.2 貼上以下 SQL 代碼**

```sql
-- 建立 exhibitions 資料表
CREATE TABLE exhibitions (
  -- 主鍵 (Primary Key)
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- 基本資訊
  title TEXT NOT NULL,  -- NOT NULL = 必填
  description TEXT,
  category TEXT,
  tags TEXT[],  -- TEXT[] = 文字陣列

  -- 日期
  start_date TIMESTAMPTZ,  -- TIMESTAMPTZ = 帶時區的時間戳記
  end_date TIMESTAMPTZ,

  -- 地點
  location TEXT,
  venue_id UUID,  -- 等等會設定 Foreign Key

  -- 多媒體
  image_url TEXT,

  -- 其他資訊
  price TEXT,
  website TEXT,
  source TEXT,
  ai_generated BOOLEAN DEFAULT false,

  -- 時間戳記 (自動記錄)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 建立索引 (讓查詢更快)
CREATE INDEX idx_exhibitions_category ON exhibitions(category);
CREATE INDEX idx_exhibitions_start_date ON exhibitions(start_date);
CREATE INDEX idx_exhibitions_venue_id ON exhibitions(venue_id);

-- 加上註解 (讓其他開發者知道這是什麼)
COMMENT ON TABLE exhibitions IS '展覽資料表';
COMMENT ON COLUMN exhibitions.title IS '展覽名稱';
COMMENT ON COLUMN exhibitions.tags IS 'AI 生成的標籤';
```

**5.3 點擊右下角 "Run" (或按 Cmd+Enter)**

你會看到:
```
Success. No rows returned
```

**5.4 確認資料表建立成功**

```
回到 Table Editor
  ↓
應該會看到 "exhibitions" 資料表
```

**新手提示** 💡:
> **SQL 不難！只是看起來嚇人**
>
> 拆解來看：
> ```sql
> CREATE TABLE exhibitions (  -- 創建名為 exhibitions 的資料表
>   id UUID PRIMARY KEY,      -- id 欄位，類型是 UUID，是主鍵
>   title TEXT NOT NULL       -- title 欄位，類型是文字，不能空白
> );
> ```
>
> 就像在說：
> "創建一個叫 exhibitions 的表格，裡面有 id 和 title 兩個欄位"

---

### 建立其他資料表

用同樣的方法，建立其他 3 個資料表：

**venues (展覽館)**

<details>
<summary>點擊展開 SQL 代碼</summary>

```sql
CREATE TABLE venues (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,  -- UNIQUE = 不能重複
  address TEXT,
  city TEXT,
  latitude DECIMAL(10, 8),  -- 緯度 (小數點後8位)
  longitude DECIMAL(11, 8),  -- 經度
  phone TEXT,
  website TEXT,
  google_place_id TEXT UNIQUE,
  google_data JSONB,  -- JSONB = 儲存 JSON 格式資料
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_venues_city ON venues(city);
CREATE INDEX idx_venues_location ON venues(latitude, longitude);
```

</details>

**user_favorites (用戶收藏)**

<details>
<summary>點擊展開 SQL 代碼</summary>

```sql
CREATE TABLE user_favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exhibition_id UUID NOT NULL REFERENCES exhibitions(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- 確保同一個用戶不會重複收藏同一個展覽
  UNIQUE(user_id, exhibition_id)
);

-- 索引
CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_user_favorites_exhibition_id ON user_favorites(exhibition_id);
```

</details>

**user_recommendations (推薦快取)**

<details>
<summary>點擊展開 SQL 代碼</summary>

```sql
CREATE TABLE user_recommendations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,  -- 暫時用 TEXT，因為可能來自不同的認證系統
  exhibition_ids UUID[],  -- UUID 陣列
  generated_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours',

  -- 每個用戶只有一筆推薦記錄
  UNIQUE(user_id)
);

-- 索引
CREATE INDEX idx_user_recommendations_user_id ON user_recommendations(user_id);
CREATE INDEX idx_user_recommendations_expires_at ON user_recommendations(expires_at);
```

</details>

---

## Step 6: 設定安全性 (RLS)

### 什麼是 Row Level Security (RLS)？

#### 簡單比喻

想像你在 Instagram：
```
❌ 你不能看到別人的私訊
❌ 你不能刪除別人的貼文
✅ 你只能看到公開的貼文
✅ 你只能編輯自己的貼文

RLS 就是這個！
```

在 Supabase 中：
```
✅ 所有人可以看展覽資訊 (exhibitions)
❌ 只有自己可以看自己的收藏 (user_favorites)
❌ 只有自己可以修改自己的收藏
```

### 為什麼需要 RLS？

**沒有 RLS 的風險** ❌:
```sql
-- 任何人都能執行這個，刪除所有資料！
DELETE FROM user_favorites;

-- 任何人都能看到所有用戶的收藏
SELECT * FROM user_favorites;
```

**有 RLS 的保護** ✅:
```sql
-- 只能刪除自己的收藏
DELETE FROM user_favorites WHERE user_id = auth.uid();

-- 只能看到自己的收藏
SELECT * FROM user_favorites WHERE user_id = auth.uid();
```

---

### 設定 RLS 政策

#### exhibitions 資料表 (所有人可讀)

**6.1 進入 Authentication → Policies**

```
Table Editor
  ↓
點擊 "exhibitions" 資料表
  ↓
上方 Tab 選擇 "Policies"
  ↓
點擊 "Enable RLS" (啟用行級安全)
```

**6.2 新增政策: 所有人可以讀取展覽**

點擊 "+ New Policy"

```
Policy name:
  Allow public read access

Allowed operation:
  SELECT (查詢)

Target roles:
  public (所有人，包括未登入用戶)

USING expression:
  true  (永遠允許)
```

**用 SQL 的話:**
```sql
CREATE POLICY "Allow public read access on exhibitions"
  ON exhibitions
  FOR SELECT
  USING (true);
```

**解釋**:
```
這個政策說：
"任何人 (public) 都可以讀取 (SELECT) exhibitions 資料表的所有資料"
```

---

#### user_favorites 資料表 (只能看自己的)

**6.3 新增政策: 用戶只能看自己的收藏**

```
Policy name:
  Users can view own favorites

Allowed operation:
  SELECT

Target roles:
  authenticated (已登入用戶)

USING expression:
  auth.uid() = user_id
```

**用 SQL:**
```sql
CREATE POLICY "Users can view own favorites"
  ON user_favorites
  FOR SELECT
  USING (auth.uid() = user_id);
```

**解釋**:
```
auth.uid() = 當前登入用戶的 ID
user_id = 這筆收藏記錄的擁有者 ID

只有當 "當前用戶 ID" = "收藏擁有者 ID" 時，才能看到
```

**6.4 新增政策: 用戶可以新增自己的收藏**

```
Policy name:
  Users can insert own favorites

Allowed operation:
  INSERT

Target roles:
  authenticated

WITH CHECK expression:
  auth.uid() = user_id
```

**用 SQL:**
```sql
CREATE POLICY "Users can insert own favorites"
  ON user_favorites
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

**6.5 新增政策: 用戶可以刪除自己的收藏**

```
Policy name:
  Users can delete own favorites

Allowed operation:
  DELETE

Target roles:
  authenticated

USING expression:
  auth.uid() = user_id
```

**用 SQL:**
```sql
CREATE POLICY "Users can delete own favorites"
  ON user_favorites
  FOR DELETE
  USING (auth.uid() = user_id);
```

---

### RLS 完整設定腳本

**一次性設定所有 RLS 政策**:

```sql
-- ============================================
-- 1. exhibitions 資料表 (公開讀取)
-- ============================================

-- 啟用 RLS
ALTER TABLE exhibitions ENABLE ROW LEVEL SECURITY;

-- 所有人可以讀取
CREATE POLICY "Allow public read access on exhibitions"
  ON exhibitions
  FOR SELECT
  USING (true);

-- ============================================
-- 2. venues 資料表 (公開讀取)
-- ============================================

ALTER TABLE venues ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on venues"
  ON venues
  FOR SELECT
  USING (true);

-- ============================================
-- 3. user_favorites 資料表 (用戶專屬)
-- ============================================

ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

-- 查詢：只能看自己的
CREATE POLICY "Users can view own favorites"
  ON user_favorites
  FOR SELECT
  USING (auth.uid() = user_id);

-- 新增：只能新增自己的
CREATE POLICY "Users can insert own favorites"
  ON user_favorites
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 刪除：只能刪除自己的
CREATE POLICY "Users can delete own favorites"
  ON user_favorites
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- 4. user_recommendations 資料表 (用戶專屬)
-- ============================================

ALTER TABLE user_recommendations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own recommendations"
  ON user_recommendations
  FOR SELECT
  USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own recommendations"
  ON user_recommendations
  FOR INSERT
  WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update own recommendations"
  ON user_recommendations
  FOR UPDATE
  USING (auth.uid()::text = user_id);
```

**新手提示** 💡:
> **測試 RLS 是否生效**:
>
> 1. 在 SQL Editor 執行：
> ```sql
> SELECT * FROM user_favorites;
> ```
>
> 2. 如果你**沒登入**，應該會看到：
> ```
> 0 rows returned
> ```
>
> 3. 這是正確的！因為 RLS 阻止了未登入用戶查詢

---

## Step 7: 設定認證

### 啟用 Email/Password 登入

**7.1 進入 Authentication 設定**

```
Dashboard 左側選單
  ↓
點擊 "Authentication"
  ↓
點擊 "Providers"
```

**7.2 啟用 Email 認證**

```
找到 "Email"
  ↓
Toggle 開關 (打開)
  ↓
設定:
  ☑ Enable Email provider
  ☑ Confirm email (建議打開，驗證 Email)
  ☐ Secure email change (可選)

Save
```

### 啟用 Google 登入

**7.3 設定 Google OAuth**

```
找到 "Google"
  ↓
Toggle 開關 (打開)
  ↓
需要填寫:
  - Client ID (從 Google Cloud Console 獲取)
  - Client Secret
```

**如何獲取 Google Client ID？**

<details>
<summary>點擊展開詳細步驟</summary>

1. 前往 [Google Cloud Console](https://console.cloud.google.com/)

2. 創建新專案或選擇現有專案

3. 啟用 Google+ API:
   ```
   APIs & Services → Library → 搜尋 "Google+ API" → Enable
   ```

4. 創建 OAuth 2.0 憑證:
   ```
   APIs & Services → Credentials → Create Credentials → OAuth client ID
   ```

5. 應用程式類型:
   ```
   選擇: iOS
   Bundle ID: 輸入你的 App Bundle ID
   ```

6. 複製 Client ID 和 Client Secret

7. 貼回 Supabase

</details>

### 啟用 Facebook 登入

**7.4 設定 Facebook OAuth**

```
找到 "Facebook"
  ↓
Toggle 開關 (打開)
  ↓
需要填寫:
  - Client ID (App ID)
  - Client Secret
```

---

## Step 8: 設定儲存空間

### 為什麼需要 Storage？

```
用途:
- 上傳用戶頭像
- 上傳展覽圖片 (如果有自己的展覽資料)
- 暫存檔案
```

### 建立 Storage Bucket

**8.1 進入 Storage**

```
Dashboard 左側選單
  ↓
點擊 "Storage"
  ↓
點擊 "New bucket"
```

**8.2 創建 Bucket**

```
Name: avatars
Public: ☑ (打勾，讓圖片可以公開存取)

Create bucket
```

**8.3 設定 Storage Policy**

```
點擊 "avatars" bucket
  ↓
點擊 "Policies"
  ↓
New Policy
```

**允許所有人讀取:**
```sql
CREATE POLICY "Allow public read access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');
```

**允許已登入用戶上傳:**
```sql
CREATE POLICY "Allow authenticated upload"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated'
  );
```

---

## Step 9: 測試後端

### 插入測試資料

**9.1 進入 SQL Editor**

**9.2 插入測試展覽**

```sql
-- 插入一個測試展覽
INSERT INTO exhibitions (
  title,
  description,
  category,
  start_date,
  end_date,
  location,
  price
) VALUES (
  '印象派大師展',
  '展出莫內、雷諾瓦等印象派大師作品',
  '西洋美術',
  '2025-12-01',
  '2026-03-31',
  '國立故宮博物院',
  'NT$350'
);
```

**9.3 查詢資料**

```sql
-- 查看剛剛插入的資料
SELECT * FROM exhibitions;
```

你應該會看到:
```
1 row returned
  ↓
id: 550e8400-e29b-41d4-a716-446655440000
title: 印象派大師展
description: 展出莫內、雷諾瓦等印象派大師作品
...
```

**恭喜！🎉 你的資料庫可以正常運作了！**

---

## Step 10: 獲取 API Keys

### 什麼是 API Key？

```
API Key 就像你家的鑰匙
  ↓
iOS App 用它來存取 Supabase
  ↓
沒有 API Key = 打不開門
```

### 獲取 API Keys

**10.1 進入 Settings**

```
Dashboard 左側選單 (最下方)
  ↓
點擊 "Settings"
  ↓
點擊 "API"
```

**10.2 複製 API Keys**

你會看到兩個 Key：

**1. Project URL**
```
https://xxxxxx.supabase.co

這是你的 Supabase 專案網址
iOS App 會用這個連線
```

**2. anon public (公開 Key)**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

這是給 iOS App 用的
可以公開，但有 RLS 保護
```

**3. service_role (服務 Key)**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

⚠️ 這個絕對不能洩漏！
這個 Key 可以繞過所有 RLS 規則
只在伺服器端使用
```

**10.3 儲存到環境變數**

在你的 `.env` 檔案:
```bash
SUPABASE_URL=https://xxxxxx.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**重要提醒** ⚠️:
```
✅ anon public key → 可以放在 iOS App
❌ service_role key → 絕對不要放在 iOS App
❌ Database Password → 絕對不要放在 iOS App

加入到 .gitignore:
.env
GoogleService-Info.plist
```

---

## 常見問題與錯誤

### Q1: 為什麼查詢不到資料？

**可能原因 1: RLS 阻擋**
```sql
-- 檢查 RLS 是否啟用
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';

-- 如果 rowsecurity = true，檢查 policies
SELECT * FROM pg_policies WHERE tablename = 'exhibitions';
```

**解決方法**:
```sql
-- 暫時關閉 RLS (僅測試用)
ALTER TABLE exhibitions DISABLE ROW LEVEL SECURITY;

-- 測試完記得開回來
ALTER TABLE exhibitions ENABLE ROW LEVEL SECURITY;
```

---

### Q2: 插入資料失敗

**錯誤訊息**:
```
new row violates row-level security policy
```

**原因**: RLS WITH CHECK 條件不符

**解決方法**:
```sql
-- 檢查 INSERT policy
SELECT * FROM pg_policies
WHERE tablename = 'user_favorites'
AND cmd = 'INSERT';

-- 確保 user_id 正確
INSERT INTO user_favorites (user_id, exhibition_id)
VALUES (auth.uid(), '550e8400...');  -- 使用 auth.uid()
```

---

### Q3: Foreign Key 錯誤

**錯誤訊息**:
```
insert or update on table "user_favorites" violates
foreign key constraint "user_favorites_exhibition_id_fkey"
```

**原因**: exhibition_id 不存在

**解決方法**:
```sql
-- 先檢查 exhibition 是否存在
SELECT id FROM exhibitions WHERE id = 'xxx';

-- 如果不存在，先插入 exhibition
INSERT INTO exhibitions (title, ...) VALUES (...);
```

---

### Q4: 時區問題

**現象**: 時間不對，差了 8 小時

**原因**: 沒用 TIMESTAMPTZ

**解決方法**:
```sql
-- 錯誤
CREATE TABLE test (
  created_at TIMESTAMP  -- 沒有時區
);

-- 正確
CREATE TABLE test (
  created_at TIMESTAMPTZ DEFAULT NOW()  -- 有時區
);
```

---

### Q5: 如何重置資料庫？

**警告** ⚠️: 這會刪除所有資料！

```sql
-- 刪除所有資料表
DROP TABLE IF EXISTS user_recommendations CASCADE;
DROP TABLE IF EXISTS user_favorites CASCADE;
DROP TABLE IF EXISTS exhibitions CASCADE;
DROP TABLE IF EXISTS venues CASCADE;

-- 重新執行建表腳本
-- (從 Step 5 開始)
```

---

## 📊 檢查清單

### 完成 Supabase 後端設定

- [ ] ✅ 建立 Supabase 帳號
- [ ] ✅ 創建專案 (taiwanartion)
- [ ] ✅ 建立 4 個資料表
  - [ ] exhibitions
  - [ ] venues
  - [ ] user_favorites
  - [ ] user_recommendations
- [ ] ✅ 設定 RLS 政策 (8 個政策)
- [ ] ✅ 啟用 Email 認證
- [ ] ✅ 啟用 Google 登入
- [ ] ✅ 啟用 Facebook 登入
- [ ] ✅ 建立 Storage Bucket (avatars)
- [ ] ✅ 測試插入資料
- [ ] ✅ 獲取 API Keys
- [ ] ✅ 設定環境變數

---

## 🎯 下一步

完成這個指南後，你應該：

1. ✅ 有一個完整運作的 Supabase 後端
2. ✅ 理解資料庫的基本概念
3. ✅ 知道如何用 SQL 操作資料
4. ✅ 了解 RLS 安全性機制
5. ✅ 準備好連接 iOS App

**接下來**:
- 回到 [IMPLEMENTATION_SPEC_KIT.md](./IMPLEMENTATION_SPEC_KIT.md)
- 繼續 Phase B: Task B.2 (iOS SDK 整合)

---

## 📚 延伸學習資源

### 官方文檔
- [Supabase 官方文檔](https://supabase.com/docs)
- [PostgreSQL 教學](https://www.postgresql.org/docs/current/tutorial.html)
- [Row Level Security 詳解](https://supabase.com/docs/guides/auth/row-level-security)

### 推薦教學
- [SQL 基礎教學](https://www.w3schools.com/sql/)
- [Supabase YouTube 頻道](https://www.youtube.com/@Supabase)

---

**建立者**: Claude Code
**最後更新**: 2025-11-28
**適合對象**: 後端新手
**預估學習時間**: 4-6 小時
