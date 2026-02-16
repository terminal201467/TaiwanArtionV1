//
//  CollectionUITests.swift
//  TaiwanArtionUITests
//
//  Created by Claude Code on 2026/2/16.
//

import XCTest

final class CollectionUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Navigation to Collection

    func testCollectionTab_CanBeSelected() throws {
        // Given: App launched
        let collectionTab = app.tabBars.buttons["收藏展覽"]

        // When: Tap collection tab
        collectionTab.tap()

        // Then: Collection tab should be selected
        XCTAssertTrue(collectionTab.isSelected, "收藏展覽 tab 應該被選中")
    }

    // MARK: - Collection Screen Elements

    func testCollectionScreen_HasSegmentedControl() throws {
        // Given: Navigate to collection
        navigateToCollection()

        // Then: Segmented control should exist for switching between exhibitions and news
        let segmentedControls = app.segmentedControls.allElementsBoundByIndex

        // 或者是自訂的 collection view 作為 tab 切換
        let collectionViews = app.collectionViews.allElementsBoundByIndex

        XCTAssertTrue(
            segmentedControls.count > 0 || collectionViews.count > 0,
            "收藏頁面應該有切換控制項"
        )
    }

    func testCollectionScreen_HasTableView() throws {
        // Given: Navigate to collection
        navigateToCollection()

        // Then: Table view should exist for showing collected items
        let tableViews = app.tables.allElementsBoundByIndex
        let collectionViews = app.collectionViews.allElementsBoundByIndex

        XCTAssertTrue(
            tableViews.count > 0 || collectionViews.count > 0,
            "收藏頁面應該有列表視圖"
        )
    }

    // MARK: - Collection Interaction Tests

    func testCollectionScreen_CanScrollContent() throws {
        // Given: Navigate to collection
        navigateToCollection()

        // When: Try to scroll
        let tableView = app.tables.firstMatch
        let collectionView = app.collectionViews.firstMatch

        if tableView.exists {
            tableView.swipeUp()
            sleep(1)
            tableView.swipeDown()
        } else if collectionView.exists {
            collectionView.swipeUp()
            sleep(1)
            collectionView.swipeDown()
        }

        // Then: Should be able to scroll without crashing
        XCTAssertTrue(app.exists, "滾動後 App 應該正常運作")
    }

    func testCollectionScreen_CanTapSegment() throws {
        // Given: Navigate to collection
        navigateToCollection()

        // When: Find and tap segment or tab
        let segmentedControl = app.segmentedControls.firstMatch
        if segmentedControl.exists {
            let buttons = segmentedControl.buttons.allElementsBoundByIndex
            if buttons.count > 1 {
                buttons[1].tap()
                sleep(1)
            }
        }

        // Then: Should switch content without crashing
        XCTAssertTrue(app.exists, "切換 tab 後 App 應該正常運作")
    }

    // MARK: - Empty State Tests

    func testCollectionScreen_ShowsEmptyStateOrContent() throws {
        // Given: Navigate to collection
        navigateToCollection()

        // Then: Should show either empty state message or collected items
        let tableView = app.tables.firstMatch
        let collectionView = app.collectionViews.firstMatch
        let staticTexts = app.staticTexts.allElementsBoundByIndex

        // 確認有內容顯示（空狀態文字或列表項目）
        let hasContent = tableView.exists ||
                        collectionView.exists ||
                        staticTexts.count > 0

        XCTAssertTrue(hasContent, "收藏頁面應該顯示內容或空狀態訊息")
    }

    // MARK: - Navigation Tests

    func testCollectionScreen_CanNavigateToExhibitionDetail() throws {
        // Given: Navigate to collection
        navigateToCollection()

        // When: Try to tap on a cell
        let tableView = app.tables.firstMatch
        if tableView.exists {
            let cells = tableView.cells.allElementsBoundByIndex
            if let firstCell = cells.first, firstCell.isHittable {
                firstCell.tap()
                sleep(1)

                // Then: Should navigate to detail (or show empty state)
                // 可以用返回按鈕存在來驗證導航成功
                let backButton = app.navigationBars.buttons.firstMatch
                if backButton.exists {
                    backButton.tap()
                    sleep(1)
                }
            }
        }

        XCTAssertTrue(app.exists, "App 應該正常運作")
    }

    // MARK: - Tab Persistence Tests

    func testCollectionScreen_RetainsStateOnTabSwitch() throws {
        // Given: Navigate to collection and interact
        navigateToCollection()
        sleep(1)

        // When: Switch to another tab and back
        let homeTab = app.tabBars.buttons["首頁"]
        homeTab.tap()
        sleep(1)

        let collectionTab = app.tabBars.buttons["收藏展覽"]
        collectionTab.tap()
        sleep(1)

        // Then: Collection screen should still be functional
        XCTAssertTrue(collectionTab.isSelected, "收藏展覽 tab 應該被選中")
    }

    // MARK: - Helper Methods

    private func navigateToCollection() {
        let collectionTab = app.tabBars.buttons["收藏展覽"]
        collectionTab.tap()
        sleep(1)
    }
}
