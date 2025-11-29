# TaiwanArtion V1 實作規格書 (Spec-Kit)

> **建立日期**: 2025-11-28
> **目標**: AI 驅動展覽推薦系統 + 最省錢方案
> **預估時程**: 12-15 個工作天
> **成本**: 測試階段 $2/月，上線後 $35/月 (1000 用戶)

---

## 📋 專案概覽

### 核心目標
將 TaiwanArtion 從固定 Firebase 資料改為 **AI 驅動的智能推薦系統**，使用最省錢的技術方案。

### 技術棧選擇 (已確認)
- ✅ **後端**: Supabase (取代 Firebase)
- ✅ **AI**: Claude 3 Haiku API
- ✅ **資料源**: 台灣政府開放資料 API + Google Places API
- ✅ **省錢策略**: 批次處理 + 快取 + 活躍用戶過濾

### 成功指標
- [ ] 成本控制在 $35/月 以內 (1000 用戶)
- [ ] AI 推薦準確率 > 70%
- [ ] 資料自動更新 (每日同步)
- [ ] App 啟動時間 < 3 秒
- [ ] 所有安全性檢查通過

---

## 🎯 Phase 總覽

| Phase | 名稱 | 工期 | 優先級 | 狀態 |
|-------|------|------|--------|------|
| **Phase A** | 安全性修復 (前置作業) | 2 天 | 🔴 必做 | ⏸️ 待開始 |
| **Phase B** | Supabase 基礎建設 | 3 天 | 🔴 必做 | ⏸️ 待開始 |
| **Phase C** | 資料源整合 | 3 天 | 🔴 必做 | ⏸️ 待開始 |
| **Phase D** | AI 推薦引擎 | 3 天 | 🔴 必做 | ⏸️ 待開始 |
| **Phase E** | 省錢優化 | 2 天 | 🟡 建議做 | ⏸️ 待開始 |
| **Phase F** | 測試與上線 | 2 天 | 🔴 必做 | ⏸️ 待開始 |

**總工期**: 12-15 天

---

## 📅 Phase A: 安全性修復 (前置作業)

> **工期**: 2 天
> **目標**: 完成 Phase 1 安全性工作，為遷移做準備

### Task A.1: 實作 KeychainManager ✅

**優先級**: 🔴 必做
**工時**: 3 小時

**檔案**: `TaiwanArtion/Core/Storage/KeychainManager.swift`

```swift
import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    // MARK: - Save
    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            AppLogger.error("無法轉換字串為 Data", category: .auth)
            return false
        }

        // 先刪除舊值
        delete(forKey: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            AppLogger.debug("成功儲存到 Keychain: \(key)", category: .auth)
            return true
        } else {
            AppLogger.error("儲存到 Keychain 失敗: \(status)", category: .auth)
            return false
        }
    }

    // MARK: - Retrieve
    func retrieve(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            AppLogger.debug("Keychain 無資料: \(key)", category: .auth)
            return nil
        }

        return value
    }

    // MARK: - Delete
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    // MARK: - Clear All
    func clearAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

// MARK: - Convenience Keys
extension KeychainManager {
    enum Key {
        static let userToken = "com.taiwanartion.userToken"
        static let refreshToken = "com.taiwanartion.refreshToken"
        static let userId = "com.taiwanartion.userId"
    }
}
```

**測試**:
```swift
// 在 AppDelegate 或 SceneDelegate 測試
KeychainManager.shared.save("test_token_123", forKey: KeychainManager.Key.userToken)
let token = KeychainManager.shared.retrieve(forKey: KeychainManager.Key.userToken)
AppLogger.debug("Token: \(token ?? "nil")", category: .auth)
```

**成功標準**:
- [ ] 可以儲存字串到 Keychain
- [ ] 可以讀取字串從 Keychain
- [ ] 可以刪除 Keychain 資料
- [ ] 重啟 App 後資料仍存在

---

### Task A.2: 遷移 Token 儲存 ✅

**優先級**: 🔴 必做
**工時**: 2 小時

**修改檔案**: `TaiwanArtion/UserFeature/UserManager.swift`

```swift
// 找到所有 UserDefaults 儲存 Token 的地方並替換

// 舊代碼 (不安全):
UserDefaults.standard.set(token, forKey: "userToken")

// 新代碼 (安全):
KeychainManager.shared.save(token, forKey: KeychainManager.Key.userToken)

// 舊代碼 (不安全):
let token = UserDefaults.standard.string(forKey: "userToken")

// 新代碼 (安全):
let token = KeychainManager.shared.retrieve(forKey: KeychainManager.Key.userToken)
```

**需要修改的位置**:
1. 登入成功後儲存 Token
2. 登出時刪除 Token
3. App 啟動時讀取 Token
4. Token 過期時更新

**成功標準**:
- [ ] 登入後 Token 儲存在 Keychain
- [ ] 重啟 App 自動登入成功
- [ ] 登出後 Keychain Token 被清除
- [ ] UserDefaults 不再有敏感資訊

---

### Task A.3: 環境變數配置 ✅

**優先級**: 🔴 必做
**工時**: 1 小時

**步驟**:

1. **創建環境變數檔案**

```bash
# 創建 .env 檔案 (不要提交到 Git)
touch .env

# 加入到 .gitignore
echo ".env" >> .gitignore
```

2. **在 Xcode 配置 Build Settings**

```
Xcode → TaiwanArtion Target → Build Settings → 搜尋 "User-Defined"
新增:
  SUPABASE_URL = $(SUPABASE_URL)
  SUPABASE_KEY = $(SUPABASE_KEY)
  CLAUDE_API_KEY = $(CLAUDE_API_KEY)
  GOOGLE_PLACES_KEY = $(GOOGLE_PLACES_KEY)
```

3. **創建 Config.swift**

**檔案**: `TaiwanArtion/Core/Config/AppConfig.swift`

```swift
import Foundation

struct AppConfig {
    // Supabase
    static let supabaseURL: String = {
        guard let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] else {
            fatalError("SUPABASE_URL not set in environment")
        }
        return url
    }()

    static let supabaseKey: String = {
        guard let key = ProcessInfo.processInfo.environment["SUPABASE_KEY"] else {
            fatalError("SUPABASE_KEY not set in environment")
        }
        return key
    }()

    // Claude API
    static let claudeAPIKey: String = {
        guard let key = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"] else {
            fatalError("CLAUDE_API_KEY not set in environment")
        }
        return key
    }()

    // Google Places
    static let googlePlacesKey: String = {
        guard let key = ProcessInfo.processInfo.environment["GOOGLE_PLACES_KEY"] else {
            fatalError("GOOGLE_PLACES_KEY not set in environment")
        }
        return key
    }()

    // 其他配置
    static let isProduction: Bool = {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }()
}
```

