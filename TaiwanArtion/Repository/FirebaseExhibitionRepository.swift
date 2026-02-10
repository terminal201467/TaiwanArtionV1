//
//  FirebaseExhibitionRepository.swift
//  TaiwanArtion
//
//  Created by Refactor on 2026/2/4.
//

import Foundation
import FirebaseFirestore

class FirebaseExhibitionRepository: ExhibitionRepository {

    private let database: FirebaseDatabase
    private let cache = DataCache.shared

    init(database: FirebaseDatabase = FirebaseDatabase(collectionName: "exhibitions")) {
        self.database = database
    }

    func getRandomExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        let cacheKey = DataCache.CacheKey.random(count: count)

        // 先檢查快取
        if let cached = cache.getExhibitions(forKey: cacheKey) {
            completion(.success(cached))
            return
        }

        database.getRandomDocuments(count: count) { [weak self] data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let exhibitions = data.compactMap { ExhibitionInfo.from($0) }
                // 存入快取
                self?.cache.cacheExhibitions(exhibitions, forKey: cacheKey)
                completion(.success(exhibitions))
            } else {
                completion(.success([]))
            }
        }
    }

    func getHotExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        let cacheKey = DataCache.CacheKey.hot(count: count)

        // 先檢查快取
        if let cached = cache.getExhibitions(forKey: cacheKey) {
            completion(.success(cached))
            return
        }

        database.getHotDocument(count: count) { [weak self] data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let exhibitions = data.compactMap { ExhibitionInfo.from($0) }
                // 存入快取
                self?.cache.cacheExhibitions(exhibitions, forKey: cacheKey)
                completion(.success(exhibitions))
            } else {
                completion(.success([]))
            }
        }
    }

    func getRecentExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        let cacheKey = DataCache.CacheKey.recent(count: count)

        // 先檢查快取
        if let cached = cache.getExhibitions(forKey: cacheKey) {
            completion(.success(cached))
            return
        }

        database.getRecentDocuments(count: count) { [weak self] data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let exhibitions = data.compactMap { ExhibitionInfo.from($0) }
                // 存入快取
                self?.cache.cacheExhibitions(exhibitions, forKey: cacheKey)
                completion(.success(exhibitions))
            } else {
                completion(.success([]))
            }
        }
    }

    func getExhibitions(month: String?, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        database.readDocument(month: month) { data, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let exhibitions = data.compactMap { ExhibitionInfo.from($0) }
                completion(.success(exhibitions))
            }
        }
    }

    // MARK: - Search

    func searchExhibitions(keyword: String, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        let cacheKey = "search_\(keyword)"

        // 先檢查快取
        if let cached = cache.getExhibitions(forKey: cacheKey) {
            completion(.success(cached))
            return
        }

        // 由於 Firestore 不支援全文搜尋，這裡使用本地過濾
        // 實際應用中建議使用 Algolia 或 Elasticsearch
        database.readDocument(month: nil) { [weak self] data, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let allExhibitions = data.compactMap { ExhibitionInfo.from($0) }
                let lowercasedKeyword = keyword.lowercased()

                // 搜尋標題、標籤、地點
                let filtered = allExhibitions.filter { exhibition in
                    exhibition.title.lowercased().contains(lowercasedKeyword) ||
                    exhibition.tag.lowercased().contains(lowercasedKeyword) ||
                    exhibition.location.lowercased().contains(lowercasedKeyword) ||
                    exhibition.city.lowercased().contains(lowercasedKeyword)
                }

                // 存入快取
                self?.cache.cacheExhibitions(filtered, forKey: cacheKey)
                completion(.success(filtered))
            }
        }
    }

    // MARK: - Pagination

    func getExhibitionsPaginated(
        pageSize: Int,
        lastDocument: Any?,
        completion: @escaping (Result<PaginatedExhibitionResult, Error>) -> Void
    ) {
        // 將 Any? 轉換為 DocumentSnapshot?
        let lastDocSnapshot = lastDocument as? DocumentSnapshot

        database.getPaginatedDocuments(
            pageSize: pageSize,
            lastDocument: lastDocSnapshot,
            orderBy: "startDate",
            descending: true
        ) { data, newLastDocument, error in
            if let error = error {
                AppLogger.error("分頁載入失敗", category: .database, error: error)
                completion(.failure(error))
            } else if let data = data {
                let exhibitions = data.compactMap { ExhibitionInfo.from($0) }
                let hasMore = exhibitions.count == pageSize
                let result = PaginatedExhibitionResult(
                    exhibitions: exhibitions,
                    lastDocument: newLastDocument,
                    hasMore: hasMore
                )
                AppLogger.debug("分頁載入成功: \(exhibitions.count) 筆, hasMore: \(hasMore)", category: .database)
                completion(.success(result))
            } else {
                let result = PaginatedExhibitionResult(
                    exhibitions: [],
                    lastDocument: nil,
                    hasMore: false
                )
                completion(.success(result))
            }
        }
    }
}
