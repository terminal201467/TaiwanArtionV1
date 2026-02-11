//
//  MockExhibitionRepository.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/11.
//

import Foundation
@testable import TaiwanArtion

/// Mock ExhibitionRepository 用於單元測試
final class MockExhibitionRepository: ExhibitionRepository {

    // MARK: - Test Configuration

    /// 模擬的展覽資料
    var mockExhibitions: [ExhibitionInfo] = []

    /// 模擬的錯誤
    var mockError: Error?

    /// 是否應該延遲回應
    var shouldDelayResponse = false
    var delayDuration: TimeInterval = 0.1

    /// 記錄方法呼叫次數
    private(set) var getRandomExhibitionsCallCount = 0
    private(set) var getHotExhibitionsCallCount = 0
    private(set) var getRecentExhibitionsCallCount = 0
    private(set) var getExhibitionsCallCount = 0
    private(set) var searchExhibitionsCallCount = 0
    private(set) var getPaginatedCallCount = 0

    /// 記錄傳入的參數
    private(set) var lastSearchKeyword: String?
    private(set) var lastMonthParameter: String?
    private(set) var lastPageSize: Int?

    // MARK: - Mock Pagination State

    private var paginationIndex = 0

    // MARK: - ExhibitionRepository Implementation

    func getRandomExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        getRandomExhibitionsCallCount += 1
        executeWithDelay {
            if let error = self.mockError {
                completion(.failure(error))
            } else {
                let exhibitions = Array(self.mockExhibitions.prefix(count))
                completion(.success(exhibitions))
            }
        }
    }

    func getHotExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        getHotExhibitionsCallCount += 1
        executeWithDelay {
            if let error = self.mockError {
                completion(.failure(error))
            } else {
                let exhibitions = Array(self.mockExhibitions.prefix(count))
                completion(.success(exhibitions))
            }
        }
    }

    func getRecentExhibitions(count: Int, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        getRecentExhibitionsCallCount += 1
        executeWithDelay {
            if let error = self.mockError {
                completion(.failure(error))
            } else {
                let exhibitions = Array(self.mockExhibitions.prefix(count))
                completion(.success(exhibitions))
            }
        }
    }

    func getExhibitions(month: String?, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        getExhibitionsCallCount += 1
        lastMonthParameter = month
        executeWithDelay {
            if let error = self.mockError {
                completion(.failure(error))
            } else if let month = month {
                // 模擬按月份篩選
                let filtered = self.mockExhibitions.filter { $0.month == month }
                completion(.success(filtered))
            } else {
                completion(.success(self.mockExhibitions))
            }
        }
    }

    func searchExhibitions(keyword: String, completion: @escaping (Result<[ExhibitionInfo], Error>) -> Void) {
        searchExhibitionsCallCount += 1
        lastSearchKeyword = keyword
        executeWithDelay {
            if let error = self.mockError {
                completion(.failure(error))
            } else {
                let lowercased = keyword.lowercased()
                let filtered = self.mockExhibitions.filter {
                    $0.title.lowercased().contains(lowercased) ||
                    $0.location.lowercased().contains(lowercased) ||
                    $0.tag.lowercased().contains(lowercased)
                }
                completion(.success(filtered))
            }
        }
    }

    func getExhibitionsPaginated(
        pageSize: Int,
        lastDocument: Any?,
        completion: @escaping (Result<PaginatedExhibitionResult, Error>) -> Void
    ) {
        getPaginatedCallCount += 1
        lastPageSize = pageSize

        executeWithDelay {
            if let error = self.mockError {
                completion(.failure(error))
            } else {
                // 模擬分頁邏輯
                let startIndex = lastDocument == nil ? 0 : self.paginationIndex
                let endIndex = min(startIndex + pageSize, self.mockExhibitions.count)
                let pageExhibitions = Array(self.mockExhibitions[startIndex..<endIndex])
                self.paginationIndex = endIndex

                let hasMore = endIndex < self.mockExhibitions.count
                let result = PaginatedExhibitionResult(
                    exhibitions: pageExhibitions,
                    lastDocument: hasMore ? endIndex as Any : nil,
                    hasMore: hasMore
                )
                completion(.success(result))
            }
        }
    }

    // MARK: - Helper Methods

    private func executeWithDelay(_ block: @escaping () -> Void) {
        if shouldDelayResponse {
            DispatchQueue.main.asyncAfter(deadline: .now() + delayDuration) {
                block()
            }
        } else {
            block()
        }
    }

    /// 重置所有狀態
    func reset() {
        mockExhibitions = []
        mockError = nil
        shouldDelayResponse = false
        getRandomExhibitionsCallCount = 0
        getHotExhibitionsCallCount = 0
        getRecentExhibitionsCallCount = 0
        getExhibitionsCallCount = 0
        searchExhibitionsCallCount = 0
        getPaginatedCallCount = 0
        lastSearchKeyword = nil
        lastMonthParameter = nil
        lastPageSize = nil
        paginationIndex = 0
    }
}

// MARK: - Test Data Factory

extension MockExhibitionRepository {

    /// 建立測試用的展覽資料
    static func createTestExhibitions(count: Int) -> [ExhibitionInfo] {
        return (0..<count).map { index in
            ExhibitionInfo(
                id: "test_\(index)",
                title: "測試展覽 \(index)",
                image: "https://example.com/image\(index).jpg",
                startDate: "2026-01-01",
                endDate: "2026-03-31",
                location: "測試地點 \(index)",
                city: "台北市",
                latitude: 25.0330,
                longitude: 121.5654,
                tag: index % 2 == 0 ? "免費" : "售票",
                month: String(format: "%02d", (index % 12) + 1),
                official: "https://example.com",
                address: "測試地址 \(index)"
            )
        }
    }
}
