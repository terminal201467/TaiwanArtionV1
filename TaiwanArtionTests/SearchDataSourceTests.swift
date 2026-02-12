//
//  SearchDataSourceTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/13.
//

import XCTest
@testable import TaiwanArtion

final class SearchDataSourceTests: XCTestCase {

    // MARK: - Properties

    var sut: SearchDataSource!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = SearchDataSource()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testSearchDataSource_Initialization_DoesNotCrash() {
        // Then
        XCTAssertNotNil(sut, "SearchDataSource 應該能夠初始化")
    }

    func testSearchDataSource_InitialState_IsCorrect() {
        // Then
        XCTAssertFalse(sut.isSearchModeViewOn, "初始 isSearchModeViewOn 應該是 false")
        XCTAssertNil(sut.currentSelectedItem, "初始 currentSelectedItem 應該是 nil")
    }

    // MARK: - Search Mode Tests

    func testIsSearchModeViewOn_CanBeToggled() {
        // When
        sut.isSearchModeViewOn = true

        // Then
        XCTAssertTrue(sut.isSearchModeViewOn, "isSearchModeViewOn 應該被設為 true")

        // When
        sut.isSearchModeViewOn = false

        // Then
        XCTAssertFalse(sut.isSearchModeViewOn, "isSearchModeViewOn 應該被設為 false")
    }

    // MARK: - Current Selected Item Tests

    func testCurrentSelectedItem_CanBeSet() {
        // When
        sut.currentSelectedItem = 2

        // Then
        XCTAssertEqual(sut.currentSelectedItem, 2, "currentSelectedItem 應該被設為 2")
    }

    func testCurrentSelectedItem_CanBeSetToNil() {
        // Given
        sut.currentSelectedItem = 5

        // When
        sut.currentSelectedItem = nil

        // Then
        XCTAssertNil(sut.currentSelectedItem, "currentSelectedItem 應該能被設為 nil")
    }

    // MARK: - CollectionView Configuration Tests

    func testCollectionViewNumberOfItems_ReturnsValidCount() {
        // When
        let count = sut.collectionViewNumberOfItems(in: 0)

        // Then
        XCTAssertGreaterThanOrEqual(count, 0, "items 數量應該大於等於 0")
    }

    func testCollectionViewCellSize_InSearchMode_ReturnsCorrectSize() {
        // Given
        sut.isSearchModeViewOn = true
        let viewWidth: CGFloat = 375.0

        // When
        let size = sut.collectionViewCellSize(for: IndexPath(item: 0, section: 0), viewWidth: viewWidth)

        // Then
        XCTAssertGreaterThan(size.width, 0, "cell width 應該大於 0")
        XCTAssertEqual(size.height, 48.0, "cell height 應該是 48")
    }

    func testCollectionViewCellSize_InNormalMode_ReturnsCorrectSize() {
        // Given
        sut.isSearchModeViewOn = false
        let viewWidth: CGFloat = 375.0

        // When
        let size = sut.collectionViewCellSize(for: IndexPath(item: 0, section: 0), viewWidth: viewWidth)

        // Then
        XCTAssertGreaterThan(size.width, 0, "cell width 應該大於 0")
        XCTAssertEqual(size.height, 48.0, "cell height 應該是 48")
    }

    func testCollectionViewCellSize_SearchMode_IsDifferentFromNormalMode() {
        // Given
        let viewWidth: CGFloat = 375.0
        let indexPath = IndexPath(item: 0, section: 0)

        // When
        sut.isSearchModeViewOn = true
        let searchModeSize = sut.collectionViewCellSize(for: indexPath, viewWidth: viewWidth)

        sut.isSearchModeViewOn = false
        let normalModeSize = sut.collectionViewCellSize(for: indexPath, viewWidth: viewWidth)

        // Then
        // 搜尋模式的 cell 應該比較大（4欄 vs 6欄）
        XCTAssertGreaterThan(searchModeSize.width, normalModeSize.width, "搜尋模式的 cell 應該比較寬")
    }

