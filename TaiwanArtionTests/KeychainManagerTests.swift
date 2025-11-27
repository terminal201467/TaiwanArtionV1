//
//  KeychainManagerTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2025-11-27.
//

import XCTest
@testable import TaiwanArtion

final class KeychainManagerTests: XCTestCase {

    var sut: KeychainManager!
    let testKey = "test_key"
    let testValue = "test_value"

    override func setUp() {
        super.setUp()
        sut = KeychainManager.shared
        // 清除測試用的鍵值
        sut.delete(key: testKey)
    }

    override func tearDown() {
        // 清理測試數據
        sut.delete(key: testKey)
        sut = nil
        super.tearDown()
    }

    // MARK: - Save Tests

    func testSaveString_Success() {
        // Given
        let key = testKey
        let value = testValue

        // When
        let result = sut.save(key: key, value: value)

        // Then
        XCTAssertTrue(result, "儲存應該成功")
        XCTAssertEqual(sut.get(key: key), value, "讀取的值應該與儲存的值相同")
    }

    func testSaveData_Success() {
        // Given
        let key = testKey
        let data = "test data".data(using: .utf8)!

        // When
        let result = sut.save(key: key, data: data)

        // Then
        XCTAssertTrue(result, "儲存應該成功")
        XCTAssertEqual(sut.getData(key: key), data, "讀取的資料應該與儲存的資料相同")
    }

    func testSaveOverwrite_Success() {
        // Given
        let key = testKey
        let firstValue = "first value"
        let secondValue = "second value"

        // When
        sut.save(key: key, value: firstValue)
        let result = sut.save(key: key, value: secondValue)

        // Then
        XCTAssertTrue(result, "覆寫應該成功")
        XCTAssertEqual(sut.get(key: key), secondValue, "應該讀取到最新的值")
        XCTAssertNotEqual(sut.get(key: key), firstValue, "不應該讀取到舊的值")
    }

    // MARK: - Get Tests

    func testGet_ExistingKey_ReturnsValue() {
        // Given
        let key = testKey
        let value = testValue
        sut.save(key: key, value: value)

        // When
        let retrievedValue = sut.get(key: key)

        // Then
        XCTAssertNotNil(retrievedValue, "應該能夠讀取已儲存的值")
        XCTAssertEqual(retrievedValue, value, "讀取的值應該與儲存的值相同")
    }

    func testGet_NonExistingKey_ReturnsNil() {
        // Given
        let key = "non_existing_key"

        // When
        let retrievedValue = sut.get(key: key)

        // Then
        XCTAssertNil(retrievedValue, "不存在的鍵值應該返回 nil")
    }

    func testGetData_ExistingKey_ReturnsData() {
        // Given
        let key = testKey
        let data = "test data".data(using: .utf8)!
        sut.save(key: key, data: data)

        // When
        let retrievedData = sut.getData(key: key)

        // Then
        XCTAssertNotNil(retrievedData, "應該能夠讀取已儲存的資料")
        XCTAssertEqual(retrievedData, data, "讀取的資料應該與儲存的資料相同")
    }

    // MARK: - Delete Tests

    func testDelete_ExistingKey_Success() {
        // Given
        let key = testKey
        let value = testValue
        sut.save(key: key, value: value)

        // When
        let result = sut.delete(key: key)

        // Then
        XCTAssertTrue(result, "刪除應該成功")
        XCTAssertNil(sut.get(key: key), "刪除後應該無法讀取到值")
    }

    func testDelete_NonExistingKey_Success() {
        // Given
        let key = "non_existing_key"

        // When
        let result = sut.delete(key: key)

        // Then
        XCTAssertTrue(result, "刪除不存在的鍵值應該返回成功")
    }

    // MARK: - Contains Tests

    func testContains_ExistingKey_ReturnsTrue() {
        // Given
        let key = testKey
        let value = testValue
        sut.save(key: key, value: value)

        // When
        let result = sut.contains(key: key)

        // Then
        XCTAssertTrue(result, "應該檢測到鍵值存在")
    }

    func testContains_NonExistingKey_ReturnsFalse() {
        // Given
        let key = "non_existing_key"

        // When
        let result = sut.contains(key: key)

        // Then
        XCTAssertFalse(result, "不存在的鍵值應該返回 false")
    }

    func testContains_AfterDelete_ReturnsFalse() {
        // Given
        let key = testKey
        let value = testValue
        sut.save(key: key, value: value)

        // When
        sut.delete(key: key)
        let result = sut.contains(key: key)

        // Then
        XCTAssertFalse(result, "刪除後應該檢測不到鍵值")
    }

    // MARK: - Clear Tests

    func testClear_RemovesAllItems() {
        // Given
        let keys = ["key1", "key2", "key3"]
        keys.forEach { key in
            sut.save(key: key, value: "value_\(key)")
        }

        // When
        let result = sut.clear()

        // Then
        XCTAssertTrue(result, "清除應該成功")
        keys.forEach { key in
            XCTAssertNil(sut.get(key: key), "清除後所有鍵值都應該不存在")
        }
    }

    // MARK: - Edge Cases

    func testSave_EmptyString_Success() {
        // Given
        let key = testKey
        let value = ""

        // When
        let result = sut.save(key: key, value: value)

        // Then
        XCTAssertTrue(result, "儲存空字串應該成功")
        XCTAssertEqual(sut.get(key: key), value, "應該能讀取空字串")
    }

    func testSave_LongString_Success() {
        // Given
        let key = testKey
        let value = String(repeating: "a", count: 10000)

        // When
        let result = sut.save(key: key, value: value)

        // Then
        XCTAssertTrue(result, "儲存長字串應該成功")
        XCTAssertEqual(sut.get(key: key), value, "應該能完整讀取長字串")
    }

    func testSave_SpecialCharacters_Success() {
        // Given
        let key = testKey
        let value = "!@#$%^&*(){}[]|\\:;\"'<>,.?/~`測試中文"

        // When
        let result = sut.save(key: key, value: value)

        // Then
        XCTAssertTrue(result, "儲存特殊字元應該成功")
        XCTAssertEqual(sut.get(key: key), value, "應該能正確讀取特殊字元")
    }

    // MARK: - Security Tests

    func testMultipleInstances_ShareSameData() {
        // Given
        let key = testKey
        let value = testValue
        let firstInstance = KeychainManager.shared
        let secondInstance = KeychainManager.shared

        // When
        firstInstance.save(key: key, value: value)
        let retrievedValue = secondInstance.get(key: key)

        // Then
        XCTAssertEqual(retrievedValue, value, "不同實例應該能存取相同的資料（Singleton）")
    }

    func testDataPersistence_AcrossAppRestarts() {
        // 這個測試模擬 App 重啟後資料應該仍然存在
        // Given
        let key = testKey
        let value = testValue

        // When
        sut.save(key: key, value: value)

        // 模擬 App 重啟：重新獲取 KeychainManager 實例
        let newInstance = KeychainManager.shared
        let retrievedValue = newInstance.get(key: key)

        // Then
        XCTAssertEqual(retrievedValue, value, "Keychain 資料應該在 App 重啟後仍然存在")
    }
}