**成功標準**:
- [ ] .env 已加入 .gitignore
- [ ] AppConfig 可讀取環境變數
- [ ] Git 不會追蹤敏感資訊

---

## 📅 Phase B: Supabase 基礎建設

> **工期**: 3 天
> **目標**: 建立 Supabase 資料庫和 iOS SDK 整合

### Task B.1: Supabase 專案設置 ✅

**優先級**: 🔴 必做
**工時**: 4-6 小時 (包含學習時間)

> **新手專用**: 請參考 [Supabase 後端完全指南](./SUPABASE_BACKEND_GUIDE.md)
> 這份指南會手把手教你從零開始建立後端，包含：
> - 什麼是 Supabase？為什麼要用？
> - 建立帳號和專案
> - 理解資料庫概念 (給完全新手)
> - 建立資料表 (圖形介面 + SQL 兩種方法)
> - 設定安全性 (RLS)
> - 認證和儲存空間
> - 常見問題解答

**快速步驟** (已有經驗者):

1. **建立 Supabase 專案**
```
1. 前往 https://supabase.com
2. 點擊 "Start your project"
3. 創建新專案:
   - Name: taiwanartion
   - Database Password: [設定強密碼並記錄]
   - Region: Southeast Asia (Singapore) ← 最近台灣
4. 等待專案建立完成 (約 2 分鐘)
```

2. **獲取 API Keys**
```
Settings → API
  - Project URL: https://xxx.supabase.co
  - anon public key: eyJhbGci...
  - service_role key: eyJhbGci... (保密!)
```

3. **建立資料表**

**SQL 腳本**: 在 Supabase SQL Editor 執行

```sql
-- exhibitions 展覽表
CREATE TABLE exhibitions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  tags TEXT[],
  difficulty TEXT,
  estimated_duration INTEGER,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  location TEXT,
  venue_id UUID REFERENCES venues(id),
  image_url TEXT,
  price TEXT,
  website TEXT,
  source TEXT, -- 'government_api' or 'manual'
  ai_generated BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- venues 展覽館表
CREATE TABLE venues (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  address TEXT,
  city TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  phone TEXT,
  website TEXT,
  google_place_id TEXT UNIQUE,
  google_data JSONB, -- 儲存 Google Places 完整資料
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- user_recommendations 用戶推薦快取表
CREATE TABLE user_recommendations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  exhibition_ids UUID[],
  generated_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours',
  UNIQUE(user_id)
);

-- user_favorites 用戶收藏表 (從 Firebase 遷移)
CREATE TABLE user_favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  exhibition_id UUID REFERENCES exhibitions(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, exhibition_id)
);

-- 建立索引 (提升查詢效能)
CREATE INDEX idx_exhibitions_category ON exhibitions(category);
CREATE INDEX idx_exhibitions_start_date ON exhibitions(start_date);
CREATE INDEX idx_exhibitions_end_date ON exhibitions(end_date);
CREATE INDEX idx_user_recommendations_user_id ON user_recommendations(user_id);
CREATE INDEX idx_user_recommendations_expires_at ON user_recommendations(expires_at);
CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_venues_city ON venues(city);

-- 啟用 Row Level Security (安全性)
ALTER TABLE exhibitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE venues ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

-- RLS 政策: exhibitions 和 venues 所有人可讀
CREATE POLICY "Allow public read access on exhibitions"
  ON exhibitions FOR SELECT
  USING (true);

CREATE POLICY "Allow public read access on venues"
  ON venues FOR SELECT
  USING (true);

-- RLS 政策: user_recommendations 只能看自己的
CREATE POLICY "Users can view own recommendations"
  ON user_recommendations FOR SELECT
  USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own recommendations"
  ON user_recommendations FOR INSERT
  WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update own recommendations"
  ON user_recommendations FOR UPDATE
  USING (auth.uid()::text = user_id);

-- RLS 政策: user_favorites 只能看/修改自己的
CREATE POLICY "Users can view own favorites"
  ON user_favorites FOR SELECT
  USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own favorites"
  ON user_favorites FOR INSERT
  WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can delete own favorites"
  ON user_favorites FOR DELETE
  USING (auth.uid()::text = user_id);
```

**成功標準**:
- [ ] Supabase 專案建立成功
- [ ] 4 個資料表建立完成
- [ ] RLS 政策設定完成
- [ ] 可在 Supabase Dashboard 看到資料表

---

### Task B.2: iOS Supabase SDK 整合 ✅

**優先級**: 🔴 必做
**工時**: 2 小時

**步驟**:

1. **安裝 Supabase Swift SDK**

**修改 Podfile**:
```ruby
# 在 Podfile 中加入
pod 'Supabase', '~> 2.0'
```

**執行安裝**:
```bash
cd /Users/jhenmu/Developer/TaiwanArtionV1
pod install
```

2. **創建 Supabase Client**

**檔案**: `TaiwanArtion/Core/Database/SupabaseClient.swift`

```swift
import Foundation
import Supabase

class SupabaseClient {
    static let shared = SupabaseClient()

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: AppConfig.supabaseURL)!,
            supabaseKey: AppConfig.supabaseKey
        )

        AppLogger.info("Supabase Client 初始化成功", category: .database)
    }

    // 測試連線
    func testConnection() async throws {
        let response: [Exhibition] = try await client
            .from("exhibitions")
            .select()
            .limit(1)
            .execute()
            .value

        AppLogger.info("Supabase 連線測試成功，取得 \(response.count) 筆資料", category: .database)
    }
}
```

**成功標準**:
- [ ] Supabase SDK 安裝成功
- [ ] SupabaseClient 初始化成功
- [ ] 測試連線成功

---

### Task B.3: 資料模型定義 ✅

**優先級**: 🔴 必做
**工時**: 2 小時

**檔案**: `TaiwanArtion/Model/Exhibition.swift` (修改現有)