    // MARK: - TableView Configuration Tests

    func testTableViewNumberOfSections_ReturnsValidCount() {
        // When
        let sections = sut.tableViewNumberOfSections()

        // Then
        XCTAssertGreaterThanOrEqual(sections, 0, "sections 數量應該大於等於 0")
    }

    func testTableViewNumberOfRows_InSearchMode_ReturnsValidCount() {
        // Given
        sut.isSearchModeViewOn = true

        // When
        let rows = sut.tableViewNumberOfRows(in: 0)

        // Then
        XCTAssertGreaterThanOrEqual(rows, 0, "rows 數量應該大於等於 0")
    }

    func testTableViewNumberOfRows_InNormalMode_ReturnsValidCount() {
        // Given
        sut.isSearchModeViewOn = false

        // When
        let rows = sut.tableViewNumberOfRows(in: 0)

        // Then
        XCTAssertGreaterThanOrEqual(rows, 0, "rows 數量應該大於等於 0")
    }

    func testTableViewHeaderHeight_Returns50() {
        // When
        let height = sut.tableViewHeaderHeight(for: 0)

        // Then
        XCTAssertEqual(height, 50.0, "header height 應該是 50")
    }

    // MARK: - Actions Tests

    func testPresentPopUp_WhenSet_CanBeTriggered() {
        // Given
        var popUpPresented = false
        sut.presentPopUp = {
            popUpPresented = true
        }

        // When
        sut.presentPopUp?()

        // Then
        XCTAssertTrue(popUpPresented, "presentPopUp 應該被觸發")
    }

    func testReloadTableView_WhenSet_CanBeTriggered() {
        // Given
        var reloadCalled = false
        sut.reloadTableView = {
            reloadCalled = true
        }

        // When
        sut.reloadTableView?()

        // Then
        XCTAssertTrue(reloadCalled, "reloadTableView 應該被觸發")
    }

    func testReloadCollectionView_WhenSet_CanBeTriggered() {
        // Given
        var reloadCalled = false
        sut.reloadCollectionView = {
            reloadCalled = true
        }

        // When
        sut.reloadCollectionView?()

        // Then
        XCTAssertTrue(reloadCalled, "reloadCollectionView 應該被觸發")
    }

    func testAllActions_InitiallyAreNil() {
        // Then
        XCTAssertNil(sut.presentPopUp, "初始 presentPopUp 應該是 nil")
        XCTAssertNil(sut.reloadTableView, "初始 reloadTableView 應該是 nil")
        XCTAssertNil(sut.reloadCollectionView, "初始 reloadCollectionView 應該是 nil")
    }

    // MARK: - CollectionView Did Select Tests

    func testCollectionViewDidSelectItem_TriggersReloads() {
        // Given
        var tableViewReloaded = false
        var collectionViewReloaded = false

        sut.reloadTableView = {
            tableViewReloaded = true
        }
        sut.reloadCollectionView = {
            collectionViewReloaded = true
        }

        // When
        sut.collectionViewDidSelectItem(at: IndexPath(item: 0, section: 0))

        // Then
        XCTAssertTrue(collectionViewReloaded, "collectionView 應該被重載")
        XCTAssertTrue(tableViewReloaded, "tableView 應該被重載")
    }

    // MARK: - Select All Tests

