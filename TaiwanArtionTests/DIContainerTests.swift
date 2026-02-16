//
//  DIContainerTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/13.
//

import XCTest
@testable import TaiwanArtion

final class DIContainerTests: XCTestCase {

    // MARK: - Singleton Tests

    func testSharedInstance_ReturnsSameInstance() {
        // When
        let instance1 = DIContainer.shared
        let instance2 = DIContainer.shared

        // Then
        XCTAssertTrue(instance1 === instance2, "shared 應該返回相同的實例")
    }

    // MARK: - Repository Tests

    func testExhibitionRepository_IsNotNil() {
        // When
        let repository = DIContainer.shared.exhibitionRepository

        // Then
        XCTAssertNotNil(repository, "exhibitionRepository 不應該為 nil")
    }

    func testNewsRepository_IsNotNil() {
        // When
        let repository = DIContainer.shared.newsRepository

        // Then
        XCTAssertNotNil(repository, "newsRepository 不應該為 nil")
    }

    func testAuthRepository_IsNotNil() {
        // When
        let repository = DIContainer.shared.authRepository

        // Then
        XCTAssertNotNil(repository, "authRepository 不應該為 nil")
    }

    // MARK: - Repository Type Tests

    func testExhibitionRepository_IsCorrectType() {
        // When
        let repository = DIContainer.shared.exhibitionRepository

        // Then
        XCTAssertTrue(repository is FirebaseExhibitionRepository, "exhibitionRepository 應該是 FirebaseExhibitionRepository 類型")
    }

    func testNewsRepository_IsCorrectType() {
        // When
        let repository = DIContainer.shared.newsRepository

        // Then
        XCTAssertTrue(repository is FirebaseNewsRepository, "newsRepository 應該是 FirebaseNewsRepository 類型")
    }

    func testAuthRepository_IsCorrectType() {
        // When
        let repository = DIContainer.shared.authRepository

        // Then
        XCTAssertTrue(repository is FirebaseAuthRepository, "authRepository 應該是 FirebaseAuthRepository 類型")
    }

    // MARK: - ViewModel Factory Tests

    func testMakeHomeViewModel_ReturnsNewInstance() {
        // When
        let viewModel1 = DIContainer.shared.makeHomeViewModel()
        let viewModel2 = DIContainer.shared.makeHomeViewModel()

        // Then
        XCTAssertNotNil(viewModel1, "HomeViewModel 不應該為 nil")
        XCTAssertTrue(viewModel1 !== viewModel2, "應該返回不同的實例")
    }

    func testMakeCollectViewModel_ReturnsNewInstance() {
        // When
        let viewModel1 = DIContainer.shared.makeCollectViewModel()
        let viewModel2 = DIContainer.shared.makeCollectViewModel()

        // Then
        XCTAssertNotNil(viewModel1, "CollectViewModel 不應該為 nil")
        XCTAssertTrue(viewModel1 !== viewModel2, "應該返回不同的實例")
    }

    func testMakeSearchViewModel_ReturnsNewInstance() {
        // When
        let viewModel1 = DIContainer.shared.makeSearchViewModel()
        let viewModel2 = DIContainer.shared.makeSearchViewModel()

        // Then
        XCTAssertNotNil(viewModel1, "SearchViewModel 不應該為 nil")
        XCTAssertTrue(viewModel1 !== viewModel2, "應該返回不同的實例")
    }

    func testMakeExhibitionCardViewModel_ReturnsNewInstance() {
        // When
        let viewModel1 = DIContainer.shared.makeExhibitionCardViewModel()
        let viewModel2 = DIContainer.shared.makeExhibitionCardViewModel()

        // Then
        XCTAssertNotNil(viewModel1, "ExhibitionCardViewModel 不應該為 nil")
        XCTAssertTrue(viewModel1 !== viewModel2, "應該返回不同的實例")
    }

    func testMakeLoginViewModel_ReturnsNewInstance() {
        // When
        let viewModel1 = DIContainer.shared.makeLoginViewModel()
        let viewModel2 = DIContainer.shared.makeLoginViewModel()

        // Then
        XCTAssertNotNil(viewModel1, "LoginViewModel 不應該為 nil")
        XCTAssertTrue(viewModel1 !== viewModel2, "應該返回不同的實例")
    }

    func testMakeRegisterViewModel_ReturnsNewInstance() {
        // When
        let viewModel1 = DIContainer.shared.makeRegisterViewModel()
        let viewModel2 = DIContainer.shared.makeRegisterViewModel()

        // Then
        XCTAssertNotNil(viewModel1, "RegisterViewModel 不應該為 nil")
        XCTAssertTrue(viewModel1 !== viewModel2, "應該返回不同的實例")
    }

    func testMakePersonInfoViewModel_ReturnsNewInstance() {
        // When
        let viewModel1 = DIContainer.shared.makePersonInfoViewModel()
        let viewModel2 = DIContainer.shared.makePersonInfoViewModel()

        // Then
        XCTAssertNotNil(viewModel1, "PersonInfoViewModel 不應該為 nil")
        XCTAssertTrue(viewModel1 !== viewModel2, "應該返回不同的實例")
    }

    // MARK: - Lazy Initialization Tests

    func testRepositories_AreLazilyInitialized() {
        // Given
        // 獲取 DIContainer
        let container = DIContainer.shared

        // When
        // 首次訪問 repository
        let repo1 = container.exhibitionRepository as AnyObject
        let repo2 = container.exhibitionRepository as AnyObject

        // Then
        // 應該返回相同的實例（lazy 只初始化一次）
        XCTAssertTrue(repo1 === repo2, "lazy 屬性應該返回相同的實例")
    }

    // MARK: - Thread Safety Tests

    func testConcurrentAccess_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 100

        // When
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            let container = DIContainer.shared

            if index % 4 == 0 {
                _ = container.exhibitionRepository
            } else if index % 4 == 1 {
                _ = container.newsRepository
            } else if index % 4 == 2 {
                _ = container.authRepository
            } else {
                _ = container.makeHomeViewModel()
            }

            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "並發存取不應該崩潰")
        }
    }
}
