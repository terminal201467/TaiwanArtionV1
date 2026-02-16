//
//  DataCache.swift
//  TaiwanArtion
//
//  Created on 2026/2/6.
//

import Foundation
import UIKit

/// API 回應快取層，使用 NSCache 實現記憶體快取
final class DataCache {

    // MARK: - Singleton

    static let shared = DataCache()

    // MARK: - Properties

    private let exhibitionCache = NSCache<NSString, CacheEntry<[ExhibitionInfo]>>()
    private let newsCache = NSCache<NSString, CacheEntry<[News]>>()

    /// 快取過期時間（秒）
    private let cacheExpiration: TimeInterval = 300 // 5 分鐘

    // MARK: - Init

    private init() {
        // 設定快取限制
        exhibitionCache.countLimit = 50  // 最多 50 個 key
        newsCache.countLimit = 20        // 最多 20 個 key

        // 監聽記憶體警告
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Exhibition Cache

    /// 快取展覽資料
    /// - Parameters:
    ///   - exhibitions: 展覽資料陣列
    ///   - key: 快取鍵值
    func cacheExhibitions(_ exhibitions: [ExhibitionInfo], forKey key: String) {
        let entry = CacheEntry(value: exhibitions)
        exhibitionCache.setObject(entry, forKey: key as NSString)
        AppLogger.debug("快取展覽資料: \(key), 數量: \(exhibitions.count)", category: .database)
    }

    /// 取得快取的展覽資料
    /// - Parameter key: 快取鍵值
    /// - Returns: 未過期的展覽資料，若過期或不存在則回傳 nil
    func getExhibitions(forKey key: String) -> [ExhibitionInfo]? {
        guard let entry = exhibitionCache.object(forKey: key as NSString) else {
            return nil
        }

        // 檢查是否過期
        if entry.isExpired(expiration: cacheExpiration) {
            exhibitionCache.removeObject(forKey: key as NSString)
            AppLogger.debug("快取已過期: \(key)", category: .database)
            return nil
        }

        AppLogger.debug("快取命中: \(key), 數量: \(entry.value.count)", category: .database)
        return entry.value
    }

    // MARK: - News Cache

    /// 快取新聞資料
    /// - Parameters:
    ///   - news: 新聞資料陣列
    ///   - key: 快取鍵值
    func cacheNews(_ news: [News], forKey key: String) {
        let entry = CacheEntry(value: news)
        newsCache.setObject(entry, forKey: key as NSString)
        AppLogger.debug("快取新聞資料: \(key), 數量: \(news.count)", category: .database)
    }

    /// 取得快取的新聞資料
    /// - Parameter key: 快取鍵值
    /// - Returns: 未過期的新聞資料，若過期或不存在則回傳 nil
    func getNews(forKey key: String) -> [News]? {
        guard let entry = newsCache.object(forKey: key as NSString) else {
            return nil
        }

        // 檢查是否過期
        if entry.isExpired(expiration: cacheExpiration) {
            newsCache.removeObject(forKey: key as NSString)
            AppLogger.debug("新聞快取已過期: \(key)", category: .database)
            return nil
        }

        AppLogger.debug("新聞快取命中: \(key), 數量: \(entry.value.count)", category: .database)
        return entry.value
    }

    // MARK: - Cache Management

    /// 清除所有快取
    func clearAll() {
        exhibitionCache.removeAllObjects()
        newsCache.removeAllObjects()
        AppLogger.info("已清除所有 API 快取", category: .database)
    }

    /// 清除展覽快取
    func clearExhibitions() {
        exhibitionCache.removeAllObjects()
    }

    /// 清除新聞快取
    func clearNews() {
        newsCache.removeAllObjects()
    }

    /// 移除特定鍵值的展覽快取
    func removeExhibition(forKey key: String) {
        exhibitionCache.removeObject(forKey: key as NSString)
    }

    /// 移除特定鍵值的新聞快取
    func removeNews(forKey key: String) {
        newsCache.removeObject(forKey: key as NSString)
    }

    // MARK: - Memory Warning

    @objc private func handleMemoryWarning() {
        clearAll()
        AppLogger.warning("收到記憶體警告，已清除 API 快取", category: .database)
    }
}

// MARK: - Cache Entry

/// 快取條目包裝器，記錄值和時間戳
private final class CacheEntry<T>: NSObject {
    let value: T
    let timestamp: Date

    init(value: T) {
        self.value = value
        self.timestamp = Date()
    }

    /// 檢查快取是否已過期
    func isExpired(expiration: TimeInterval) -> Bool {
        return Date().timeIntervalSince(timestamp) > expiration
    }
}

// MARK: - Cache Keys

extension DataCache {

    /// 預定義的快取鍵值
    enum CacheKey {
        static func hot(count: Int) -> String { "hot_\(count)" }
        static func recent(count: Int) -> String { "recent_\(count)" }
        static func random(count: Int) -> String { "random_\(count)" }
        static func month(_ month: Int, count: Int) -> String { "month_\(month)_\(count)" }
        static func allExhibitions(page: Int) -> String { "all_page_\(page)" }
        static func news(count: Int) -> String { "news_\(count)" }
    }
}