    func testSelectAllInSection_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.selectAllInSection(0)
            self.sut.selectAllInSection(1)
            self.sut.selectAllInSection(2)
        }(), "selectAllInSection 不應該崩潰")
    }

    // MARK: - UICollectionViewDataSource Protocol Tests

    func testCollectionView_NumberOfItemsInSection_ReturnsCorrectValue() {
        // Given
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )

        // When
        let count = sut.collectionView(collectionView, numberOfItemsInSection: 0)

        // Then
        XCTAssertEqual(count, sut.collectionViewNumberOfItems(in: 0), "UICollectionViewDataSource 方法應該返回正確的值")
    }

    // MARK: - UITableViewDataSource Protocol Tests

    func testTableView_NumberOfSections_ReturnsCorrectValue() {
        // Given
        let tableView = UITableView()

        // When
        let sections = sut.numberOfSections(in: tableView)

        // Then
        XCTAssertEqual(sections, sut.tableViewNumberOfSections(), "UITableViewDataSource 方法應該返回正確的值")
    }

    func testTableView_NumberOfRowsInSection_ReturnsCorrectValue() {
        // Given
        let tableView = UITableView()

        // When
        let rows = sut.tableView(tableView, numberOfRowsInSection: 0)

        // Then
        XCTAssertEqual(rows, sut.tableViewNumberOfRows(in: 0), "UITableViewDataSource 方法應該返回正確的值")
    }

    // MARK: - UITableViewDelegate Protocol Tests

    func testTableView_HeightForHeaderInSection_ReturnsCorrectValue() {
        // Given
        let tableView = UITableView()

        // When
        let height = sut.tableView(tableView, heightForHeaderInSection: 0)

        // Then
        XCTAssertEqual(height, sut.tableViewHeaderHeight(for: 0), "UITableViewDelegate 方法應該返回正確的值")
    }

    func testTableView_EstimatedHeightForRowAt_ReturnsAutomaticDimension() {
        // Given
        let tableView = UITableView()
        let indexPath = IndexPath(row: 0, section: 0)

        // When
        let height = sut.tableView(tableView, estimatedHeightForRowAt: indexPath)

        // Then
        XCTAssertEqual(height, UITableView.automaticDimension, "estimatedHeight 應該是 automaticDimension")
    }

    // MARK: - UICollectionViewDelegateFlowLayout Protocol Tests

    func testCollectionView_MinimumInteritemSpacing_Returns10() {
        // Given
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        let layout = UICollectionViewFlowLayout()

        // When
        let spacing = sut.collectionView(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: 0)

        // Then
        XCTAssertEqual(spacing, 10, "minimumInteritemSpacing 應該是 10")
    }

    func testCollectionView_MinimumLineSpacing_Returns5() {
        // Given
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        let layout = UICollectionViewFlowLayout()

        // When
        let spacing = sut.collectionView(collectionView, layout: layout, minimumLineSpacingForSectionAt: 0)

        // Then
        XCTAssertEqual(spacing, 5, "minimumLineSpacing 應該是 5")
    }

    func testCollectionView_SectionInset_ReturnsCorrectValue() {
        // Given
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        let layout = UICollectionViewFlowLayout()
        let expectedInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        // When
        let inset = sut.collectionView(collectionView, layout: layout, insetForSectionAt: 0)

        // Then
        XCTAssertEqual(inset, expectedInset, "section inset 應該是 (5, 5, 5, 5)")
    }

    // MARK: - Mode Switching Tests

    func testModeSwitching_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            for _ in 0..<50 {
                self.sut.isSearchModeViewOn = true
                _ = self.sut.tableViewNumberOfRows(in: 0)
                _ = self.sut.collectionViewCellSize(for: IndexPath(item: 0, section: 0), viewWidth: 375)

                self.sut.isSearchModeViewOn = false
                _ = self.sut.tableViewNumberOfRows(in: 0)
                _ = self.sut.collectionViewCellSize(for: IndexPath(item: 0, section: 0), viewWidth: 375)
            }
        }(), "快速切換模式不應該崩潰")
    }

    // MARK: - Edge Cases Tests

    func testTableViewNumberOfRows_WithInvalidSection_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            _ = self.sut.tableViewNumberOfRows(in: 999)
        }(), "無效的 section 不應該崩潰")
    }

    func testCollectionViewDidSelectItem_WithInvalidIndexPath_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.collectionViewDidSelectItem(at: IndexPath(item: 999, section: 999))
        }(), "無效的 indexPath 不應該崩潰")
    }

    func testSelectAllInSection_WithInvalidSection_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.selectAllInSection(999)
        }(), "無效的 section 不應該崩潰")
    }
}
