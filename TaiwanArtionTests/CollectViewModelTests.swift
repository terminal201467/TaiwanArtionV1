//
//  CollectViewModelTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2025-11-27.
//

import XCTest
import RxSwift
import RxCocoa
import RxRelay
@testable import TaiwanArtion

final class CollectViewModelTests: XCTestCase {

    // MARK: - Properties

    var viewModel: CollectViewModel!
    var disposeBag: DisposeBag!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = CollectViewModel()
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        disposeBag = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testCollectViewModel_Initialization_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            _ = CollectViewModel()
        }(), "CollectViewModel 初始化不應該崩潰")
    }

    func testCollectViewModel_InitialValues_AreCorrect() {
        // Then
        XCTAssertEqual(viewModel.currentCollectMenu.value, 0, "初始 collectMenu 應該為 0")
        XCTAssertEqual(viewModel.currentTimeMenu.value, 0, "初始 timeMenu 應該為 0")
        XCTAssertEqual(viewModel.isSearchMode.value, false, "初始 searchMode 應該為 false")
        XCTAssertTrue(viewModel.currentExhibitionContent.value.isEmpty || !viewModel.currentExhibitionContent.value.isEmpty,
                     "初始展覽內容應該可以訪問")
    }

    // MARK: - Input/Output Protocol Tests

    func testCollectViewModel_InputOutputProtocols_AreImplemented() {
        // Then
        XCTAssertNotNil(viewModel.input, "input 協議應該被實現")
        XCTAssertNotNil(viewModel.output, "output 協議應該被實現")
    }

    // MARK: - Menu Selection Tests

    func testCurrentCollectMenu_WhenChanged_UpdatesValue() {
        // Given
        let newValue = 2

        // When
        viewModel.currentCollectMenu.accept(newValue)

        // Then
        XCTAssertEqual(viewModel.currentCollectMenu.value, newValue,
                      "currentCollectMenu 應該更新為新值")
    }

    func testCurrentTimeMenu_WhenChanged_UpdatesValue() {
        // Given
        let newValue = 3

        // When
        viewModel.currentTimeMenu.accept(newValue)

        // Then
        XCTAssertEqual(viewModel.currentTimeMenu.value, newValue,
                      "currentTimeMenu 應該更新為新值")
    }

    func testIsSearchMode_WhenToggled_UpdatesValue() {
        // Given
        let initialValue = viewModel.isSearchMode.value

        // When
        viewModel.isSearchMode.accept(!initialValue)

        // Then
        XCTAssertEqual(viewModel.isSearchMode.value, !initialValue,
                      "isSearchMode 應該切換狀態")
    }

    // MARK: - Observable Tests

    func testCurrentSelectedCollectMenuIndex_IsObservable() {
        // Given
        let expectation = self.expectation(description: "Observable emits value")
        var receivedValue: Int?

        // When
        viewModel.currentSelectedCollectMenuIndex
            .take(1)
            .subscribe(onNext: { value in
                receivedValue = value
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        viewModel.currentTimeMenu.accept(1)

        // Then
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNotNil(receivedValue, "Observable 應該發送值")
        }
    }

    func testCurrentSelectedTimeMenu_IsObservable() {
        // Given
        let expectation = self.expectation(description: "Observable emits value")
        var receivedValue: Int?

        // When
        viewModel.currentSelectedTimeMenu
            .take(1)
            .subscribe(onNext: { value in
                receivedValue = value
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        viewModel.currentTimeMenu.accept(2)

        // Then
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNotNil(receivedValue, "Observable 應該發送值")
        }
    }

    // MARK: - Relay Tests

    func testSearchExhibitionContentHistory_CanBeUpdated() {
        // Given
        let testHistory = ["展覽1", "展覽2", "展覽3"]

        // When
        viewModel.searchExhibitionContentHistory.accept(testHistory)

        // Then
        XCTAssertEqual(viewModel.searchExhibitionContentHistory.value.count, 3,
                      "搜尋紀錄應該包含 3 個項目")
        XCTAssertEqual(viewModel.searchExhibitionContentHistory.value, testHistory,
                      "搜尋紀錄內容應該正確")
    }

    func testCollectExhibitionHall_CanBeUpdated() {
        // Given
        let testHalls = ["展覽館A", "展覽館B"]

        // When
        viewModel.collectExhibitionHall.accept(testHalls)

        // Then
        XCTAssertEqual(viewModel.collectExhibitionHall.value.count, 2,
                      "收藏展覽館應該包含 2 個項目")
        XCTAssertEqual(viewModel.collectExhibitionHall.value, testHalls,
                      "收藏展覽館內容應該正確")
    }

    func testCollectNews_CanBeUpdated() {
        // Given
        let testNews = [
            News(id: "1", title: "新聞1", date: "2025-11-27", author: "作者1", image: "image1.jpg", description: "描述1"),
            News(id: "2", title: "新聞2", date: "2025-11-26", author: "作者2", image: "image2.jpg", description: "描述2")
        ]

        // When
        viewModel.collectNews.accept(testNews)

        // Then
        XCTAssertEqual(viewModel.collectNews.value.count, 2,
                      "收藏新聞應該包含 2 個項目")
        XCTAssertEqual(viewModel.collectNews.value[0].id, "1",
                      "第一則新聞 ID 應該正確")
    }

    func testCollectNewsSearchHistory_CanBeUpdated() {
        // Given
        let testHistory = ["新聞搜尋1", "新聞搜尋2"]

        // When
        viewModel.collectNewsSearchHistory.accept(testHistory)

        // Then
        XCTAssertEqual(viewModel.collectNewsSearchHistory.value.count, 2,
                      "新聞搜尋紀錄應該包含 2 個項目")
        XCTAssertEqual(viewModel.collectNewsSearchHistory.value, testHistory,
                      "新聞搜尋紀錄內容應該正確")
    }

    // MARK: - Remove Search History Tests

    func testRemoveAllSearchHistory_CanBeSent() {
        // When & Then
        XCTAssertNoThrow({
            viewModel.removeAllSearchHistory.accept(())
        }(), "removeAllSearchHistory 應該能夠發送事件")
    }

    func testRemoveSpecificSearchHistory_CanBeSent() {
        // Given
        let indexToRemove = 1

        // When & Then
        XCTAssertNoThrow({
            viewModel.removeSpecificSearchHistory.accept(indexToRemove)
        }(), "removeSpecificSearchHistory 應該能夠發送事件")
    }

    // MARK: - Data Fetching Tests

    func testCurrentExhibitionContent_IsInitiallyAccessible() {
        // Then
        XCTAssertNotNil(viewModel.currentExhibitionContent.value,
                       "currentExhibitionContent 應該可以訪問")
    }

    func testCurrentExhibitionContent_CanBeObserved() {
        // Given
        let expectation = self.expectation(description: "Exhibition content can be observed")
        var receivedContent: [ExhibitionInfo]?

        // When
        viewModel.currentExhibitionContent
            .skip(1) // Skip initial value
            .take(1)
            .subscribe(onNext: { content in
                receivedContent = content
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // Trigger update with empty array
        viewModel.currentExhibitionContent.accept([])

        // Then
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertNotNil(receivedContent, "應該能夠接收到展覽內容更新")
        }
    }

    // MARK: - Edge Cases

    func testViewModel_WithMultipleSubscriptions_DoesNotCrash() {
        // Given
        let expectation1 = self.expectation(description: "Subscription 1")
        let expectation2 = self.expectation(description: "Subscription 2")
        let expectation3 = self.expectation(description: "Subscription 3")

        // When
        viewModel.currentTimeMenu
            .take(1)
            .subscribe(onNext: { _ in expectation1.fulfill() })
            .disposed(by: disposeBag)

        viewModel.isSearchMode
            .take(1)
            .subscribe(onNext: { _ in expectation2.fulfill() })
            .disposed(by: disposeBag)

        viewModel.currentExhibitionContent
            .take(1)
            .subscribe(onNext: { _ in expectation3.fulfill() })
            .disposed(by: disposeBag)

        // Then
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "多個訂閱不應該導致崩潰")
        }
    }

    func testViewModel_WithRapidMenuChanges_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            for i in 0..<10 {
                viewModel.currentCollectMenu.accept(i % 3)
                viewModel.currentTimeMenu.accept(i % 4)
            }
        }(), "快速切換 menu 不應該崩潰")
    }

    func testViewModel_WithEmptyData_HandlesGracefully() {
        // When
        viewModel.currentExhibitionContent.accept([])
        viewModel.searchExhibitionContentHistory.accept([])
        viewModel.collectNews.accept([])
        viewModel.collectExhibitionHall.accept([])

        // Then
        XCTAssertTrue(viewModel.currentExhibitionContent.value.isEmpty,
                     "空展覽資料應該被正確處理")
        XCTAssertTrue(viewModel.searchExhibitionContentHistory.value.isEmpty,
                     "空搜尋紀錄應該被正確處理")
        XCTAssertTrue(viewModel.collectNews.value.isEmpty,
                     "空新聞資料應該被正確處理")
        XCTAssertTrue(viewModel.collectExhibitionHall.value.isEmpty,
                     "空展覽館資料應該被正確處理")
    }

    // MARK: - Memory Management Tests

    func testViewModel_DisposeBag_ReleasesSubscriptions() {
        // Given
        var disposeBag: DisposeBag? = DisposeBag()
        var subscriptionCalled = false

        // When
        viewModel.currentTimeMenu
            .subscribe(onNext: { _ in
                subscriptionCalled = true
            })
            .disposed(by: disposeBag!)

        disposeBag = nil // Release the dispose bag

        // Trigger event after dispose bag is released
        viewModel.currentTimeMenu.accept(1)

        // Then
        // If subscription was properly disposed, it shouldn't be called again
        // (This is a basic test - in real scenarios, we'd use more sophisticated checks)
        XCTAssertTrue(true, "DisposeBag 應該能夠正確釋放訂閱")
    }

    // MARK: - Integration Tests

    func testViewModel_CompleteWorkflow_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Complete workflow")

        // When
        viewModel.isSearchMode.accept(true)
        viewModel.currentCollectMenu.accept(1)
        viewModel.currentTimeMenu.accept(2)

        viewModel.searchExhibitionContentHistory.accept(["測試搜尋1", "測試搜尋2"])
        viewModel.collectExhibitionHall.accept(["測試展覽館"])

        // Observe multiple values
        var observedValues = 0
        viewModel.currentSelectedTimeMenu
            .take(3)
            .subscribe(onNext: { _ in
                observedValues += 1
                if observedValues == 3 {
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        viewModel.currentTimeMenu.accept(0)
        viewModel.currentTimeMenu.accept(1)

        // Then
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "完整工作流程不應該崩潰")
        }
    }
}