```swift
import Foundation

// MARK: - Exhibition (主要模型)
struct Exhibition: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let category: String?
    let tags: [String]?
    let difficulty: String?
    let estimatedDuration: Int?
    let startDate: Date?
    let endDate: Date?
    let location: String?
    let venueId: UUID?
    let imageUrl: String?
    let price: String?
    let website: String?
    let source: String?
    let aiGenerated: Bool?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case tags
        case difficulty
        case estimatedDuration = "estimated_duration"
        case startDate = "start_date"
        case endDate = "end_date"
        case location
        case venueId = "venue_id"
        case imageUrl = "image_url"
        case price
        case website
        case source
        case aiGenerated = "ai_generated"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Venue (展覽館)
struct Venue: Codable, Identifiable {
    let id: UUID
    let name: String
    let address: String?
    let city: String?
    let latitude: Double?
    let longitude: Double?
    let phone: String?
    let website: String?
    let googlePlaceId: String?
    let googleData: [String: Any]?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case city
        case latitude
        case longitude
        case phone
        case website
        case googlePlaceId = "google_place_id"
        case googleData = "google_data"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - UserRecommendation (推薦快取)
struct UserRecommendation: Codable, Identifiable {
    let id: UUID
    let userId: String
    let exhibitionIds: [UUID]
    let generatedAt: Date
    let expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case exhibitionIds = "exhibition_ids"
        case generatedAt = "generated_at"
        case expiresAt = "expires_at"
    }
}

// MARK: - RawExhibition (政府 API 原始資料)
struct RawExhibition: Codable {
    let title: String
    let description: String?
    let category: String?
    let startDate: String?
    let endDate: String?
    let location: String?
    let imageUrl: String?
    let price: String?
    let website: String?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case category
        case startDate = "startDate"
        case endDate = "endDate"
        case location
        case imageUrl = "imageUrl"
        case price
        case website
    }
}
```

**成功標準**:
- [ ] 所有模型符合 Supabase 資料表結構
- [ ] Codable 正常運作
- [ ] 可正確序列化/反序列化

---

## 📅 Phase C: 資料源整合

> **工期**: 3 天
> **目標**: 串接政府 API 和 Google Places API

### Task C.1: 政府開放資料 API 整合 ✅

**優先級**: 🔴 必做
**工時**: 4 小時

**檔案**: `TaiwanArtion/Core/DataSources/CultureGovDataSource.swift`

```swift
import Foundation
import RxSwift

class CultureGovDataSource {
    private let apiURL = "https://cloud.culture.tw/frontsite/trans/SearchShowAction.do?method=doFindTypeJ&category=6"

    func fetchExhibitions() -> Observable<[RawExhibition]> {
        return Observable.create { observer in
            guard let url = URL(string: self.apiURL) else {
                observer.onError(AppError.invalidInput("Invalid URL"))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    AppLogger.error("政府 API 請求失敗", category: .network, error: error)
                    observer.onError(error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    AppLogger.error("政府 API 回應錯誤", category: .network)
                    observer.onError(AppError.serverError("HTTP error"))
                    return
                }

                guard let data = data else {
                    observer.onError(AppError.dataNotFound)
                    return
                }

                do {
                    // 政府 API 可能回傳不同格式，需要解析
                    let decoder = JSONDecoder()
                    let exhibitions = try decoder.decode([RawExhibition].self, from: data)

                    AppLogger.info("成功獲取 \(exhibitions.count) 筆展覽資料", category: .network)
                    observer.onNext(exhibitions)
                    observer.onCompleted()
                } catch {
                    AppLogger.error("解析政府 API 資料失敗", category: .network, error: error)
                    observer.onError(error)
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
```

**成功標準**:
- [ ] 可成功呼叫政府 API
- [ ] 可正確解析 JSON 資料
- [ ] 錯誤處理完整
- [ ] 日誌記錄清楚

---

### Task C.2: Google Places API 整合 ✅

**優先級**: 🔴 必做
**工時**: 3 小時

**檔案**: `TaiwanArtion/Core/DataSources/GooglePlacesDataSource.swift`

```swift
import Foundation
import RxSwift

class GooglePlacesDataSource {
    private let apiKey = AppConfig.googlePlacesKey
    private let baseURL = "https://maps.googleapis.com/maps/api/place"

    // 搜尋展覽館
    func searchVenue(name: String) -> Observable<String?> {
        return Observable.create { observer in
            let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "\(self.baseURL)/findplacefromtext/json?input=\(encodedName)&inputtype=textquery&fields=place_id&key=\(self.apiKey)"

            guard let url = URL(string: urlString) else {
                observer.onError(AppError.invalidInput("Invalid URL"))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    AppLogger.error("Google Places API 錯誤", category: .network, error: error)
                    observer.onError(error)
                    return
                }

                guard let data = data else {
                    observer.onError(AppError.dataNotFound)
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let placeId = firstCandidate["place_id"] as? String {
                        observer.onNext(placeId)
                        observer.onCompleted()
                    } else {
                        observer.onNext(nil)
                        observer.onCompleted()
                    }
                } catch {
                    observer.onError(error)
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }

    // 獲取展覽館詳細資訊
    func getVenueDetails(placeId: String) -> Observable<Venue> {
        return Observable.create { observer in
            let urlString = "\(self.baseURL)/details/json?place_id=\(placeId)&fields=name,formatted_address,geometry,formatted_phone_number,website&key=\(self.apiKey)"

            guard let url = URL(string: urlString) else {
                observer.onError(AppError.invalidInput("Invalid URL"))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }

                guard let data = data else {
                    observer.onError(AppError.dataNotFound)
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let result = json["result"] as? [String: Any] {

                        let venue = Venue(
                            id: UUID(),
                            name: result["name"] as? String ?? "",
                            address: result["formatted_address"] as? String,
                            city: self.extractCity(from: result["formatted_address"] as? String),
                            latitude: (result["geometry"] as? [String: Any])?["location"]?["lat"] as? Double,
                            longitude: (result["geometry"] as? [String: Any])?["location"]?["lng"] as? Double,
                            phone: result["formatted_phone_number"] as? String,
                            website: result["website"] as? String,
                            googlePlaceId: placeId,
                            googleData: result,
                            createdAt: Date(),
                            updatedAt: Date()
                        )

                        observer.onNext(venue)
                        observer.onCompleted()
                    } else {
                        observer.onError(AppError.dataNotFound)
                    }
                } catch {
                    observer.onError(error)
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }

    private func extractCity(from address: String?) -> String? {
        // 簡單解析，提取城市名稱
        // 例: "台北市中正區..." → "台北市"
        guard let address = address else { return nil }

        let cities = ["台北市", "新北市", "桃園市", "台中市", "台南市", "高雄市",
                      "基隆市", "新竹市", "嘉義市", "宜蘭縣", "新竹縣", "苗栗縣",
                      "彰化縣", "南投縣", "雲林縣", "嘉義縣", "屏東縣", "台東縣",
                      "花蓮縣", "澎湖縣", "金門縣", "連江縣"]

        for city in cities {
            if address.contains(city) {
                return city
            }
        }

        return nil
    }
}
```

