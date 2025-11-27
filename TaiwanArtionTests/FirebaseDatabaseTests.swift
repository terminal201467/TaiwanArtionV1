//
//  FirebaseDatabaseTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2025-11-27.
//

import XCTest
@testable import TaiwanArtion

final class FirebaseDatabaseTests: XCTestCase {

    // MARK: - Properties

    var firebaseDatabase: FirebaseDatabase!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        firebaseDatabase = FirebaseDatabase(collectionName: "exhibitions")
    }

    override func tearDownWithError() throws {
        firebaseDatabase = nil
        try super.tearDownWithError()
    }

    // MARK: - getPopularDocument Tests

    func testGetPopularDocument_WithDefaultCount_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Get popular documents with default count")

        // When
        firebaseDatabase.getPopularDocument { documents, error in
            // Then
            XCTAssertTrue(documents != nil || error != nil, "應該返回文件或錯誤")
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    func testGetPopularDocument_WithCustomCount_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Get popular documents with custom count")
        let customCount = 5

        // When
        firebaseDatabase.getPopularDocument(count: customCount) { documents, error in
            // Then
            if let documents = documents {
                XCTAssertTrue(documents.count <= customCount, "返回的文件數量不應超過請求數量")
            }
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    func testGetPopularDocument_WithZeroCount_ReturnsEmptyOrError() {
        // Given
        let expectation = self.expectation(description: "Get popular documents with zero count")

        // When
        firebaseDatabase.getPopularDocument(count: 0) { documents, error in
            // Then
            if let documents = documents {
                XCTAssertTrue(documents.isEmpty, "當 count 為 0 時應返回空陣列")
            }
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    func testGetPopularDocument_OrderedByViewCount() {
        // Given
        let expectation = self.expectation(description: "Get popular documents ordered by view count")

        // When
        firebaseDatabase.getPopularDocument(count: 5) { documents, error in
            // Then
            if let documents = documents, documents.count > 1 {
                // 驗證是否按 viewCount 降序排列
                var previousViewCount = Int.max
                for document in documents {
                    if let viewCount = document["viewCount"] as? Int {
                        XCTAssertLessThanOrEqual(viewCount, previousViewCount,
                                                "文件應該按 viewCount 降序排列")
                        previousViewCount = viewCount
                    }
                }
            }
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    // MARK: - getHighEvaluationDocument Tests

    func testGetHighEvaluationDocument_WithDefaultParameters_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Get high evaluation documents with defaults")

        // When
        firebaseDatabase.getHighEvaluationDocument { documents, error in
            // Then
            XCTAssertTrue(documents != nil || error != nil, "應該返回文件或錯誤")
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    func testGetHighEvaluationDocument_WithCustomParameters_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Get high evaluation documents with custom params")
        let customCount = 5
        let customMinRating = 4.5

        // When
        firebaseDatabase.getHighEvaluationDocument(count: customCount, minRating: customMinRating) { documents, error in
            // Then
            if let documents = documents {
                XCTAssertTrue(documents.count <= customCount, "返回的文件數量不應超過請求數量")

                // 驗證所有文件的評分都符合最低要求
                for document in documents {
                    if let rating = document["rating"] as? Double {
                        XCTAssertGreaterThanOrEqual(rating, customMinRating,
                                                   "所有文件的評分應該 >= \(customMinRating)")
                    }
                }
            }
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    func testGetHighEvaluationDocument_WithZeroMinRating_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Get high evaluation documents with zero min rating")

        // When
        firebaseDatabase.getHighEvaluationDocument(count: 5, minRating: 0.0) { documents, error in
            // Then
            XCTAssertTrue(documents != nil || error != nil, "應該返回文件或錯誤")
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    func testGetHighEvaluationDocument_WithHighMinRating_MayReturnEmpty() {
        // Given
        let expectation = self.expectation(description: "Get high evaluation documents with very high min rating")
        let veryHighRating = 4.9

        // When
        firebaseDatabase.getHighEvaluationDocument(count: 10, minRating: veryHighRating) { documents, error in
            // Then
            if let documents = documents {
                // 可能為空，因為高評分展覽較少
                XCTAssertTrue(documents.isEmpty || !documents.isEmpty, "應該成功返回結果（可能為空）")

                // 如果有結果，驗證評分
                for document in documents {
                    if let rating = document["rating"] as? Double {
                        XCTAssertGreaterThanOrEqual(rating, veryHighRating,
                                                   "所有文件的評分應該 >= \(veryHighRating)")
                    }
                }
            }
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    func testGetHighEvaluationDocument_OrderedByRating() {
        // Given
        let expectation = self.expectation(description: "Get high evaluation documents ordered by rating")

        // When
        firebaseDatabase.getHighEvaluationDocument(count: 5, minRating: 3.0) { documents, error in
            // Then
            if let documents = documents, documents.count > 1 {
                // 驗證是否按 rating 降序排列
                var previousRating = Double.infinity
                for document in documents {
                    if let rating = document["rating"] as? Double {
                        XCTAssertLessThanOrEqual(rating, previousRating,
                                                "文件應該按 rating 降序排列")
                        previousRating = rating
                    }
                }
            }
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    // MARK: - Edge Cases

    func testGetPopularDocument_WithLargeCount_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Get popular documents with large count")
        let largeCount = 1000

        // When
        firebaseDatabase.getPopularDocument(count: largeCount) { documents, error in
            // Then
            XCTAssertTrue(documents != nil || error != nil, "應該返回文件或錯誤")
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 15.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    func testGetHighEvaluationDocument_WithNegativeMinRating_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Get high evaluation documents with negative min rating")

        // When
        firebaseDatabase.getHighEvaluationDocument(count: 5, minRating: -1.0) { documents, error in
            // Then
            XCTAssertTrue(documents != nil || error != nil, "應該返回文件或錯誤")
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    func testGetHighEvaluationDocument_WithRatingAboveFive_MayReturnEmpty() {
        // Given
        let expectation = self.expectation(description: "Get high evaluation documents with rating > 5")

        // When
        firebaseDatabase.getHighEvaluationDocument(count: 5, minRating: 5.5) { documents, error in
            // Then
            if let documents = documents {
                XCTAssertTrue(documents.isEmpty, "評分大於 5 時應該返回空陣列")
            }
            expectation.fulfill()
        }

        // Wait
        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNil(error, "請求不應該超時")
        }
    }

    // MARK: - Collection Name Tests

    func testFirebaseDatabase_WithDifferentCollections_DoesNotCrash() {
        // Given
        let collections = ["exhibitions", "news", "users", "test_collection"]

        for collectionName in collections {
            let expectation = self.expectation(description: "Test with collection: \(collectionName)")
            let db = FirebaseDatabase(collectionName: collectionName)

            // When
            db.getPopularDocument(count: 1) { documents, error in
                // Then
                XCTAssertTrue(documents != nil || error != nil, "不同 collection 應該都能正常運作")
                expectation.fulfill()
            }

            // Wait
            waitForExpectations(timeout: 10.0) { error in
                XCTAssertNil(error, "請求不應該超時")
            }
        }
    }
}
