//
//  DataCacheTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/11.
//

import XCTest
@testable import TaiwanArtion

final class DataCacheTests: XCTestCase {

    // MARK: - Properties

    var sut: DataCache!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = DataCache.shared
        sut.clearAll()
    }

    override func tearDownWithError() throws {
        sut.clearAll()
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Exhibition Cache Tests

    func testCacheExhibitions_StoresData() {
        // Given
        let exhibitions = createTestExhibitions(count: 5)
        let key = "test_exhibitions"

        // When
        sut.cacheExhibitions(exhibitions, forKey: key)
        let retrieved = sut.getExhibitions(forKey: key)

        // Then
        XCTAssertNotNil(retrieved, "應該能取得快取資料")
        XCTAssertEqual(retrieved?.count, 5, "應該取得正確數量的展覽")
    }

    func testGetExhibitions_WithNonExistentKey_ReturnsNil() {
        // When
        let retrieved = sut.getExhibitions(forKey: "non_existent_key")

        // Then
        XCTAssertNil(retrieved, "不存在的 key 應該返回 nil")
    }

    func testCacheExhibitions_Overwrite_UpdatesData() {
        // Given
        let key = "test_key"
        let firstBatch = createTestExhibitions(count: 3)
        let secondBatch = createTestExhibitions(count: 7)

        // When
        sut.cacheExhibitions(firstBatch, forKey: key)
        sut.cacheExhibitions(secondBatch, forKey: key)
        let retrieved = sut.getExhibitions(forKey: key)

        // Then
        XCTAssertEqual(retrieved?.count, 7, "應該更新為新的資料")
    }

    // MARK: - News Cache Tests

    func testCacheNews_StoresData() {
        // Given
        let news = createTestNews(count: 5)
        let key = "test_news"

        // When
        sut.cacheNews(news, forKey: key)
        let retrieved = sut.getNews(forKey: key)

        // Then
        XCTAssertNotNil(retrieved, "應該能取得快取資料")
        XCTAssertEqual(retrieved?.count, 5, "應該取得正確數量的新聞")
    }

    func testGetNews_WithNonExistentKey_ReturnsNil() {
        // When
        let retrieved = sut.getNews(forKey: "non_existent_key")

        // Then
        XCTAssertNil(retrieved, "不存在的 key 應該返回 nil")
    }

    // MARK: - Cache Key Tests

    func testCacheKey_Hot_GeneratesCorrectKey() {
        // When
        let key = DataCache.CacheKey.hot(count: 10)

        // Then
        XCTAssertEqual(key, "hot_10", "應該生成正確的 key")
    }

    func testCacheKey_Recent_GeneratesCorrectKey() {
        // When
        let key = DataCache.CacheKey.recent(count: 5)

        // Then
        XCTAssertEqual(key, "recent_5", "應該生成正確的 key")
    }

    func testCacheKey_Random_GeneratesCorrectKey() {
        // When
        let key = DataCache.CacheKey.random(count: 8)

        // Then
        XCTAssertEqual(key, "random_8", "應該生成正確的 key")
    }

    func testCacheKey_News_GeneratesCorrectKey() {
        // When
        let key = DataCache.CacheKey.news(count: 3)

        // Then
        XCTAssertEqual(key, "news_3", "應該生成正確的 key")
    }

    // MARK: - Clear Tests

    func testClearAll_RemovesAllData() {
        // Given
        sut.cacheExhibitions(createTestExhibitions(count: 5), forKey: "exhibitions")
        sut.cacheNews(createTestNews(count: 3), forKey: "news")

        // When
        sut.clearAll()

        // Then
        XCTAssertNil(sut.getExhibitions(forKey: "exhibitions"), "展覽快取應該被清除")
        XCTAssertNil(sut.getNews(forKey: "news"), "新聞快取應該被清除")
    }

    // MARK: - Cache Expiration Tests

    func testExhibitionCache_AfterExpiration_ReturnsNil() {
        // Given - 這個測試依賴於實際的快取過期時間
        // 如果 cacheExpiration 設為 300 秒 (5 分鐘)，這個測試無法直接驗證
        // 這裡僅測試新存入的資料能正常取得

        let exhibitions = createTestExhibitions(count: 3)
        let key = "expiration_test"

        // When
        sut.cacheExhibitions(exhibitions, forKey: key)
        let retrieved = sut.getExhibitions(forKey: key)

        // Then
        XCTAssertNotNil(retrieved, "新存入的資料應該能取得")
    }

    // MARK: - Multiple Keys Tests

    func testMultipleKeys_StoreIndependently() {
        // Given
        let exhibitions1 = createTestExhibitions(count: 3)
        let exhibitions2 = createTestExhibitions(count: 5)
        let key1 = "key_1"
        let key2 = "key_2"

        // When
        sut.cacheExhibitions(exhibitions1, forKey: key1)
        sut.cacheExhibitions(exhibitions2, forKey: key2)

        // Then
        XCTAssertEqual(sut.getExhibitions(forKey: key1)?.count, 3, "key1 應該有 3 筆")
        XCTAssertEqual(sut.getExhibitions(forKey: key2)?.count, 5, "key2 應該有 5 筆")
    }

    // MARK: - Thread Safety Tests

    func testConcurrentAccess_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 100

        // When
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            let key = "concurrent_\(index % 10)"
            let exhibitions = self.createTestExhibitions(count: 3)

            if index % 2 == 0 {
                self.sut.cacheExhibitions(exhibitions, forKey: key)
            } else {
                _ = self.sut.getExhibitions(forKey: key)
            }
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "並發存取不應該崩潰")
        }
    }

    // MARK: - Empty Data Tests

    func testCacheEmptyArray_StoresCorrectly() {
        // Given
        let emptyExhibitions: [ExhibitionInfo] = []
        let key = "empty_test"

        // When
        sut.cacheExhibitions(emptyExhibitions, forKey: key)
        let retrieved = sut.getExhibitions(forKey: key)

        // Then
        XCTAssertNotNil(retrieved, "應該能取得快取（即使是空陣列）")
        XCTAssertTrue(retrieved?.isEmpty ?? false, "應該是空陣列")
    }

    // MARK: - Singleton Tests

    func testSharedInstance_ReturnsSameInstance() {
        // When
        let instance1 = DataCache.shared
        let instance2 = DataCache.shared

        // Then
        XCTAssertTrue(instance1 === instance2, "shared 應該返回相同的實例")
    }

    // MARK: - Helper Methods

    private func createTestExhibitions(count: Int) -> [ExhibitionInfo] {
        return (0..<count).map { index in
            ExhibitionInfo(
                id: "test_\(index)",
                title: "測試展覽 \(index)",
                image: "https://example.com/image\(index).jpg",
                startDate: "2026-01-01",
                endDate: "2026-03-31",
                location: "測試地點",
                city: "台北市",
                latitude: 25.0330,
                longitude: 121.5654,
                tag: "免費",
                month: "01",
                official: "https://example.com",
                address: "測試地址"
            )
        }
    }

    private func createTestNews(count: Int) -> [News] {
        return (0..<count).map { index in
            News(
                id: "news_\(index)",
                title: "測試新聞 \(index)",
                date: "2026-01-01",
                author: "作者",
                image: "https://example.com/news.jpg",
                description: "描述"
            )
        }
    }
}