**成功標準**:
- [ ] 可搜尋展覽館並獲取 Place ID
- [ ] 可獲取展覽館詳細資訊
- [ ] 正確解析地址和座標
- [ ] API 配額控制 (每日 < 100 次)

---

### Task C.3: 資料同步服務 ✅

**優先級**: 🔴 必做
**工時**: 4 小時

**檔案**: `TaiwanArtion/Core/Services/DataSyncService.swift`

```swift
import Foundation
import RxSwift
import Supabase

class DataSyncService {
    static let shared = DataSyncService()

    private let cultureDataSource = CultureGovDataSource()
    private let googleDataSource = GooglePlacesDataSource()
    private let supabase = SupabaseClient.shared.client
    private let disposeBag = DisposeBag()

    private init() {}

    // 完整同步流程
    func syncAll() {
        AppLogger.info("開始完整資料同步", category: .database)

        // 1. 同步展覽資料
        syncExhibitions()

        // 2. 同步展覽館資料 (一次性)
        syncVenues()
    }

    // 同步展覽資料
    private func syncExhibitions() {
        cultureDataSource.fetchExhibitions()
            .subscribe(
                onNext: { [weak self] rawExhibitions in
                    AppLogger.info("獲取 \(rawExhibitions.count) 筆原始展覽資料", category: .database)

                    // 將原始資料轉為標準格式並儲存
                    self?.saveExhibitionsToSupabase(rawExhibitions)
                },
                onError: { error in
                    AppLogger.error("同步展覽失敗", category: .database, error: error)
                }
            )
            .disposed(by: disposeBag)
    }

    // 儲存展覽到 Supabase
    private func saveExhibitionsToSupabase(_ rawExhibitions: [RawExhibition]) {
        Task {
            do {
                for rawExhibition in rawExhibitions {
                    // 轉換為 Exhibition 格式
                    let exhibition = Exhibition(
                        id: UUID(),
                        title: rawExhibition.title,
                        description: rawExhibition.description,
                        category: rawExhibition.category,
                        tags: nil, // 稍後由 AI 生成
                        difficulty: nil, // 稍後由 AI 生成
                        estimatedDuration: nil, // 稍後由 AI 生成
                        startDate: parseDate(rawExhibition.startDate),
                        endDate: parseDate(rawExhibition.endDate),
                        location: rawExhibition.location,
                        venueId: nil, // 稍後關聯
                        imageUrl: rawExhibition.imageUrl,
                        price: rawExhibition.price,
                        website: rawExhibition.website,
                        source: "government_api",
                        aiGenerated: false,
                        createdAt: Date(),
                        updatedAt: Date()
                    )

                    // Upsert 到 Supabase (如果已存在則更新)
                    try await supabase
                        .from("exhibitions")
                        .upsert(exhibition)
                        .execute()
                }

                AppLogger.info("成功同步 \(rawExhibitions.count) 筆展覽到 Supabase", category: .database)
            } catch {
                AppLogger.error("儲存展覽到 Supabase 失敗", category: .database, error: error)
            }
        }
    }

    // 同步展覽館 (一次性，之後只新增)
    private func syncVenues() {
        // 從政府資料獲取所有展覽館名稱
        let venueNames = ["國立故宮博物院", "台北市立美術館", "國立台灣美術館", "高雄市立美術館"]
        // TODO: 實際應從展覽資料中提取所有唯一展覽館

        for venueName in venueNames {
            // 檢查是否已存在
            Task {
                let exists = try await checkVenueExists(venueName)
                if !exists {
                    // 使用 Google Places API 獲取詳細資訊
                    googleDataSource.searchVenue(name: venueName)
                        .flatMap { placeId -> Observable<Venue> in
                            guard let placeId = placeId else {
                                return Observable.error(AppError.dataNotFound)
                            }
                            return self.googleDataSource.getVenueDetails(placeId: placeId)
                        }
                        .subscribe(
                            onNext: { [weak self] venue in
                                self?.saveVenueToSupabase(venue)
                            },
                            onError: { error in
                                AppLogger.error("同步展覽館失敗: \(venueName)", category: .database, error: error)
                            }
                        )
                        .disposed(by: disposeBag)
                }
            }
        }
    }

    private func checkVenueExists(_ name: String) async throws -> Bool {
        let response: [Venue] = try await supabase
            .from("venues")
            .select()
            .eq("name", value: name)
            .execute()
            .value

        return !response.isEmpty
    }

    private func saveVenueToSupabase(_ venue: Venue) {
        Task {
            do {
                try await supabase
                    .from("venues")
                    .insert(venue)
                    .execute()

                AppLogger.info("成功儲存展覽館: \(venue.name)", category: .database)
            } catch {
                AppLogger.error("儲存展覽館失敗: \(venue.name)", category: .database, error: error)
            }
        }
    }

    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}
```

**成功標準**:
- [ ] 可從政府 API 獲取展覽資料
- [ ] 可儲存展覽到 Supabase
- [ ] 可從 Google Places 獲取展覽館資料
- [ ] 可儲存展覽館到 Supabase
- [ ] 避免重複資料 (upsert)

---

## 📅 Phase D: AI 推薦引擎

> **工期**: 3 天
> **目標**: 實作 Claude AI 推薦系統 (最省錢方案)

### Task D.1: Claude API 服務 ✅

**優先級**: 🔴 必做
**工時**: 4 小時

**檔案**: `TaiwanArtion/Core/AI/ClaudeAPIService.swift`

