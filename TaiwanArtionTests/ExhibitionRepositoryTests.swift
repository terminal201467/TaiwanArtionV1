//
//  ExhibitionRepositoryTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/11.
//

import XCTest
@testable import TaiwanArtion

final class ExhibitionRepositoryTests: XCTestCase {

    // MARK: - Properties

    var sut: MockExhibitionRepository!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MockExhibitionRepository()
    }

    override func tearDownWithError() throws {
        sut.reset()
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - getRandomExhibitions Tests

    func testGetRandomExhibitions_WithValidData_ReturnsExhibitions() {
        // Given
        let expectedCount = 5
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 10)

        // When
        let expectation = self.expectation(description: "Get random exhibitions")
        var result: Result<[ExhibitionInfo], Error>?

        sut.getRandomExhibitions(count: expectedCount) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(sut.getRandomExhibitionsCallCount, 1, "應該呼叫一次")

        if case .success(let exhibitions) = result {
            XCTAssertEqual(exhibitions.count, expectedCount, "應該返回指定數量的展覽")
        } else {
            XCTFail("應該成功返回展覽資料")
        }
    }

    func testGetRandomExhibitions_WithError_ReturnsError() {
        // Given
        let expectedError = NSError(domain: "test", code: 500, userInfo: nil)
        sut.mockError = expectedError

        // When
        let expectation = self.expectation(description: "Get random exhibitions with error")
        var result: Result<[ExhibitionInfo], Error>?

        sut.getRandomExhibitions(count: 5) { res in
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

    func testGetRandomExhibitions_WithEmptyData_ReturnsEmptyArray() {
        // Given
        sut.mockExhibitions = []

        // When
        let expectation = self.expectation(description: "Get random exhibitions empty")
        var result: Result<[ExhibitionInfo], Error>?

        sut.getRandomExhibitions(count: 5) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .success(let exhibitions) = result {
            XCTAssertTrue(exhibitions.isEmpty, "應該返回空陣列")
        } else {
            XCTFail("應該成功返回空陣列")
        }
    }

    // MARK: - getHotExhibitions Tests

    func testGetHotExhibitions_WithValidData_ReturnsExhibitions() {
        // Given
        let expectedCount = 8
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 10)

        // When
        let expectation = self.expectation(description: "Get hot exhibitions")
        var result: Result<[ExhibitionInfo], Error>?

        sut.getHotExhibitions(count: expectedCount) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(sut.getHotExhibitionsCallCount, 1, "應該呼叫一次")

        if case .success(let exhibitions) = result {
            XCTAssertEqual(exhibitions.count, expectedCount, "應該返回指定數量的展覽")
        } else {
            XCTFail("應該成功返回展覽資料")
        }
    }

    // MARK: - getRecentExhibitions Tests

    func testGetRecentExhibitions_WithValidData_ReturnsExhibitions() {
        // Given
        let expectedCount = 5
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 10)

        // When
        let expectation = self.expectation(description: "Get recent exhibitions")
        var result: Result<[ExhibitionInfo], Error>?

        sut.getRecentExhibitions(count: expectedCount) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(sut.getRecentExhibitionsCallCount, 1, "應該呼叫一次")

        if case .success(let exhibitions) = result {
            XCTAssertEqual(exhibitions.count, expectedCount, "應該返回指定數量的展覽")
        } else {
            XCTFail("應該成功返回展覽資料")
        }
    }

    // MARK: - getExhibitions (by month) Tests

    func testGetExhibitions_WithMonth_ReturnsFilteredExhibitions() {
        // Given
        let targetMonth = "01"
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 24)

        // When
        let expectation = self.expectation(description: "Get exhibitions by month")
        var result: Result<[ExhibitionInfo], Error>?

        sut.getExhibitions(month: targetMonth) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(sut.getExhibitionsCallCount, 1, "應該呼叫一次")
        XCTAssertEqual(sut.lastMonthParameter, targetMonth, "應該傳入正確的月份參數")

        if case .success(let exhibitions) = result {
            XCTAssertTrue(exhibitions.allSatisfy { $0.month == targetMonth }, "所有展覽都應該屬於指定月份")
        } else {
            XCTFail("應該成功返回展覽資料")
        }
    }

    func testGetExhibitions_WithNilMonth_ReturnsAllExhibitions() {
        // Given
        let expectedCount = 10
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: expectedCount)

        // When
        let expectation = self.expectation(description: "Get all exhibitions")
        var result: Result<[ExhibitionInfo], Error>?

        sut.getExhibitions(month: nil) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(sut.lastMonthParameter, "月份參數應該是 nil")

        if case .success(let exhibitions) = result {
            XCTAssertEqual(exhibitions.count, expectedCount, "應該返回所有展覽")
        } else {
            XCTFail("應該成功返回展覽資料")
        }
    }

    // MARK: - searchExhibitions Tests

    func testSearchExhibitions_WithKeyword_ReturnsMatchingExhibitions() {
        // Given
        let keyword = "測試展覽 0"
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 10)

        // When
        let expectation = self.expectation(description: "Search exhibitions")
        var result: Result<[ExhibitionInfo], Error>?

        sut.searchExhibitions(keyword: keyword) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(sut.searchExhibitionsCallCount, 1, "應該呼叫一次")
        XCTAssertEqual(sut.lastSearchKeyword, keyword, "應該記錄搜尋關鍵字")

        if case .success(let exhibitions) = result {
            XCTAssertTrue(exhibitions.allSatisfy { $0.title.contains(keyword) }, "所有結果都應該包含關鍵字")
        } else {
            XCTFail("應該成功返回搜尋結果")
        }
    }

    func testSearchExhibitions_WithNoMatch_ReturnsEmptyArray() {
        // Given
        let keyword = "不存在的展覽"
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 10)

        // When
        let expectation = self.expectation(description: "Search exhibitions no match")
        var result: Result<[ExhibitionInfo], Error>?

        sut.searchExhibitions(keyword: keyword) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .success(let exhibitions) = result {
            XCTAssertTrue(exhibitions.isEmpty, "沒有符合的結果應該返回空陣列")
        } else {
            XCTFail("應該成功返回空陣列")
        }
    }

    func testSearchExhibitions_CaseInsensitive_ReturnsMatches() {
        // Given
        let keyword = "測試"
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 5)

        // When
        let expectation = self.expectation(description: "Search case insensitive")
        var result: Result<[ExhibitionInfo], Error>?

        sut.searchExhibitions(keyword: keyword) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .success(let exhibitions) = result {
            XCTAssertFalse(exhibitions.isEmpty, "應該返回符合的結果")
        } else {
            XCTFail("應該成功返回搜尋結果")
        }
    }

    // MARK: - getExhibitionsPaginated Tests

    func testGetExhibitionsPaginated_FirstPage_ReturnsCorrectCount() {
        // Given
        let pageSize = 5
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 20)

        // When
        let expectation = self.expectation(description: "Get first page")
        var result: Result<PaginatedExhibitionResult, Error>?

        sut.getExhibitionsPaginated(pageSize: pageSize, lastDocument: nil) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(sut.getPaginatedCallCount, 1, "應該呼叫一次")
        XCTAssertEqual(sut.lastPageSize, pageSize, "應該記錄頁面大小")

        if case .success(let paginatedResult) = result {
            XCTAssertEqual(paginatedResult.exhibitions.count, pageSize, "應該返回指定數量的展覽")
            XCTAssertTrue(paginatedResult.hasMore, "應該還有更多資料")
            XCTAssertNotNil(paginatedResult.lastDocument, "應該有分頁游標")
        } else {
            XCTFail("應該成功返回分頁結果")
        }
    }

    func testGetExhibitionsPaginated_LastPage_HasMoreIsFalse() {
        // Given
        let pageSize = 10
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 10)

        // When
        let expectation = self.expectation(description: "Get last page")
        var result: Result<PaginatedExhibitionResult, Error>?

        sut.getExhibitionsPaginated(pageSize: pageSize, lastDocument: nil) { res in
            result = res
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)

        if case .success(let paginatedResult) = result {
            XCTAssertFalse(paginatedResult.hasMore, "最後一頁應該沒有更多資料")
            XCTAssertNil(paginatedResult.lastDocument, "最後一頁不應該有分頁游標")
        } else {
            XCTFail("應該成功返回分頁結果")
        }
    }

    func testGetExhibitionsPaginated_MultipleCalls_ReturnsDifferentData() {
        // Given
        let pageSize = 5
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 15)

        // When - First page
        let expectation1 = self.expectation(description: "Get first page")
        var firstPageResult: PaginatedExhibitionResult?

        sut.getExhibitionsPaginated(pageSize: pageSize, lastDocument: nil) { res in
            if case .success(let result) = res {
                firstPageResult = result
            }
            expectation1.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        // When - Second page
        let expectation2 = self.expectation(description: "Get second page")
        var secondPageResult: PaginatedExhibitionResult?

        sut.getExhibitionsPaginated(pageSize: pageSize, lastDocument: firstPageResult?.lastDocument) { res in
            if case .success(let result) = res {
                secondPageResult = result
            }
            expectation2.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        // Then
        XCTAssertEqual(sut.getPaginatedCallCount, 2, "應該呼叫兩次")
        XCTAssertNotNil(firstPageResult, "第一頁應該有結果")
        XCTAssertNotNil(secondPageResult, "第二頁應該有結果")

        if let first = firstPageResult, let second = secondPageResult {
            XCTAssertEqual(first.exhibitions.count, pageSize, "第一頁應該有 5 筆")
            XCTAssertEqual(second.exhibitions.count, pageSize, "第二頁應該有 5 筆")

            // 確認資料不重複
            let firstIds = Set(first.exhibitions.map { $0.id })
            let secondIds = Set(second.exhibitions.map { $0.id })
            XCTAssertTrue(firstIds.isDisjoint(with: secondIds), "兩頁的資料不應該重複")
        }
    }

    // MARK: - Error Handling Tests

    func testGetExhibitionsPaginated_WithError_ReturnsError() {
        // Given
        let expectedError = NSError(domain: "test", code: 404, userInfo: nil)
        sut.mockError = expectedError

        // When
        let expectation = self.expectation(description: "Get paginated with error")
        var result: Result<PaginatedExhibitionResult, Error>?

        sut.getExhibitionsPaginated(pageSize: 10, lastDocument: nil) { res in
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

    // MARK: - Call Count Tests

    func testMultipleCalls_TracksCallCount() {
        // Given
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 10)

        let expectation1 = expectation(description: "Call 1")
        let expectation2 = expectation(description: "Call 2")
        let expectation3 = expectation(description: "Call 3")

        // When
        sut.getRandomExhibitions(count: 5) { _ in expectation1.fulfill() }
        sut.getHotExhibitions(count: 5) { _ in expectation2.fulfill() }
        sut.getRecentExhibitions(count: 5) { _ in expectation3.fulfill() }

        waitForExpectations(timeout: 1.0)

        // Then
        XCTAssertEqual(sut.getRandomExhibitionsCallCount, 1)
        XCTAssertEqual(sut.getHotExhibitionsCallCount, 1)
        XCTAssertEqual(sut.getRecentExhibitionsCallCount, 1)
    }

    // MARK: - Reset Tests

    func testReset_ClearsAllState() {
        // Given
        sut.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 10)

        let expectation = expectation(description: "Call before reset")
        sut.getRandomExhibitions(count: 5) { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1.0)

        // When
        sut.reset()

        // Then
        XCTAssertTrue(sut.mockExhibitions.isEmpty, "展覽資料應該被清除")
        XCTAssertNil(sut.mockError, "錯誤應該被清除")
        XCTAssertEqual(sut.getRandomExhibitionsCallCount, 0, "呼叫次數應該被重置")
    }
}
