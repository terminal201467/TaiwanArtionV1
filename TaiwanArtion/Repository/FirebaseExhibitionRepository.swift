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