```swift
import Foundation
import RxSwift

class ClaudeAPIService {
    static let shared = ClaudeAPIService()

    private let apiKey = AppConfig.claudeAPIKey
    private let baseURL = "https://api.anthropic.com/v1/messages"

    private init() {}

    // 呼叫 Claude API
    func callAPI(prompt: String, maxTokens: Int = 1024) -> Observable<String> {
        return Observable.create { observer in
            guard let url = URL(string: self.baseURL) else {
                observer.onError(AppError.invalidInput("Invalid URL"))
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(self.apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

            let body: [String: Any] = [
                "model": "claude-3-haiku-20240307",
                "max_tokens": maxTokens,
                "messages": [
                    ["role": "user", "content": prompt]
                ]
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    AppLogger.error("Claude API 請求失敗", category: .network, error: error)
                    observer.onError(error)
                    return
                }

                guard let data = data else {
                    observer.onError(AppError.dataNotFound)
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let content = json["content"] as? [[String: Any]],
                       let text = content.first?["text"] as? String {

                        AppLogger.debug("Claude API 回應成功", category: .network)
                        observer.onNext(text)
                        observer.onCompleted()
                    } else {
                        AppLogger.error("Claude API 回應格式錯誤", category: .network)
                        observer.onError(AppError.serverError("Invalid response format"))
                    }
                } catch {
                    observer.onError(error)
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }

    // 資料標準化
    func standardizeExhibition(_ raw: RawExhibition) -> Observable<Exhibition> {
        let prompt = """
        請將以下展覽資訊標準化為 JSON 格式，只回傳 JSON，不要其他說明文字。

        格式:
        {
          "category": "分類 (當代藝術/古典藝術/攝影/雕塑/其他)",
          "tags": ["標籤1", "標籤2", "標籤3"],
          "difficulty": "適合對象 (入門/進階/專業)",
          "estimatedDuration": 建議參觀時間(分鐘，數字)
        }

        展覽資訊:
        標題: \(raw.title)
        描述: \(raw.description ?? "無")
        類別: \(raw.category ?? "無")
        """

        return callAPI(prompt: prompt)
            .map { response in
                // 解析 AI 回應
                guard let data = response.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw AppError.serverError("AI 回應解析失敗")
                }

                // 建立標準化的 Exhibition
                return Exhibition(
                    id: UUID(),
                    title: raw.title,
                    description: raw.description,
                    category: json["category"] as? String,
                    tags: json["tags"] as? [String],
                    difficulty: json["difficulty"] as? String,
                    estimatedDuration: json["estimatedDuration"] as? Int,
                    startDate: nil, // 從 raw 提取
                    endDate: nil,
                    location: raw.location,
                    venueId: nil,
                    imageUrl: raw.imageUrl,
                    price: raw.price,
                    website: raw.website,
                    source: "government_api",
                    aiGenerated: true,
                    createdAt: Date(),
                    updatedAt: Date()
                )
            }
    }

    // 生成推薦 (批次處理版本 - 最省錢)
    func generateRecommendations(
        for userId: String,
        userPreferences: [String],
        exhibitions: [Exhibition],
        limit: Int = 10
    ) -> Observable<[UUID]> {
        // 只傳遞必要資訊給 AI (減少 tokens)
        let exhibitionSummary = exhibitions.prefix(50).enumerated().map { index, ex in
            "[\(index)] \(ex.title) - \(ex.category ?? "未分類")"
        }.joined(separator: "\n")

        let prompt = """
        基於用戶喜好推薦展覽。只回傳 JSON 陣列格式的展覽編號，不要其他說明。

        用戶喜好: \(userPreferences.joined(separator: ", "))

        展覽清單:
        \(exhibitionSummary)

        請回傳最推薦的 \(limit) 個展覽編號，例如: [3, 7, 1, 9, 12]
        """

        return callAPI(prompt: prompt, maxTokens: 200) // 減少 max tokens
            .map { response in
                // 解析推薦的展覽編號
                let cleaned = response
                    .replacingOccurrences(of: "[", with: "")
                    .replacingOccurrences(of: "]", with: "")
                    .replacingOccurrences(of: " ", with: "")

                let indices = cleaned.split(separator: ",").compactMap { Int($0) }

                // 將編號轉為 UUID
                return indices.compactMap { index in
                    index < exhibitions.count ? exhibitions[index].id : nil
                }
            }
    }
}
```

**成功標準**:
- [ ] 可成功呼叫 Claude API
- [ ] 資料標準化正常運作
- [ ] 推薦生成正常運作
- [ ] Token 使用量在預期內

---

### Task D.2: 推薦快取系統 (省錢關鍵!) ✅

**優先級**: 🔴 必做
**工時**: 3 小時

**檔案**: `TaiwanArtion/Core/Services/RecommendationService.swift`

```swift
import Foundation
import RxSwift
import Supabase

class RecommendationService {
    static let shared = RecommendationService()

    private let aiService = ClaudeAPIService.shared
    private let supabase = SupabaseClient.shared.client
    private let disposeBag = DisposeBag()

    private init() {}

    // 獲取推薦 (帶快取)
    func getRecommendations(for userId: String, userPreferences: [String]) async throws -> [Exhibition] {
        // 1. 先檢查快取
        if let cached = try await getCachedRecommendations(userId: userId),
           cached.expiresAt > Date() {
            AppLogger.info("使用快取推薦 (userId: \(userId))", category: .viewModel)
            return try await fetchExhibitionsByIds(cached.exhibitionIds)
        }

        // 2. 快取過期，生成新推薦
        AppLogger.info("快取過期，生成新推薦 (userId: \(userId))", category: .viewModel)
        return try await generateAndCacheRecommendations(userId: userId, userPreferences: userPreferences)
    }

    // 獲取快取的推薦
    private func getCachedRecommendations(userId: String) async throws -> UserRecommendation? {
        let response: [UserRecommendation] = try await supabase
            .from("user_recommendations")
            .select()
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value

        return response.first
    }

    // 生成並快取推薦
    private func generateAndCacheRecommendations(userId: String, userPreferences: [String]) async throws -> [Exhibition] {
        // 1. 獲取所有展覽
        let allExhibitions: [Exhibition] = try await supabase
            .from("exhibitions")
            .select()
            .limit(100)
            .execute()
            .value

        // 2. 使用 AI 生成推薦
        let recommendedIds = try await aiService
            .generateRecommendations(
                for: userId,
                userPreferences: userPreferences,
                exhibitions: allExhibitions,
                limit: 10
            )
            .toAsync()

        // 3. 儲存快取 (24 小時)
        let recommendation = UserRecommendation(
            id: UUID(),
            userId: userId,
            exhibitionIds: recommendedIds,
            generatedAt: Date(),
            expiresAt: Date().addingTimeInterval(24 * 60 * 60) // 24 小時
        )

        try await supabase
            .from("user_recommendations")
            .upsert(recommendation)
            .execute()

        AppLogger.info("成功快取推薦 (userId: \(userId), 過期時間: \(recommendation.expiresAt))", category: .database)

        // 4. 回傳推薦的展覽
        return try await fetchExhibitionsByIds(recommendedIds)
    }

    // 根據 IDs 獲取展覽
    private func fetchExhibitionsByIds(_ ids: [UUID]) async throws -> [Exhibition] {
        let response: [Exhibition] = try await supabase
            .from("exhibitions")
            .select()
            .in("id", values: ids)
            .execute()
            .value

        return response
    }
}

// RxSwift Observable 轉 async/await 擴展
extension Observable {
    func toAsync() async throws -> Element {
        return try await withCheckedThrowingContinuation { continuation in
            var disposable: Disposable?

            disposable = self.subscribe(
                onNext: { value in
                    continuation.resume(returning: value)
                    disposable?.dispose()
                },
                onError: { error in
                    continuation.resume(throwing: error)
                    disposable?.dispose()
                }
            )
        }
    }
}
```

