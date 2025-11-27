//
//  AppLoggerTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2025-11-27.
//

import XCTest
@testable import TaiwanArtion

final class AppLoggerTests: XCTestCase {

    // MARK: - Basic Logging Tests

    func testDebugLogging_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.debug("Test debug message")
        }(), "Debug logging 不應該導致崩潰")
    }

    func testInfoLogging_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.info("Test info message")
        }(), "Info logging 不應該導致崩潰")
    }

    func testWarningLogging_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.warning("Test warning message")
        }(), "Warning logging 不應該導致崩潰")
    }

    func testErrorLogging_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.error("Test error message")
        }(), "Error logging 不應該導致崩潰")
    }

    func testErrorLoggingWithError_DoesNotCrash() {
        // Given
        let testError = NSError(domain: "TestDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Test error"])

        // When & Then
        XCTAssertNoThrow({
            AppLogger.error("Test error with error object", error: testError)
        }(), "Error logging with error object 不應該導致崩潰")
    }

    func testFaultLogging_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.fault("Test fault message")
        }(), "Fault logging 不應該導致崩潰")
    }

    // MARK: - Category Tests

    func testLoggingWithDifferentCategories_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.debug("Test", category: .general)
            AppLogger.info("Test", category: .network)
            AppLogger.warning("Test", category: .firebase)
            AppLogger.error("Test", category: .auth)
            AppLogger.debug("Test", category: .ui)
            AppLogger.info("Test", category: .viewModel)
            AppLogger.warning("Test", category: .database)
            AppLogger.error("Test", category: .map)
        }(), "不同 category 的 logging 都不應該崩潰")
    }

    // MARK: - Specialized Logging Tests

    func testLogNetworkRequest_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.logNetworkRequest(
                url: "https://api.example.com/data",
                method: "GET",
                headers: ["Authorization": "Bearer token"]
            )
        }(), "Network request logging 不應該導致崩潰")
    }

    func testLogNetworkResponse_DoesNotCrash() {
        // Given
        let testData = "{\"key\": \"value\"}".data(using: .utf8)

        // When & Then
        XCTAssertNoThrow({
            AppLogger.logNetworkResponse(
                url: "https://api.example.com/data",
                statusCode: 200,
                data: testData
            )
        }(), "Network response logging 不應該導致崩潰")
    }

    func testLogFirebaseOperation_Success() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.logFirebaseOperation(
                operation: "Fetch",
                collection: "users",
                documentID: "user123",
                success: true,
                error: nil
            )
        }(), "Firebase operation logging (success) 不應該導致崩潰")
    }

    func testLogFirebaseOperation_Failure() {
        // Given
        let testError = NSError(domain: "Firebase", code: 500, userInfo: nil)

        // When & Then
        XCTAssertNoThrow({
            AppLogger.logFirebaseOperation(
                operation: "Update",
                collection: "posts",
                documentID: "post456",
                success: false,
                error: testError
            )
        }(), "Firebase operation logging (failure) 不應該導致崩潰")
    }

    func testLogAuthentication_Success() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.logAuthentication(
                action: "Login",
                provider: "Google",
                userID: "user123",
                success: true,
                error: nil
            )
        }(), "Authentication logging (success) 不應該導致崩潰")
    }

    func testLogAuthentication_Failure() {
        // Given
        let testError = NSError(domain: "Auth", code: 401, userInfo: nil)

        // When & Then
        XCTAssertNoThrow({
            AppLogger.logAuthentication(
                action: "Login",
                provider: "Email",
                userID: nil,
                success: false,
                error: testError
            )
        }(), "Authentication logging (failure) 不應該導致崩潰")
    }

    func testLogNavigation_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.logNavigation(from: "HomeViewController", to: "DetailViewController")
        }(), "Navigation logging 不應該導致崩潰")
    }

    func testLogViewModelEvent_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.logViewModelEvent(
                viewModel: "LoginViewModel",
                event: "LoginButtonTapped",
                data: ["email": "test@example.com"]
            )
        }(), "ViewModel event logging 不應該導致崩潰")
    }

    // MARK: - Performance Logging Tests

    func testMeasureTime_ExecutesBlock() {
        // Given
        var blockExecuted = false

        // When
        AppLogger.measureTime("Test operation") {
            blockExecuted = true
        }

        // Then
        XCTAssertTrue(blockExecuted, "Block 應該被執行")
    }

    func testMeasureTimeAsync_ExecutesBlockAndCompletion() {
        // Given
        let expectation = self.expectation(description: "Async block executed")
        var blockExecuted = false

        // When
        AppLogger.measureTimeAsync("Test async operation") { completion in
            blockExecuted = true
            completion()
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertTrue(blockExecuted, "Async block 應該被執行")
        }
    }

    // MARK: - Enter/Exit Logging Tests

    func testEnterLogging_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.enter()
        }(), "Enter logging 不應該導致崩潰")
    }

    func testExitLogging_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.exit()
        }(), "Exit logging 不應該導致崩潰")
    }

    // MARK: - String Extension Tests

    func testStringTruncate_LongString() {
        // Given
        let longString = String(repeating: "a", count: 100)

        // When
        let truncated = longString.truncate(length: 10)

        // Then
        XCTAssertEqual(truncated.count, 13, "截斷後的字串長度應該為 10 + 3('...')")
        XCTAssertTrue(truncated.hasSuffix("..."), "截斷後的字串應該以 '...' 結尾")
    }

    func testStringTruncate_ShortString() {
        // Given
        let shortString = "Hello"

        // When
        let truncated = shortString.truncate(length: 10)

        // Then
        XCTAssertEqual(truncated, shortString, "短字串不應該被截斷")
        XCTAssertEqual(truncated.count, 5, "短字串長度應該保持不變")
    }

    func testStringTruncate_ExactLength() {
        // Given
        let exactString = "HelloWorld"

        // When
        let truncated = exactString.truncate(length: 10)

        // Then
        XCTAssertEqual(truncated, exactString, "長度剛好的字串不應該被截斷")
    }

    // MARK: - Edge Cases

    func testLoggingWithEmptyString_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            AppLogger.debug("")
            AppLogger.info("")
            AppLogger.warning("")
            AppLogger.error("")
        }(), "空字串 logging 不應該導致崩潰")
    }

    func testLoggingWithLongString_DoesNotCrash() {
        // Given
        let longMessage = String(repeating: "a", count: 10000)

        // When & Then
        XCTAssertNoThrow({
            AppLogger.debug(longMessage)
        }(), "長字串 logging 不應該導致崩潰")
    }

    func testLoggingWithSpecialCharacters_DoesNotCrash() {
        // Given
        let specialMessage = "!@#$%^&*(){}[]|\\:;\"'<>,.?/~`測試中文🎉"

        // When & Then
        XCTAssertNoThrow({
            AppLogger.debug(specialMessage)
        }(), "特殊字元 logging 不應該導致崩潰")
    }
}
