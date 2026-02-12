//
//  HeightCacheTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/13.
//

import XCTest
@testable import TaiwanArtion

final class HeightCacheTests: XCTestCase {

    // MARK: - Properties

    var sut: HeightCache!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = HeightCache.shared
        sut.clear()
    }

    override func tearDownWithError() throws {
        sut.clear()
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Singleton Tests

    func testSharedInstance_ReturnsSameInstance() {
        // When
        let instance1 = HeightCache.shared
        let instance2 = HeightCache.shared

        // Then
        XCTAssertTrue(instance1 === instance2, "shared 應該返回相同的實例")
    }

    // MARK: - Set and Get Tests

    func testSetHeight_AndGetHeight_ReturnsCorrectValue() {
        // Given
        let key = "test_key"
        let height: CGFloat = 100.0

        // When
        sut.setHeight(height, for: key)
        let retrieved = sut.height(for: key)

        // Then
        XCTAssertEqual(retrieved, height, "應該返回設定的高度")
    }

    func testGetHeight_WithNonExistentKey_ReturnsNil() {
        // When
        let retrieved = sut.height(for: "non_existent_key")

        // Then
        XCTAssertNil(retrieved, "不存在的 key 應該返回 nil")
    }

    func testSetHeight_Overwrite_UpdatesValue() {
        // Given
        let key = "test_key"
        let firstHeight: CGFloat = 100.0
        let secondHeight: CGFloat = 200.0

        // When
        sut.setHeight(firstHeight, for: key)
        sut.setHeight(secondHeight, for: key)
        let retrieved = sut.height(for: key)

        // Then
        XCTAssertEqual(retrieved, secondHeight, "應該返回最新的高度")
    }

    // MARK: - Height with Calculator Tests

    func testHeightWithCalculator_CacheMiss_CallsCalculator() {
        // Given
        let key = "calc_key"
        let expectedHeight: CGFloat = 150.0
        var calculatorCalled = false

        // When
        let height = sut.height(for: key) {
            calculatorCalled = true
            return expectedHeight
        }

        // Then
        XCTAssertTrue(calculatorCalled, "快取未命中時應該呼叫 calculator")
        XCTAssertEqual(height, expectedHeight, "應該返回計算的高度")
    }

    func testHeightWithCalculator_CacheHit_DoesNotCallCalculator() {
        // Given
        let key = "calc_key"
        let cachedHeight: CGFloat = 100.0
        sut.setHeight(cachedHeight, for: key)
        var calculatorCalled = false

        // When
        let height = sut.height(for: key) {
            calculatorCalled = true
            return 999.0
        }

        // Then
        XCTAssertFalse(calculatorCalled, "快取命中時不應該呼叫 calculator")
        XCTAssertEqual(height, cachedHeight, "應該返回快取的高度")
    }

    func testHeightWithCalculator_CachesResult() {
        // Given
        let key = "calc_key"
        let expectedHeight: CGFloat = 150.0

        // When
        _ = sut.height(for: key) { expectedHeight }
        let retrieved = sut.height(for: key)

        // Then
        XCTAssertEqual(retrieved, expectedHeight, "計算結果應該被快取")
    }

    // MARK: - Remove Tests

    func testRemoveHeight_RemovesValue() {
        // Given
        let key = "test_key"
        sut.setHeight(100.0, for: key)

        // When
        sut.removeHeight(for: key)
        let retrieved = sut.height(for: key)

        // Then
        XCTAssertNil(retrieved, "移除後應該返回 nil")
    }

    func testRemoveHeight_NonExistentKey_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.removeHeight(for: "non_existent")
        }(), "移除不存在的 key 不應該崩潰")
    }

    // MARK: - Clear Tests

    func testClear_RemovesAllValues() {
        // Given
        sut.setHeight(100.0, for: "key1")
        sut.setHeight(200.0, for: "key2")
        sut.setHeight(300.0, for: "key3")

        // When
        sut.clear()

        // Then
        XCTAssertNil(sut.height(for: "key1"), "key1 應該被清除")
        XCTAssertNil(sut.height(for: "key2"), "key2 應該被清除")
        XCTAssertNil(sut.height(for: "key3"), "key3 應該被清除")
    }

    func testClearWithPrefix_OnlyRemovesMatchingKeys() {
        // Given
        sut.setHeight(100.0, for: "home-0-1")
        sut.setHeight(200.0, for: "home-1-0")
        sut.setHeight(300.0, for: "search-0-0")
        sut.setHeight(400.0, for: "detail-0-0")

        // When
        sut.clear(prefix: "home")

        // Then
        XCTAssertNil(sut.height(for: "home-0-1"), "home 前綴的 key 應該被清除")
        XCTAssertNil(sut.height(for: "home-1-0"), "home 前綴的 key 應該被清除")
        XCTAssertNotNil(sut.height(for: "search-0-0"), "search 前綴的 key 不應該被清除")
        XCTAssertNotNil(sut.height(for: "detail-0-0"), "detail 前綴的 key 不應該被清除")
    }

    func testClearWithPrefix_NoMatch_KeepsAllValues() {
        // Given
        sut.setHeight(100.0, for: "key1")
        sut.setHeight(200.0, for: "key2")

        // When
        sut.clear(prefix: "nonexistent")

        // Then
        XCTAssertNotNil(sut.height(for: "key1"), "key1 應該保留")
        XCTAssertNotNil(sut.height(for: "key2"), "key2 應該保留")
    }

    // MARK: - Key Generator Tests

    func testKeyForIndexPath_WithoutPrefix_ReturnsCorrectKey() {
        // Given
        let indexPath = IndexPath(row: 5, section: 2)

        // When
        let key = HeightCache.key(for: indexPath)

        // Then
        XCTAssertEqual(key, "2-5", "應該返回 'section-row' 格式的 key")
    }

    func testKeyForIndexPath_WithPrefix_ReturnsCorrectKey() {
        // Given
        let indexPath = IndexPath(row: 3, section: 1)

        // When
        let key = HeightCache.key(for: indexPath, prefix: "home")

        // Then
        XCTAssertEqual(key, "home-1-3", "應該返回 'prefix-section-row' 格式的 key")
    }

    func testKeyForIdentifier_ReturnsCorrectKey() {
        // Given
        let identifier = "myCell"
        let section = 4

        // When
        let key = HeightCache.key(for: identifier, section: section)

        // Then
        XCTAssertEqual(key, "myCell-4", "應該返回 'identifier-section' 格式的 key")
    }

    // MARK: - Thread Safety Tests

    func testConcurrentAccess_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 100

        // When
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            let key = "concurrent_\(index % 10)"
            let height = CGFloat(index)

            if index % 3 == 0 {
                self.sut.setHeight(height, for: key)
            } else if index % 3 == 1 {
                _ = self.sut.height(for: key)
            } else {
                _ = self.sut.height(for: key) { height }
            }
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "並發存取不應該崩潰")
        }
    }

    func testConcurrentReadWrite_MaintainsDataIntegrity() {
        // Given
        let key = "shared_key"
        let iterations = 1000

        // When
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            let height = CGFloat(index)
            self.sut.setHeight(height, for: key)
            _ = self.sut.height(for: key)
        }

        // Then
        // 確認最後能正常讀取
        let finalHeight = sut.height(for: key)
        XCTAssertNotNil(finalHeight, "並發操作後應該能讀取到值")
    }

    // MARK: - Edge Cases Tests

    func testSetHeight_ZeroValue_StoresCorrectly() {
        // Given
        let key = "zero_key"
        let height: CGFloat = 0.0

        // When
        sut.setHeight(height, for: key)
        let retrieved = sut.height(for: key)

        // Then
        XCTAssertEqual(retrieved, 0.0, "應該能存儲 0 值")
    }

    func testSetHeight_NegativeValue_StoresCorrectly() {
        // Given
        let key = "negative_key"
        let height: CGFloat = -50.0

        // When
        sut.setHeight(height, for: key)
        let retrieved = sut.height(for: key)

        // Then
        XCTAssertEqual(retrieved, -50.0, "應該能存儲負值")
    }

    func testSetHeight_LargeValue_StoresCorrectly() {
        // Given
        let key = "large_key"
        let height: CGFloat = 999999.99

        // When
        sut.setHeight(height, for: key)
        let retrieved = sut.height(for: key)

        // Then
        XCTAssertEqual(retrieved, 999999.99, "應該能存儲大值")
    }

    func testEmptyKeyString_WorksCorrectly() {
        // Given
        let key = ""
        let height: CGFloat = 100.0

        // When
        sut.setHeight(height, for: key)
        let retrieved = sut.height(for: key)

        // Then
        XCTAssertEqual(retrieved, height, "空字串 key 應該能正常工作")
    }

    func testSpecialCharactersInKey_WorksCorrectly() {
        // Given
        let key = "特殊字元!@#$%^&*()"
        let height: CGFloat = 100.0

        // When
        sut.setHeight(height, for: key)
        let retrieved = sut.height(for: key)

        // Then
        XCTAssertEqual(retrieved, height, "特殊字元 key 應該能正常工作")
    }

    // MARK: - Multiple Keys Tests

    func testMultipleKeys_StoreIndependently() {
        // Given
        let keys = (0..<100).map { "key_\($0)" }
        let heights = keys.enumerated().map { CGFloat($0.offset) }

        // When
        for (key, height) in zip(keys, heights) {
            sut.setHeight(height, for: key)
        }

        // Then
        for (key, expectedHeight) in zip(keys, heights) {
            let retrieved = sut.height(for: key)
            XCTAssertEqual(retrieved, expectedHeight, "\(key) 應該返回正確的高度")
        }
    }
}