**成功標準**:
- [ ] 推薦結果會快取 24 小時
- [ ] 24 小時內不重複呼叫 AI
- [ ] 快取過期後自動重新生成
- [ ] 成本降低 50%

---

### Task D.3: Repository 層整合 ✅

**優先級**: 🔴 必做
**工時**: 2 小時

**檔案**: `TaiwanArtion/Repository/ExhibitionRepository.swift` (新增)

```swift
import Foundation
import RxSwift

protocol ExhibitionRepository {
    func getExhibitions(limit: Int) async throws -> [Exhibition]
    func getRecommendedExhibitions(for userId: String, preferences: [String]) async throws -> [Exhibition]
    func getFavoriteExhibitions(for userId: String) async throws -> [Exhibition]
    func addFavorite(userId: String, exhibitionId: UUID) async throws
    func removeFavorite(userId: String, exhibitionId: UUID) async throws
}

class SupabaseExhibitionRepository: ExhibitionRepository {
    private let supabase = SupabaseClient.shared.client
    private let recommendationService = RecommendationService.shared

    func getExhibitions(limit: Int = 20) async throws -> [Exhibition] {
        let response: [Exhibition] = try await supabase
            .from("exhibitions")
            .select()
            .limit(limit)
            .order("created_at", ascending: false)
            .execute()
            .value

        AppLogger.debug("獲取 \(response.count) 筆展覽", category: .database)
        return response
    }

    func getRecommendedExhibitions(for userId: String, preferences: [String]) async throws -> [Exhibition] {
        return try await recommendationService.getRecommendations(for: userId, userPreferences: preferences)
    }

    func getFavoriteExhibitions(for userId: String) async throws -> [Exhibition] {
        // 先獲取收藏的展覽 IDs
        let favorites: [UserFavorite] = try await supabase
            .from("user_favorites")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        let exhibitionIds = favorites.map { $0.exhibitionId }

        // 再獲取展覽詳情
        let exhibitions: [Exhibition] = try await supabase
            .from("exhibitions")
            .select()
            .in("id", values: exhibitionIds)
            .execute()
            .value

        return exhibitions
    }

    func addFavorite(userId: String, exhibitionId: UUID) async throws {
        let favorite = UserFavorite(
            id: UUID(),
            userId: userId,
            exhibitionId: exhibitionId,
            createdAt: Date()
        )

        try await supabase
            .from("user_favorites")
            .insert(favorite)
            .execute()

        AppLogger.info("加入收藏: \(exhibitionId)", category: .database)
    }

    func removeFavorite(userId: String, exhibitionId: UUID) async throws {
        try await supabase
            .from("user_favorites")
            .delete()
            .eq("user_id", value: userId)
            .eq("exhibition_id", value: exhibitionId)
            .execute()

        AppLogger.info("移除收藏: \(exhibitionId)", category: .database)
    }
}

// UserFavorite 模型
struct UserFavorite: Codable, Identifiable {
    let id: UUID
    let userId: String
    let exhibitionId: UUID
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case exhibitionId = "exhibition_id"
        case createdAt = "created_at"
    }
}
```

**成功標準**:
- [ ] Repository 協議定義清楚
- [ ] Supabase 實作完整
- [ ] 可獲取推薦展覽
- [ ] 可操作收藏功能

---

## 📅 Phase E: 省錢優化

> **工期**: 2 天
> **目標**: 實作所有成本優化策略

### Task E.1: 批次推薦處理 ✅

**優先級**: 🟡 建議做
**工時**: 3 小時

**策略**: 每日凌晨批次處理活躍用戶推薦，而不是即時生成

**檔案**: `TaiwanArtion/Core/Services/BatchRecommendationService.swift`

```swift
import Foundation

class BatchRecommendationService {
    static let shared = BatchRecommendationService()

    private let supabase = SupabaseClient.shared.client
    private let recommendationService = RecommendationService.shared

    private init() {}

    // 批次生成所有活躍用戶的推薦
    func generateBatchRecommendations() async {
        AppLogger.info("開始批次生成推薦", category: .database)

        do {
            // 1. 獲取最近 7 天活躍的用戶 (假設 30% 用戶)
            let activeUsers = try await getActiveUsers(days: 7)

            AppLogger.info("找到 \(activeUsers.count) 位活躍用戶", category: .database)

            // 2. 為每位用戶生成推薦
            for userId in activeUsers {
                do {
                    // 獲取用戶偏好
                    let userPreferences = try await getUserPreferences(userId: userId)

                    // 生成推薦
                    _ = try await recommendationService.getRecommendations(
                        for: userId,
                        userPreferences: userPreferences
                    )

                    AppLogger.debug("完成用戶推薦: \(userId)", category: .database)

                    // 延遲避免 API 限流
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 秒
                } catch {
                    AppLogger.error("生成用戶推薦失敗: \(userId)", category: .database, error: error)
                }
            }

            AppLogger.info("批次推薦完成", category: .database)
        } catch {
            AppLogger.error("批次推薦失敗", category: .database, error: error)
        }
    }

    // 獲取活躍用戶 (簡化版，實際應查詢登入記錄)
    private func getActiveUsers(days: Int) async throws -> [String] {
        // TODO: 實作真實的活躍用戶查詢
        // 暫時回傳所有有收藏的用戶
        let favorites: [UserFavorite] = try await supabase
            .from("user_favorites")
            .select()
            .gte("created_at", value: Date().addingTimeInterval(-Double(days * 24 * 60 * 60)))
            .execute()
            .value

        let uniqueUserIds = Set(favorites.map { $0.userId })
        return Array(uniqueUserIds)
    }

    // 獲取用戶偏好
    private func getUserPreferences(userId: String) async throws -> [String] {
        // TODO: 從用戶資料表獲取 habby
        // 暫時回傳預設值
        return ["當代藝術", "攝影"]
    }
}
```

