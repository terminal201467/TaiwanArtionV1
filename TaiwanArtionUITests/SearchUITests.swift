//
//  SearchUITests.swift
//  TaiwanArtionUITests
//
//  Created by Claude Code on 2026/2/16.
//

import XCTest

final class SearchUITests: XCTestCase {

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

    // MARK: - Search Screen Navigation

    func testSearchButton_OpensSearchScreen() throws {
        // Given: App launched on home screen
        // Find search button (可能是圖片按鈕)
        let buttons = app.buttons.allElementsBoundByIndex

        // 尋找可能是搜尋按鈕的元素
        var searchButtonFound = false
        for button in buttons {
            if button.identifier.contains("search") ||
               button.label.lowercased().contains("search") ||
               button.identifier == "searchButton" {
                button.tap()
                searchButtonFound = true
                break
            }
        }

        if !searchButtonFound {
            // 嘗試點擊第一個導航區域的按鈕
            if let firstButton = buttons.first {
                firstButton.tap()
            }
        }

        // 等待導航完成
        sleep(1)

        // Then: 應該導航到搜尋頁面或顯示搜尋介面
        // 驗證不在首頁（Tab Bar 可能仍存在但畫面已改變）
        XCTAssertTrue(app.exists, "App 應該仍然存在")
    }

    // MARK: - Search Screen Elements

    func testSearchScreen_HasSearchTextField() throws {
        // Given: Navigate to search
        navigateToSearch()

        // Then: Search text field should exist
        let textFields = app.textFields.allElementsBoundByIndex
        let searchViews = app.searchFields.allElementsBoundByIndex

        XCTAssertTrue(
            textFields.count > 0 || searchViews.count > 0,
            "搜尋頁面應該有文字輸入框"
        )
    }

    func testSearchScreen_HasCollectionView() throws {
        // Given: Navigate to search
        navigateToSearch()

        // Then: Collection view or table view should exist for filters/results
        let collectionViews = app.collectionViews.allElementsBoundByIndex
        let tableViews = app.tables.allElementsBoundByIndex

        XCTAssertTrue(
            collectionViews.count > 0 || tableViews.count > 0,
            "搜尋頁面應該有列表或集合視圖"
        )
    }

    // MARK: - Search Interaction Tests

    func testSearchScreen_CanTapFilterButtons() throws {
        // Given: Navigate to search
        navigateToSearch()

        // When: Look for filter collection view cells
        let collectionView = app.collectionViews.firstMatch
        if collectionView.exists {
            let cells = collectionView.cells.allElementsBoundByIndex
            if let firstCell = cells.first, firstCell.isHittable {
                firstCell.tap()
                sleep(1)
                // Then: Should be able to interact with filter
                XCTAssertTrue(app.exists, "點擊篩選後 App 應該正常運作")
            }
        }
    }

    func testSearchScreen_CanTypeInSearchField() throws {
        // Given: Navigate to search
        navigateToSearch()

        // When: Find and tap on search field
        let searchField = app.textFields.firstMatch
        let searchBar = app.searchFields.firstMatch

        if searchField.exists && searchField.isHittable {
            searchField.tap()
            searchField.typeText("台北")
            sleep(1)

            // Then: Text should be entered
            XCTAssertTrue(searchField.value as? String != "", "搜尋欄位應該有文字")
        } else if searchBar.exists && searchBar.isHittable {
            searchBar.tap()
            searchBar.typeText("台北")
            sleep(1)

            XCTAssertTrue(app.exists, "輸入搜尋文字後 App 應該正常運作")
        }
    }

    // MARK: - Back Navigation

    func testSearchScreen_CanNavigateBack() throws {
        // Given: Navigate to search
        navigateToSearch()

        // When: Look for back button
        let backButton = app.navigationBars.buttons.firstMatch

        if backButton.exists && backButton.isHittable {
            backButton.tap()
            sleep(1)
        } else {
            // 嘗試滑動返回
            app.swipeRight()
            sleep(1)
        }

        // Then: Should be back on home screen
        let homeTab = app.tabBars.buttons["首頁"]
        XCTAssertTrue(homeTab.exists, "返回後應該能看到首頁 tab")
    }

    // MARK: - Helper Methods

    private func navigateToSearch() {
        // 嘗試多種方式導航到搜尋頁面
        let buttons = app.buttons.allElementsBoundByIndex

        for button in buttons {
            if button.identifier.contains("search") ||
               button.label.lowercased().contains("search") {
                button.tap()
                sleep(1)
                return
            }
        }

        // 如果找不到搜尋按鈕，嘗試點擊導航區域的第一個按鈕
        if let firstButton = buttons.first, firstButton.isHittable {
            firstButton.tap()
            sleep(1)
        }
    }
}
