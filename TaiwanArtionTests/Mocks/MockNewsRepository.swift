//
//  MockNewsRepository.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/11.
//

import Foundation
@testable import TaiwanArtion

/// Mock NewsRepository 用於單元測試
final class MockNewsRepository: NewsRepository {

    // MARK: - Test Configuration

    /// 模擬的新聞資料
    var mockNews: [News] = []

    /// 模擬的錯誤
    var mockError: Error?

    /// 記錄方法呼叫次數
    private(set) var getRandomNewsCallCount = 0
    private(set) var getNewsByIDCallCount = 0
    private(set) var getNewsByIDsCallCount = 0

    /// 記錄傳入的參數
    private(set) var lastRequestedID: String?
    private(set) var lastRequestedIDs: [String]?

    // MARK: - NewsRepository Implementation

    func getRandomNews(count: Int, completion: @escaping (Result<[News], Error>) -> Void) {
        getRandomNewsCallCount += 1

        if let error = mockError {
            completion(.failure(error))
        } else {
            let news = Array(mockNews.prefix(count))
            completion(.success(news))
        }
    }

    func getNews(byID id: String, completion: @escaping (Result<News?, Error>) -> Void) {
        getNewsByIDCallCount += 1
        lastRequestedID = id

        if let error = mockError {
            completion(.failure(error))
        } else {
            let news = mockNews.first { $0.id == id }
            completion(.success(news))
        }
    }

    func getNews(byIDs ids: [String], completion: @escaping (Result<[News], Error>) -> Void) {
        getNewsByIDsCallCount += 1
        lastRequestedIDs = ids

        if let error = mockError {
            completion(.failure(error))
        } else {
            let news = mockNews.filter { ids.contains($0.id) }
            completion(.success(news))
        }
    }

    // MARK: - Helper Methods

    /// 重置所有狀態
    func reset() {
        mockNews = []
        mockError = nil
        getRandomNewsCallCount = 0
        getNewsByIDCallCount = 0
        getNewsByIDsCallCount = 0
        lastRequestedID = nil
        lastRequestedIDs = nil
    }
}

// MARK: - Test Data Factory

extension MockNewsRepository {

    /// 建立測試用的新聞資料
    static func createTestNews(count: Int) -> [News] {
        return (0..<count).map { index in
            News(
                id: "news_\(index)",
                title: "測試新聞 \(index)",
                date: "2026-01-\(String(format: "%02d", (index % 28) + 1))",
                author: "作者 \(index)",
                image: "https://example.com/news\(index).jpg",
                description: "這是測試新聞 \(index) 的描述內容"
            )
        }
    }
}