**排程執行** (在 AppDelegate):
```swift
// AppDelegate.swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 註冊背景任務
    registerBackgroundTasks()
    return true
}

func registerBackgroundTasks() {
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "com.taiwanartion.batchRecommendation",
        using: nil
    ) { task in
        self.handleBatchRecommendation(task: task as! BGProcessingTask)
    }
}

func handleBatchRecommendation(task: BGProcessingTask) {
    Task {
        await BatchRecommendationService.shared.generateBatchRecommendations()
        task.setTaskCompleted(success: true)
    }
}

func scheduleNextBatchRecommendation() {
    let request = BGProcessingTaskRequest(identifier: "com.taiwanartion.batchRecommendation")
    request.earliestBeginDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())

    try? BGTaskScheduler.shared.submit(request)
}
```

**成功標準**:
- [ ] 可批次生成推薦
- [ ] 只為活躍用戶生成
- [ ] 成本降低 70%

---

### Task E.2: 成本監控與預算控制 ✅

**優先級**: 🔴 必做
**工時**: 2 小時

**檔案**: `TaiwanArtion/Core/Analytics/CostMonitor.swift`

```swift
import Foundation

class CostMonitor {
    static let shared = CostMonitor()

    private let userDefaults = UserDefaults.standard
    private let monthlyBudget: Double = 50.0 // $50 USD

    // 成本追蹤 keys
    private enum Key {
        static let aiRequestsThisMonth = "cost.aiRequests.month"
        static let googleAPIRequestsThisMonth = "cost.googleAPI.month"
        static let lastResetDate = "cost.lastReset"
    }

    private init() {
        resetIfNewMonth()
    }

    // 記錄 AI API 請求
    func recordAIRequest(estimatedCost: Double = 0.001) {
        let current = userDefaults.double(forKey: Key.aiRequestsThisMonth)
        userDefaults.set(current + estimatedCost, forKey: Key.aiRequestsThisMonth)

        checkBudget()
    }

    // 記錄 Google API 請求
    func recordGoogleAPIRequest(estimatedCost: Double = 0.017) {
        let current = userDefaults.double(forKey: Key.googleAPIRequestsThisMonth)
        userDefaults.set(current + estimatedCost, forKey: Key.googleAPIRequestsThisMonth)

        checkBudget()
    }

    // 檢查預算
    private func checkBudget() {
        let totalCost = getTotalCost()

        if totalCost > monthlyBudget {
            AppLogger.warning("⚠️ 預算超標! 本月成本: $\(totalCost)", category: .general)
            // TODO: 發送通知給開發者
            // TODO: 啟動降級模式
        } else if totalCost > monthlyBudget * 0.8 {
            AppLogger.warning("⚠️ 預算達 80%! 本月成本: $\(totalCost)", category: .general)
        }
    }

    // 獲取本月總成本
    func getTotalCost() -> Double {
        let aiCost = userDefaults.double(forKey: Key.aiRequestsThisMonth)
        let googleCost = userDefaults.double(forKey: Key.googleAPIRequestsThisMonth)
        let supabaseCost = 25.0 // 固定 $25

        return aiCost + googleCost + supabaseCost
    }

    // 每月重置
    private func resetIfNewMonth() {
        guard let lastReset = userDefaults.object(forKey: Key.lastResetDate) as? Date else {
            userDefaults.set(Date(), forKey: Key.lastResetDate)
            return
        }

        let calendar = Calendar.current
        if !calendar.isDate(lastReset, equalTo: Date(), toGranularity: .month) {
            // 新的月份，重置
            userDefaults.set(0, forKey: Key.aiRequestsThisMonth)
            userDefaults.set(0, forKey: Key.googleAPIRequestsThisMonth)
            userDefaults.set(Date(), forKey: Key.lastResetDate)

            AppLogger.info("成本追蹤已重置 (新月份)", category: .general)
        }
    }

    // 是否超過預算
    func isOverBudget() -> Bool {
        return getTotalCost() > monthlyBudget
    }
}
```

**在 API 呼叫時記錄**:
```swift
// ClaudeAPIService.swift - 在成功回應後加入
CostMonitor.shared.recordAIRequest(estimatedCost: 0.001)

// GooglePlacesDataSource.swift - 在成功回應後加入
CostMonitor.shared.recordGoogleAPIRequest(estimatedCost: 0.017)
```

**成功標準**:
- [ ] 可追蹤每月成本
- [ ] 超過 80% 預算時警告
- [ ] 超過預算時停止非必要請求

---

## 📅 Phase F: 測試與上線

> **工期**: 2 天
> **目標**: 完整測試並準備上線

### Task F.1: 完整功能測試 ✅

**優先級**: 🔴 必做
**工時**: 4 小時

**測試清單**:

```markdown
## 資料同步測試
- [ ] 政府 API 資料獲取正常
- [ ] Google Places API 資料獲取正常
- [ ] 資料正確儲存到 Supabase
- [ ] 避免重複資料

## AI 推薦測試
- [ ] Claude API 呼叫成功
- [ ] 推薦結果合理 (符合用戶偏好)
- [ ] 推薦結果快取 24 小時
- [ ] 快取過期後重新生成

## 成本控制測試
- [ ] AI 請求數量在預期內
- [ ] Google API 請求數量在預期內
- [ ] 預算警告正常運作
- [ ] 實際成本 < $5 (測試階段)

## 用戶體驗測試
- [ ] 首頁載入 < 3 秒
- [ ] 推薦展覽正確顯示
- [ ] 收藏功能正常
- [ ] 無明顯卡頓

## 安全性測試
- [ ] Token 儲存在 Keychain
- [ ] API Keys 不在程式碼中
- [ ] Supabase RLS 正常運作
- [ ] 無敏感資訊洩漏
```

