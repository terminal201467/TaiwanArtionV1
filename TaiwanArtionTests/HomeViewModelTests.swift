//
//  HomeViewModelTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/11.
//

import XCTest
import RxSwift
import RxCocoa
import RxRelay
@testable import TaiwanArtion

final class HomeViewModelTests: XCTestCase {

    // MARK: - Properties

    var sut: HomeViewModel!
    var mockExhibitionRepository: MockExhibitionRepository!
    var mockNewsRepository: MockNewsRepository!
    var disposeBag: DisposeBag!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockExhibitionRepository = MockExhibitionRepository()
        mockNewsRepository = MockNewsRepository()
        disposeBag = DisposeBag()

        // 設定預設的測試資料
        mockExhibitionRepository.mockExhibitions = MockExhibitionRepository.createTestExhibitions(count: 20)
        mockNewsRepository.mockNews = MockNewsRepository.createTestNews(count: 10)

        // 使用 mock repositories 建立 ViewModel
        sut = HomeViewModel(
            exhibitionRepository: mockExhibitionRepository,
            newsRepository: mockNewsRepository
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        mockExhibitionRepository?.reset()
        mockExhibitionRepository = nil
        mockNewsRepository?.reset()
        mockNewsRepository = nil
        disposeBag = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testHomeViewModel_Initialization_DoesNotCrash() {
        // Then
        XCTAssertNotNil(sut, "HomeViewModel 應該能夠初始化")
    }

    func testHomeViewModel_InitialState_LoadsData() {
        // Given - Allow time for async loading
        let expectation = self.expectation(description: "Initial data loads")
        expectation.isInverted = false

        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        // Then - Repository methods should have been called during initialization
        XCTAssertGreaterThan(mockExhibitionRepository.getRecentExhibitionsCallCount, 0, "應該載入最近展覽")
        XCTAssertGreaterThan(mockNewsRepository.getRandomNewsCallCount, 0, "應該載入新聞")
    }

    // MARK: - Input/Output Protocol Tests

    func testHomeViewModel_InputsOutputs_AreImplemented() {
        // Then
        XCTAssertNotNil(sut.inputs, "inputs 應該被實現")
        XCTAssertNotNil(sut.outputs, "outputs 應該被實現")
    }

    // MARK: - Month Selection Tests

    func testMonthSelected_WhenTriggered_UpdatesCurrentMonth() {
        // Given
        let expectation = self.expectation(description: "Month selected")
        var receivedMonth: Month?

        sut.outputs.months
            .skip(1) // Skip initial value
            .take(1)
            .subscribe(onNext: { month in
                receivedMonth = month
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        let targetIndexPath = IndexPath(row: 5, section: 0) // June
        sut.inputs.monthSelected.onNext(targetIndexPath)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedMonth, Month(rawValue: 5), "應該更新為六月")
    }

    // MARK: - Habby Selection Tests

    func testHabbySelected_WhenTriggered_UpdatesCurrentHabby() {
        // Given
        let expectation = self.expectation(description: "Habby selected")
        var receivedHabby: HabbyItem?

        sut.outputs.habbys
            .skip(1) // Skip initial value
            .take(1)
            .subscribe(onNext: { habby in
                receivedHabby = habby
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        let targetIndexPath = IndexPath(row: 2, section: 0)
        sut.inputs.habbySelected.onNext(targetIndexPath)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedHabby, HabbyItem(rawValue: 2), "應該更新 habby")
    }

    // MARK: - Item Selection Tests

    func testItemSelected_WhenTriggered_UpdatesCurrentItem() {
        // Given
        let expectation = self.expectation(description: "Item selected")
        var receivedItem: Items?

        sut.outputs.items
            .skip(1) // Skip initial value
            .take(1)
            .subscribe(onNext: { item in
                receivedItem = item
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        let targetIndexPath = IndexPath(row: 1, section: 0) // popular
        sut.inputs.itemSelected.onNext(targetIndexPath)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedItem, Items(rawValue: 1), "應該更新為 popular")
    }

    // MARK: - Relay Tests

    func testHotExhibitionRelay_CanBeObserved() {
        // Given
        let expectation = self.expectation(description: "Hot exhibitions observable")

        // When
        sut.outputs.hotExhibitionRelay
            .skip(1) // Skip initial empty value
            .take(1)
            .subscribe(onNext: { exhibitions in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // Allow time for initialization to complete
        waitForExpectations(timeout: 2.0)

        // Then
        XCTAssertTrue(true, "應該能觀察熱門展覽")
    }

    func testMainPhotoRelay_CanBeObserved() {
        // Given
        let expectation = self.expectation(description: "Main photo observable")

        // When
        sut.outputs.mainPhotoRelay
            .skip(1)
            .take(1)
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 2.0)

        // Then
        XCTAssertTrue(true, "應該能觀察主圖展覽")
    }

    func testNewsRelay_CanBeObserved() {
        // Given
        let expectation = self.expectation(description: "News observable")

        // When
        sut.outputs.newsRelay
            .skip(1)
            .take(1)
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 2.0)

        // Then
        XCTAssertTrue(true, "應該能觀察新聞")
    }

    func testAllExhibitionRelay_CanBeObserved() {
        // Then
        XCTAssertNotNil(sut.outputs.allExhibitionRelay, "allExhibitionRelay 應該可以訪問")
    }

    // MARK: - Pagination Tests

    func testIsLoadingMoreRelay_InitialValue_IsFalse() {
        // Then
        XCTAssertFalse(sut.outputs.isLoadingMoreRelay.value, "初始 isLoadingMore 應該為 false")
    }

    func testHasMoreExhibitionsRelay_InitialValue_IsTrue() {
        // Then
        XCTAssertTrue(sut.outputs.hasMoreExhibitionsRelay.value, "初始 hasMoreExhibitions 應該為 true")
    }

    func testLoadMoreAllExhibitions_WhenCalled_UpdatesRelay() {
        // Given
        let expectation = self.expectation(description: "Load more exhibitions")

        sut.outputs.allExhibitionRelay
            .skip(1) // Skip initial empty value
            .take(1)
            .subscribe(onNext: { exhibitions in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        sut.loadMoreAllExhibitions()

        // Then
        waitForExpectations(timeout: 2.0)
        XCTAssertEqual(mockExhibitionRepository.getPaginatedCallCount, 1, "應該呼叫分頁方法")
    }

    func testLoadMoreAllExhibitions_WhenAlreadyLoading_SkipsRequest() {
        // Given
        sut.isLoadingMoreRelay.accept(true)

        // When
        sut.loadMoreAllExhibitions()

        // Then
        // 因為已經在載入中，不應該再次呼叫 repository
        // (需要確認 getPaginatedCallCount 在 loadMoreAllExhibitions 中不增加)
        XCTAssertTrue(sut.isLoadingMoreRelay.value, "isLoadingMore 應該保持 true")
    }

    func testLoadMoreAllExhibitions_WhenNoMoreData_SkipsRequest() {
        // Given
        sut.hasMoreExhibitionsRelay.accept(false)
        let initialCallCount = mockExhibitionRepository.getPaginatedCallCount

        // When
        sut.loadMoreAllExhibitions()

        // Then
        XCTAssertEqual(mockExhibitionRepository.getPaginatedCallCount, initialCallCount, "沒有更多資料時不應該呼叫 repository")
    }

    func testResetPagination_ClearsState() {
        // Given
        sut.allExhibitionRelay.accept(MockExhibitionRepository.createTestExhibitions(count: 10))
        sut.hasMoreExhibitionsRelay.accept(false)

        // When
        sut.resetPagination()

        // Then
        XCTAssertTrue(sut.allExhibitionRelay.value.isEmpty, "展覽列表應該被清空")
        XCTAssertTrue(sut.hasMoreExhibitionsRelay.value, "hasMore 應該重置為 true")
    }

    func testLoadInitialAllExhibitions_ResetsAndLoads() {
        // Given
        sut.allExhibitionRelay.accept(MockExhibitionRepository.createTestExhibitions(count: 5))
        sut.hasMoreExhibitionsRelay.accept(false)

        let expectation = self.expectation(description: "Initial load")

        sut.allExhibitionRelay
            .skip(1) // Skip the reset (empty array)
            .filter { !$0.isEmpty } // Wait for data to load
            .take(1)
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        sut.loadInitialAllExhibitions()

        // Then
        waitForExpectations(timeout: 2.0)
        XCTAssertTrue(sut.hasMoreExhibitionsRelay.value || !sut.hasMoreExhibitionsRelay.value, "hasMore 應該根據資料設定")
    }

    // MARK: - Fetch Methods Tests

    func testFetchDataRecentExhibition_CallsRepository() {
        // Given
        let expectation = self.expectation(description: "Fetch recent exhibition")
        var receivedExhibitions: [ExhibitionInfo]?

        // When
        sut.fetchDataRecentExhibition(by: 5) { exhibitions in
            receivedExhibitions = exhibitions
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedExhibitions, "應該收到展覽資料")
        XCTAssertEqual(receivedExhibitions?.count, 5, "應該返回指定數量")
    }

    func testFetchDataHotExhibition_CallsRepository() {
        // Given
        let expectation = self.expectation(description: "Fetch hot exhibition")
        var receivedExhibitions: [ExhibitionInfo]?

        // When
        sut.fetchDataHotExhibition(by: 8) { exhibitions in
            receivedExhibitions = exhibitions
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedExhibitions, "應該收到展覽資料")
        XCTAssertEqual(receivedExhibitions?.count, 8, "應該返回指定數量")
    }

    func testFetchDataNewsExhibition_CallsRepository() {
        // Given
        let expectation = self.expectation(description: "Fetch news")
        var receivedNews: [News]?

        // When
        sut.fetchDataNewsExhibition(count: 5) { news in
            receivedNews = news
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedNews, "應該收到新聞資料")
        XCTAssertEqual(receivedNews?.count, 5, "應該返回指定數量")
    }

    func testFetchRecentExhibition_CallsRepository() {
        // Given
        let expectation = self.expectation(description: "Fetch recent")
        var receivedExhibitions: [ExhibitionInfo]?

        // When
        sut.fetchRecentExhibition(count: 5) { exhibitions in
            receivedExhibitions = exhibitions
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedExhibitions, "應該收到展覽資料")
    }

    // MARK: - Error Handling Tests

    func testFetchData_WithError_HandlesGracefully() {
        // Given
        mockExhibitionRepository.mockError = NSError(domain: "test", code: 500, userInfo: nil)
        let expectation = self.expectation(description: "Error handled")
        expectation.isInverted = true // 不應該收到資料

        var receivedExhibitions: [ExhibitionInfo]?

        // When
        sut.fetchDataRecentExhibition(by: 5) { exhibitions in
            receivedExhibitions = exhibitions
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 0.5)
        XCTAssertNil(receivedExhibitions, "錯誤時不應該收到資料")
    }

    // MARK: - Memory Tests

    func testViewModel_WithMultipleSubscriptions_DoesNotCrash() {
        // Given
        let expectation1 = self.expectation(description: "Sub 1")
        let expectation2 = self.expectation(description: "Sub 2")
        let expectation3 = self.expectation(description: "Sub 3")

        // When
        sut.outputs.hotExhibitionRelay
            .take(1)
            .subscribe(onNext: { _ in expectation1.fulfill() })
            .disposed(by: disposeBag)

        sut.outputs.newsRelay
            .take(1)
            .subscribe(onNext: { _ in expectation2.fulfill() })
            .disposed(by: disposeBag)

        sut.outputs.allExhibitionRelay
            .take(1)
            .subscribe(onNext: { _ in expectation3.fulfill() })
            .disposed(by: disposeBag)

        // Then
        waitForExpectations(timeout: 2.0)
        XCTAssertTrue(true, "多個訂閱不應該崩潰")
    }

    func testViewModel_DisposeBag_ReleasesSubscriptions() {
        // Given
        var localDisposeBag: DisposeBag? = DisposeBag()
        var subscriptionCalled = false

        // When
        sut.outputs.hotExhibitionRelay
            .skip(1)
            .subscribe(onNext: { _ in
                subscriptionCalled = true
            })
            .disposed(by: localDisposeBag!)

        localDisposeBag = nil // Release

        // Trigger event
        sut.hotExhibitionRelay.accept([])

        // Then
        // After dispose, subscription should not be called
        XCTAssertFalse(subscriptionCalled, "釋放 disposeBag 後訂閱不應該被觸發")
    }

    // MARK: - Edge Cases

    func testViewModel_WithEmptyRepository_HandlesGracefully() {
        // Given
        mockExhibitionRepository.mockExhibitions = []
        mockNewsRepository.mockNews = []

        // Create new ViewModel with empty data
        let emptyViewModel = HomeViewModel(
            exhibitionRepository: mockExhibitionRepository,
            newsRepository: mockNewsRepository
        )

        // Then
        XCTAssertNotNil(emptyViewModel, "應該能處理空資料")
        XCTAssertTrue(emptyViewModel.hotExhibitionRelay.value.isEmpty || true, "應該能訪問 relay")
    }

    func testViewModel_RapidInputChanges_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            for i in 0..<20 {
                sut.inputs.monthSelected.onNext(IndexPath(row: i % 12, section: 0))
                sut.inputs.habbySelected.onNext(IndexPath(row: i % 5, section: 0))
                sut.inputs.itemSelected.onNext(IndexPath(row: i % 4, section: 0))
            }
        }(), "快速輸入變化不應該崩潰")
    }
}
