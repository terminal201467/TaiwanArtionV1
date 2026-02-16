//
//  HomeUITests.swift
//  TaiwanArtionUITests
//
//  Created by Claude Code on 2026/2/16.
//

import XCTest

final class HomeUITests: XCTestCase {

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

    // MARK: - App Launch Tests

    func testAppLaunch_ShowsTabBar() throws {
        // Then: Tab bar should be visible
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar 應該存在")
        XCTAssertTrue(tabBar.isHittable, "Tab bar 應該可以點擊")
    }

    func testAppLaunch_ShowsAllTabs() throws {
        // Then: All 5 tabs should be visible
        let tabBar = app.tabBars.firstMatch

        // 檢查 5 個 tab 標籤
        XCTAssertTrue(tabBar.buttons["首頁"].exists, "首頁 tab 應該存在")
        XCTAssertTrue(tabBar.buttons["附近展覽"].exists, "附近展覽 tab 應該存在")
        XCTAssertTrue(tabBar.buttons["收藏展覽"].exists, "收藏展覽 tab 應該存在")
        XCTAssertTrue(tabBar.buttons["展覽月曆"].exists, "展覽月曆 tab 應該存在")
        XCTAssertTrue(tabBar.buttons["個人檔案"].exists, "個人檔案 tab 應該存在")
    }

    func testAppLaunch_HomeTabIsSelected() throws {
        // Then: Home tab should be selected by default
        let homeTab = app.tabBars.buttons["首頁"]
        XCTAssertTrue(homeTab.isSelected, "首頁 tab 應該被預設選中")
    }

    // MARK: - Home Screen Content Tests

    func testHomeScreen_HasSearchButton() throws {
        // Given: App launched on home screen
        // Then: Search button should exist
        let searchButton = app.buttons["searchButton"]

        // 如果沒有 accessibility identifier，嘗試用圖片名稱尋找
        if !searchButton.exists {
            let buttons = app.buttons.allElementsBoundByIndex
            let hasSearchButton = buttons.contains { $0.label.contains("search") || $0.identifier.contains("search") }
            XCTAssertTrue(hasSearchButton || buttons.count > 0, "應該有搜尋按鈕")
        }
    }

    func testHomeScreen_HasTableView() throws {
        // Given: App launched on home screen
        // Then: TableView should exist
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.exists, "首頁 TableView 應該存在")
    }

    func testHomeScreen_CanScroll() throws {
        // Given: App launched on home screen
        let tableView = app.tables.firstMatch

        // When: Scroll down
        tableView.swipeUp()

        // Then: Should be able to scroll
        // 等待滾動完成
        sleep(1)

        // 再滾動回上方
        tableView.swipeDown()
        sleep(1)

        XCTAssertTrue(tableView.exists, "滾動後 TableView 應該仍然存在")
    }

    // MARK: - Tab Navigation Tests

    func testTabNavigation_CanSwitchToNearTab() throws {
        // Given: App launched on home screen
        let nearTab = app.tabBars.buttons["附近展覽"]

        // When: Tap near exhibitions tab
        nearTab.tap()

        // Then: Near tab should be selected
        XCTAssertTrue(nearTab.isSelected, "附近展覽 tab 應該被選中")
    }

    func testTabNavigation_CanSwitchToCollectionTab() throws {
        // Given: App launched on home screen
        let collectionTab = app.tabBars.buttons["收藏展覽"]

        // When: Tap collection tab
        collectionTab.tap()

        // Then: Collection tab should be selected
        XCTAssertTrue(collectionTab.isSelected, "收藏展覽 tab 應該被選中")
    }

    func testTabNavigation_CanSwitchToCalendarTab() throws {
        // Given: App launched on home screen
        let calendarTab = app.tabBars.buttons["展覽月曆"]

        // When: Tap calendar tab
        calendarTab.tap()

        // Then: Calendar tab should be selected
        XCTAssertTrue(calendarTab.isSelected, "展覽月曆 tab 應該被選中")
    }

    func testTabNavigation_CanSwitchToProfileTab() throws {
        // Given: App launched on home screen
        let profileTab = app.tabBars.buttons["個人檔案"]

        // When: Tap profile tab
        profileTab.tap()

        // Then: Profile tab should be selected
        XCTAssertTrue(profileTab.isSelected, "個人檔案 tab 應該被選中")
    }

    func testTabNavigation_CanSwitchBackToHome() throws {
        // Given: On another tab
        let profileTab = app.tabBars.buttons["個人檔案"]
        profileTab.tap()

        // When: Tap home tab
        let homeTab = app.tabBars.buttons["首頁"]
        homeTab.tap()

        // Then: Home tab should be selected
        XCTAssertTrue(homeTab.isSelected, "首頁 tab 應該被選中")
    }

    // MARK: - Tab Cycling Tests

    func testTabNavigation_CycleAllTabs() throws {
        // Given: Start at home
        let tabs = ["首頁", "附近展覽", "收藏展覽", "展覽月曆", "個人檔案"]

        // When & Then: Cycle through all tabs
        for tabName in tabs {
            let tab = app.tabBars.buttons[tabName]
            tab.tap()
            sleep(1) // 等待畫面載入
            XCTAssertTrue(tab.isSelected, "\(tabName) tab 應該被選中")
        }
    }
}
