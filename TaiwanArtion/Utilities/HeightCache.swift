//
//  HeightCache.swift
//  TaiwanArtion
//
//  Created by Claude on 2026/2/11.
//

import UIKit

/// 行高緩存，減少 TableView/CollectionView 重複計算 Auto Layout
final class HeightCache {

    // MARK: - Singleton

    static let shared = HeightCache()

    // MARK: - Properties

    private var cache: [String: CGFloat] = [:]
    private let lock = NSLock()

    // MARK: - Init

    private init() {
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

    // MARK: - Public Methods

    /// 取得快取的高度
    /// - Parameter key: 快取鍵值（建議使用 "section-row" 或 identifier）
    /// - Returns: 快取的高度，若不存在則回傳 nil
    func height(for key: String) -> CGFloat? {
        lock.lock()
        defer { lock.unlock() }
        return cache[key]
    }

    /// 設定快取高度
    /// - Parameters:
    ///   - height: 計算後的高度
    ///   - key: 快取鍵值
    func setHeight(_ height: CGFloat, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache[key] = height
    }

    /// 取得或計算高度
    /// - Parameters:
    ///   - key: 快取鍵值
    ///   - calculator: 計算高度的閉包（僅在快取未命中時執行）
    /// - Returns: 快取或計算的高度
    func height(for key: String, calculator: () -> CGFloat) -> CGFloat {
        if let cached = height(for: key) {
            return cached
        }
        let calculated = calculator()
        setHeight(calculated, for: key)
        return calculated
    }

    /// 移除特定鍵值的快取
    func removeHeight(for key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache.removeValue(forKey: key)
    }

    /// 清除所有快取
    func clear() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
        AppLogger.debug("已清除高度快取", category: .ui)
    }

    /// 清除特定前綴的快取
    /// - Parameter prefix: 鍵值前綴
    func clear(prefix: String) {
        lock.lock()
        defer { lock.unlock() }
        cache = cache.filter { !$0.key.hasPrefix(prefix) }
    }

    // MARK: - Memory Warning

    @objc private func handleMemoryWarning() {
        clear()
        AppLogger.warning("收到記憶體警告，已清除高度快取", category: .ui)
    }
}

// MARK: - Convenience Key Generators

extension HeightCache {

    /// 產生 IndexPath 的快取鍵值
    static func key(for indexPath: IndexPath, prefix: String = "") -> String {
        let base = "\(indexPath.section)-\(indexPath.row)"
        return prefix.isEmpty ? base : "\(prefix)-\(base)"
    }

    /// 產生識別符的快取鍵值
    static func key(for identifier: String, section: Int) -> String {
        return "\(identifier)-\(section)"
    }
}