**成功標準**:
- [ ] 所有測試項目通過
- [ ] 無 critical bugs

---

### Task F.2: 效能優化 ✅

**優先級**: 🟡 建議做
**工時**: 2 小時

**優化項目**:

1. **圖片載入優化**
```swift
// 使用 Kingfisher 快取
imageView.kf.setImage(
    with: URL(string: exhibition.imageUrl),
    options: [
        .transition(.fade(0.2)),
        .cacheOriginalImage,
        .diskCacheExpiration(.days(7))
    ]
)
```

2. **分頁載入**
```swift
// Repository 加入分頁
func getExhibitions(page: Int, limit: Int = 20) async throws -> [Exhibition] {
    let offset = page * limit

    let response: [Exhibition] = try await supabase
        .from("exhibitions")
        .select()
        .range(from: offset, to: offset + limit - 1)
        .order("created_at", ascending: false)
        .execute()
        .value

    return response
}
```

3. **預載推薦**
```swift
// App 啟動時預載推薦 (背景執行)
func preloadRecommendations() {
    Task.detached(priority: .background) {
        guard let userId = UserManager.shared.currentUser?.id else { return }
        _ = try? await RecommendationService.shared.getRecommendations(
            for: userId,
            userPreferences: UserManager.shared.currentUser?.habby ?? []
        )
    }
}
```

**成功標準**:
- [ ] 啟動時間 < 3 秒
- [ ] 捲動流暢 (60 fps)
- [ ] 記憶體使用 < 150MB

---

### Task F.3: 上線前檢查 ✅

**優先級**: 🔴 必做
**工時**: 2 小時

**檢查清單**:

```markdown
## 安全性
- [ ] 所有 API Keys 已環境變數化
- [ ] Token 儲存在 Keychain
- [ ] .gitignore 正確配置
- [ ] HTTPS 全站啟用
- [ ] 無敏感資訊洩漏

## 功能
- [ ] 用戶註冊/登入正常
- [ ] Google/Facebook 登入正常
- [ ] 展覽瀏覽正常
- [ ] AI 推薦正常
- [ ] 搜尋功能正常
- [ ] 收藏功能正常
- [ ] 地圖功能正常

## 效能
- [ ] 啟動時間 < 3 秒
- [ ] 頁面切換流暢
- [ ] 圖片載入正常
- [ ] 記憶體使用 < 150MB
- [ ] 無明顯卡頓

## 成本
- [ ] 測試階段成本 < $5
- [ ] 預算警告設定完成
- [ ] 成本監控正常

## 文檔
- [ ] README 更新
- [ ] API 文檔完整
- [ ] 部署指南完整
```

**成功標準**:
- [ ] 所有檢查項目通過

---

## 📊 整體時程規劃

### 甘特圖 (Gantt Chart)

```
Week 1:
Day 1: ████ Phase A (安全性)
Day 2: ████ Phase A 完成
Day 3: ████ Phase B (Supabase 建設)
Day 4: ████ Phase B 繼續
Day 5: ████ Phase B 完成

Week 2:
Day 6: ████ Phase C (資料源整合)
Day 7: ████ Phase C 繼續
Day 8: ████ Phase C 完成
Day 9: ████ Phase D (AI 推薦)
Day 10: ████ Phase D 繼續

Week 3:
Day 11: ████ Phase D 完成
Day 12: ████ Phase E (省錢優化)
Day 13: ████ Phase E 完成
Day 14: ████ Phase F (測試)
Day 15: ████ Phase F 完成 🎉
```

### 里程碑

| 日期 | 里程碑 | 交付物 |
|------|--------|--------|
| Day 2 | ✅ 安全性完成 | KeychainManager, 環境變數 |
| Day 5 | ✅ Supabase 就緒 | 資料表, iOS SDK |
| Day 8 | ✅ 資料源串接 | 政府 API, Google API |
| Day 11 | ✅ AI 推薦上線 | 推薦引擎, 快取系統 |
| Day 13 | ✅ 成本優化 | 批次處理, 成本監控 |
| Day 15 | 🎉 準備上線 | 完整測試, 文檔 |

---

## ✅ 驗收標準

### 功能驗收

- [ ] AI 推薦準確率 > 70%
- [ ] 推薦載入時間 < 2 秒
- [ ] 資料每日自動更新
- [ ] 所有核心功能正常

### 效能驗收

- [ ] App 啟動時間 < 3 秒
- [ ] 記憶體使用 < 150MB
- [ ] 捲動 FPS > 55
- [ ] 無記憶體洩漏

### 成本驗收

- [ ] 測試階段 (100 用戶) < $5/月
- [ ] 上線後 (1000 用戶) < $40/月
- [ ] 預算監控正常運作
- [ ] 有應急降級方案

### 安全驗收

- [ ] 通過所有安全性檢查
- [ ] 無敏感資訊洩漏
- [ ] Token 安全儲存
- [ ] API Keys 環境變數化

---

## 🎯 成功指標

### 技術指標

```
✅ 程式碼品質 > 90%
✅ 測試覆蓋率 > 60%
✅ 無 Critical Bugs
✅ 無 Security Issues
```

### 業務指標

```
✅ 用戶留存率 > 40%
✅ AI 推薦點擊率 > 30%
✅ App Crash Rate < 1%
✅ 用戶評分 > 4.0
```

---

## 📝 附錄

### 相關文檔

- [AI_DATA_SOURCING_STRATEGY.md](./AI_DATA_SOURCING_STRATEGY.md) - AI 資料架構設計
- [COST_ANALYSIS_AI_SUPABASE.md](./COST_ANALYSIS_AI_SUPABASE.md) - 成本分析
- [LAUNCH_ACTION_PLAN.md](./LAUNCH_ACTION_PLAN.md) - 上線行動計劃
- [BACKEND_MIGRATION_ANALYSIS.md](./BACKEND_MIGRATION_ANALYSIS.md) - 後端遷移分析

### 外部資源

- [Supabase 文檔](https://supabase.com/docs)
- [Claude API 文檔](https://docs.anthropic.com/)
- [政府開放資料平臺](https://data.gov.tw/)
- [Google Places API](https://developers.google.com/maps/documentation/places/web-service)

---

**建立者**: Claude Code
**最後更新**: 2025-11-28
**狀態**: Ready to Execute
**預估完成日期**: 2025-12-13
