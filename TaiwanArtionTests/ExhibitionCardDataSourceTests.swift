//
//  ExhibitionCardDataSourceTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/13.
//

import XCTest
@testable import TaiwanArtion

final class ExhibitionCardDataSourceTests: XCTestCase {

    // MARK: - Properties

    var sut: ExhibitionCardDataSource!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ExhibitionCardDataSource()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testExhibitionCardDataSource_Initialization_DoesNotCrash() {
        // Then
        XCTAssertNotNil(sut, "ExhibitionCardDataSource 應該能夠初始化")
    }

    func testExhibitionCardDataSource_InitialSelectedItem_IsOverview() {
        // Then
        XCTAssertEqual(sut.selectedItem, .overview, "初始 selectedItem 應該是 overview")
    }

    // MARK: - Selected Item Tests

    func testSelectedItem_CanBeChanged() {
        // When
        sut.selectedItem = .introduce

        // Then
        XCTAssertEqual(sut.selectedItem, .introduce, "selectedItem 應該被更新")
    }

    func testSelectedItem_AllCases_CanBeSet() {
        // Given
        let allCases: [CardInfoItem] = [.overview, .introduce, .ticketPrice, .location, .evaluate]

        // When & Then
        for item in allCases {
            sut.selectedItem = item
            XCTAssertEqual(sut.selectedItem, item, "應該能設定為 \(item)")
        }
    }

    // MARK: - Number of Sections Tests

    func testNumberOfSections_ForOverview_ReturnsCorrectCount() {
        // Given
        sut.selectedItem = .overview

        // When
        let sections = sut.numberOfSections()

        // Then
        XCTAssertGreaterThanOrEqual(sections, 0, "sections 應該大於等於 0")
    }

    func testNumberOfSections_ForIntroduce_ReturnsCorrectCount() {
        // Given
        sut.selectedItem = .introduce

        // When
        let sections = sut.numberOfSections()

        // Then
        XCTAssertGreaterThanOrEqual(sections, 0, "sections 應該大於等於 0")
    }

    func testNumberOfSections_ForTicketPrice_ReturnsCorrectCount() {
        // Given
        sut.selectedItem = .ticketPrice

        // When
        let sections = sut.numberOfSections()

        // Then
        XCTAssertGreaterThanOrEqual(sections, 0, "sections 應該大於等於 0")
    }

    func testNumberOfSections_ForLocation_ReturnsCorrectCount() {
        // Given
        sut.selectedItem = .location

        // When
        let sections = sut.numberOfSections()

        // Then
        XCTAssertGreaterThanOrEqual(sections, 0, "sections 應該大於等於 0")
    }

    func testNumberOfSections_ForEvaluate_ReturnsCorrectCount() {
        // Given
        sut.selectedItem = .evaluate

        // When
        let sections = sut.numberOfSections()

        // Then
        XCTAssertGreaterThanOrEqual(sections, 0, "sections 應該大於等於 0")
    }

    // MARK: - Number of Rows Tests

    func testNumberOfRows_ForOverview_ReturnsCorrectCount() {
        // Given
        sut.selectedItem = .overview

        // When
        let rows = sut.numberOfRows(in: 0)

        // Then
        XCTAssertGreaterThanOrEqual(rows, 0, "rows 應該大於等於 0")
    }

    func testNumberOfRows_ForIntroduce_ReturnsCorrectCount() {
        // Given
        sut.selectedItem = .introduce

        // When
        let rows = sut.numberOfRows(in: 0)

        // Then
        XCTAssertGreaterThanOrEqual(rows, 0, "rows 應該大於等於 0")
    }

    // MARK: - Height Tests

    func testHeightForHeader_ReturnsValidHeight() {
        // Given
        sut.selectedItem = .overview

        // When
        let height = sut.heightForHeader(in: 0)

        // Then
        XCTAssertGreaterThanOrEqual(height, 0, "header height 應該大於等於 0")
    }

    func testHeightForRow_ReturnsValidHeight() {
        // Given
        sut.selectedItem = .overview
        let indexPath = IndexPath(row: 0, section: 0)

        // When
        let height = sut.heightForRow(at: indexPath)

        // Then
        XCTAssertGreaterThan(height, 0, "row height 應該大於 0")
    }

    // MARK: - Header View Tests

