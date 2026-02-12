//
//  NewsRepositoryTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/13.
//

import XCTest
@testable import TaiwanArtion

final class NewsRepositoryTests: XCTestCase {

    // MARK: - Properties

    var sut: MockNewsRepository!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MockNewsRepository()
    }

    override func tearDownWithError() throws {
        sut.reset()
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - getRandomNews Tests

    func testGetRandomNews_WithValidData_ReturnsNews() {
        // Given
        let expectedCount = 5
        sut.mockNews = MockNewsRepository.createTestNews(count: 10)

        // When
        let expectation = self.expectation(description: "Get random news")
        var result: Result<[News], Error>?

        sut.getRandomNews(count: expectedCount) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(sut.getRandomNewsCallCount, 1, "應該呼叫一次")

        if case .success(let news) = result {
            XCTAssertEqual(news.count, expectedCount, "應該返回指定數量的新聞")
        } else {
            XCTFail("應該成功返回新聞資料")
        }
    }

    func testGetRandomNews_WithError_ReturnsError() {
        // Given
        let expectedError = NSError(domain: "test", code: 500, userInfo: nil)
        sut.mockError = expectedError

        // When
        let expectation = self.expectation(description: "Get random news with error")
        var result: Result<[News], Error>?

        sut.getRandomNews(count: 5) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .failure(let error) = result {
            XCTAssertEqual((error as NSError).code, 500, "應該返回正確的錯誤")
        } else {
            XCTFail("應該返回錯誤")
        }
    }

    func testGetRandomNews_WithEmptyData_ReturnsEmptyArray() {
        // Given
        sut.mockNews = []

        // When
        let expectation = self.expectation(description: "Get random news empty")
        var result: Result<[News], Error>?

        sut.getRandomNews(count: 5) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .success(let news) = result {
            XCTAssertTrue(news.isEmpty, "應該返回空陣列")
        } else {
            XCTFail("應該成功返回空陣列")
        }
    }

    func testGetRandomNews_WithLessDataThanRequested_ReturnsAvailableData() {
        // Given
        sut.mockNews = MockNewsRepository.createTestNews(count: 3)

        // When
        let expectation = self.expectation(description: "Get random news less data")
        var result: Result<[News], Error>?

        sut.getRandomNews(count: 10) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .success(let news) = result {
            XCTAssertEqual(news.count, 3, "應該返回可用的資料數量")
        } else {
            XCTFail("應該成功返回新聞資料")
        }
    }

    // MARK: - getNews(byID:) Tests

    func testGetNewsByID_WithExistingID_ReturnsNews() {
        // Given
        let targetID = "news_5"
        sut.mockNews = MockNewsRepository.createTestNews(count: 10)

        // When
        let expectation = self.expectation(description: "Get news by ID")
        var result: Result<News?, Error>?

        sut.getNews(byID: targetID) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(sut.getNewsByIDCallCount, 1, "應該呼叫一次")
        XCTAssertEqual(sut.lastRequestedID, targetID, "應該記錄請求的 ID")

        if case .success(let news) = result {
            XCTAssertNotNil(news, "應該找到新聞")
            XCTAssertEqual(news?.id, targetID, "應該返回正確的新聞")
        } else {
            XCTFail("應該成功返回新聞")
        }
    }

    func testGetNewsByID_WithNonExistingID_ReturnsNil() {
        // Given
        let targetID = "non_existing_id"
        sut.mockNews = MockNewsRepository.createTestNews(count: 5)

        // When
        let expectation = self.expectation(description: "Get news by non-existing ID")
        var result: Result<News?, Error>?

        sut.getNews(byID: targetID) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .success(let news) = result {
            XCTAssertNil(news, "不存在的 ID 應該返回 nil")
        } else {
            XCTFail("應該成功返回 nil")
        }
    }

    func testGetNewsByID_WithError_ReturnsError() {
        // Given
        let expectedError = NSError(domain: "test", code: 404, userInfo: nil)
        sut.mockError = expectedError

        // When
        let expectation = self.expectation(description: "Get news by ID with error")
        var result: Result<News?, Error>?

        sut.getNews(byID: "any_id") { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .failure(let error) = result {
            XCTAssertEqual((error as NSError).code, 404, "應該返回正確的錯誤")
        } else {
            XCTFail("應該返回錯誤")
        }
    }

    // MARK: - getNews(byIDs:) Tests

    func testGetNewsByIDs_WithExistingIDs_ReturnsMatchingNews() {
        // Given
        let targetIDs = ["news_1", "news_3", "news_5"]
        sut.mockNews = MockNewsRepository.createTestNews(count: 10)

        // When
        let expectation = self.expectation(description: "Get news by IDs")
        var result: Result<[News], Error>?

        sut.getNews(byIDs: targetIDs) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(sut.getNewsByIDsCallCount, 1, "應該呼叫一次")
        XCTAssertEqual(sut.lastRequestedIDs, targetIDs, "應該記錄請求的 IDs")

        if case .success(let news) = result {
            XCTAssertEqual(news.count, targetIDs.count, "應該返回匹配的新聞數量")
            let returnedIDs = Set(news.map { $0.id })
            XCTAssertEqual(returnedIDs, Set(targetIDs), "應該返回正確的新聞")
        } else {
            XCTFail("應該成功返回新聞")
        }
    }

    func testGetNewsByIDs_WithPartialMatch_ReturnsOnlyMatching() {
        // Given
        let targetIDs = ["news_1", "non_existing", "news_3"]
        sut.mockNews = MockNewsRepository.createTestNews(count: 5)

        // When
        let expectation = self.expectation(description: "Get news by IDs partial")
        var result: Result<[News], Error>?

        sut.getNews(byIDs: targetIDs) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .success(let news) = result {
            XCTAssertEqual(news.count, 2, "應該只返回存在的新聞")
        } else {
            XCTFail("應該成功返回新聞")
        }
    }

    func testGetNewsByIDs_WithEmptyArray_ReturnsEmptyArray() {
        // Given
        let targetIDs: [String] = []
        sut.mockNews = MockNewsRepository.createTestNews(count: 5)

        // When
        let expectation = self.expectation(description: "Get news by empty IDs")
        var result: Result<[News], Error>?

        sut.getNews(byIDs: targetIDs) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .success(let news) = result {
            XCTAssertTrue(news.isEmpty, "空 IDs 應該返回空陣列")
        } else {
            XCTFail("應該成功返回空陣列")
        }
    }

    func testGetNewsByIDs_WithError_ReturnsError() {
        // Given
        let expectedError = NSError(domain: "test", code: 500, userInfo: nil)
        sut.mockError = expectedError

        // When
        let expectation = self.expectation(description: "Get news by IDs with error")
        var result: Result<[News], Error>?

        sut.getNews(byIDs: ["news_1"]) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .failure(let error) = result {
            XCTAssertEqual((error as NSError).code, 500, "應該返回正確的錯誤")
        } else {
            XCTFail("應該返回錯誤")
        }
    }

    // MARK: - Call Count Tests

    func testMultipleCalls_TracksCallCount() {
        // Given
        sut.mockNews = MockNewsRepository.createTestNews(count: 10)

        let expectation1 = expectation(description: "Call 1")
        let expectation2 = expectation(description: "Call 2")
        let expectation3 = expectation(description: "Call 3")

        // When
        sut.getRandomNews(count: 5) { _ in expectation1.fulfill() }
        sut.getNews(byID: "news_1") { _ in expectation2.fulfill() }
        sut.getNews(byIDs: ["news_1", "news_2"]) { _ in expectation3.fulfill() }

        waitForExpectations(timeout: 1.0)

        // Then
        XCTAssertEqual(sut.getRandomNewsCallCount, 1)
        XCTAssertEqual(sut.getNewsByIDCallCount, 1)
        XCTAssertEqual(sut.getNewsByIDsCallCount, 1)
    }

    // MARK: - Reset Tests

    func testReset_ClearsAllState() {
        // Given
        sut.mockNews = MockNewsRepository.createTestNews(count: 10)

        let expectation = expectation(description: "Call before reset")
        sut.getRandomNews(count: 5) { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1.0)

        // When
        sut.reset()

        // Then
        XCTAssertTrue(sut.mockNews.isEmpty, "新聞資料應該被清除")
        XCTAssertNil(sut.mockError, "錯誤應該被清除")
        XCTAssertEqual(sut.getRandomNewsCallCount, 0, "呼叫次數應該被重置")
        XCTAssertNil(sut.lastRequestedID, "lastRequestedID 應該被重置")
        XCTAssertNil(sut.lastRequestedIDs, "lastRequestedIDs 應該被重置")
    }

    // MARK: - News Data Validation Tests

    func testCreateTestNews_GeneratesValidData() {
        // When
        let news = MockNewsRepository.createTestNews(count: 5)

        // Then
        XCTAssertEqual(news.count, 5, "應該生成指定數量的新聞")

        for (index, item) in news.enumerated() {
            XCTAssertEqual(item.id, "news_\(index)", "ID 應該正確")
            XCTAssertFalse(item.title.isEmpty, "標題不應該為空")
            XCTAssertFalse(item.date.isEmpty, "日期不應該為空")
            XCTAssertFalse(item.author.isEmpty, "作者不應該為空")
        }
    }
}