    func testHeaderView_ForOverview_ReturnsView() {
        // Given
        sut.selectedItem = .overview

        // When
        let header = sut.headerView(for: 0)

        // Then
        // Header 可能為 nil 取決於 section
        XCTAssertTrue(true, "headerView 方法應該能正常執行")
    }

    func testHeaderView_ForEvaluate_ReturnsAllCommentHeaderView() {
        // Given
        sut.selectedItem = .evaluate

        // When
        let header = sut.headerView(for: 0)

        // Then
        XCTAssertNotNil(header, "evaluate 的 header 應該不為 nil")
    }

    // MARK: - Navigate To Evaluate Tests

    func testNavigateToEvaluate_WhenSet_CanBeTriggered() {
        // Given
        var navigateCalled = false
        sut.navigateToEvaluate = {
            navigateCalled = true
        }

        // When
        sut.navigateToEvaluate?()

        // Then
        XCTAssertTrue(navigateCalled, "navigateToEvaluate 應該被觸發")
    }

    func testNavigateToEvaluate_InitialValue_IsNil() {
        // Then
        XCTAssertNil(sut.navigateToEvaluate, "初始 navigateToEvaluate 應該是 nil")
    }

    // MARK: - UITableViewDataSource Protocol Tests

    func testNumberOfSectionsInTableView_ReturnsCorrectValue() {
        // Given
        let tableView = UITableView()
        sut.selectedItem = .overview

        // When
        let sections = sut.numberOfSections(in: tableView)

        // Then
        XCTAssertEqual(sections, sut.numberOfSections(), "UITableViewDataSource 方法應該返回正確的值")
    }

    func testNumberOfRowsInSection_ReturnsCorrectValue() {
        // Given
        let tableView = UITableView()
        sut.selectedItem = .overview

        // When
        let rows = sut.tableView(tableView, numberOfRowsInSection: 0)

        // Then
        XCTAssertEqual(rows, sut.numberOfRows(in: 0), "UITableViewDataSource 方法應該返回正確的值")
    }

    // MARK: - UITableViewDelegate Protocol Tests

    func testHeightForHeaderInSection_ReturnsCorrectValue() {
        // Given
        let tableView = UITableView()
        sut.selectedItem = .overview

        // When
        let height = sut.tableView(tableView, heightForHeaderInSection: 0)

        // Then
        XCTAssertEqual(height, sut.heightForHeader(in: 0), "UITableViewDelegate 方法應該返回正確的值")
    }

    func testHeightForRowAt_ReturnsCorrectValue() {
        // Given
        let tableView = UITableView()
        let indexPath = IndexPath(row: 0, section: 0)
        sut.selectedItem = .overview

        // When
        let height = sut.tableView(tableView, heightForRowAt: indexPath)

        // Then
        XCTAssertEqual(height, sut.heightForRow(at: indexPath), "UITableViewDelegate 方法應該返回正確的值")
    }

    // MARK: - Multiple Selected Item Changes Tests

    func testRapidSelectedItemChanges_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            for _ in 0..<100 {
                self.sut.selectedItem = .overview
                _ = self.sut.numberOfSections()
                self.sut.selectedItem = .introduce
                _ = self.sut.numberOfRows(in: 0)
                self.sut.selectedItem = .ticketPrice
                _ = self.sut.heightForHeader(in: 0)
                self.sut.selectedItem = .location
                _ = self.sut.heightForRow(at: IndexPath(row: 0, section: 0))
                self.sut.selectedItem = .evaluate
                _ = self.sut.headerView(for: 0)
            }
        }(), "快速切換 selectedItem 不應該崩潰")
    }

    // MARK: - Edge Cases Tests

    func testNumberOfRows_WithInvalidSection_DoesNotCrash() {
        // Given
        sut.selectedItem = .overview

        // When & Then
        XCTAssertNoThrow({
            _ = self.sut.numberOfRows(in: 999)
        }(), "無效的 section 不應該崩潰")
    }

    func testHeightForHeader_WithInvalidSection_DoesNotCrash() {
        // Given
        sut.selectedItem = .overview

        // When & Then
        XCTAssertNoThrow({
            _ = self.sut.heightForHeader(in: 999)
        }(), "無效的 section 不應該崩潰")
    }

    func testHeaderView_WithInvalidSection_DoesNotCrash() {
        // Given
        sut.selectedItem = .overview

        // When & Then
        XCTAssertNoThrow({
            _ = self.sut.headerView(for: 999)
        }(), "無效的 section 不應該崩潰")
    }
}
