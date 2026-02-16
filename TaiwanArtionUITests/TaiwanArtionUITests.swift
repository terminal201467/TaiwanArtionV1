//
//  TaiwanArtionUITests.swift
//  TaiwanArtionUITests
//
//  Created by Jhen Mu on 2023/5/11.
//  Updated by Claude Code on 2026/2/16.
//

import XCTest

final class TaiwanArtionUITests: XCTestCase {

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

    // MARK: - Basic Launch Tests

    func testAppLaunch_Succeeds() throws {
        // Then: App should launch successfully
        XCTAssertTrue(app.exists, "App 應該成功啟動")
    }

    func testAppLaunch_ShowsMainInterface() throws {
        // Then: Main interface elements should be visible
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar 應該可見")
    }

    // MARK: - Performance Tests

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    // MARK: - Accessibility Tests

    func testAccessibility_TabBarIsAccessible() throws {
        // Given: App is launched
        let tabBar = app.tabBars.firstMatch

        // Then: Tab bar should be accessible
        XCTAssertTrue(tabBar.isHittable, "Tab bar 應該可以點擊")
    }

    func testAccessibility_AllTabsAreAccessible() throws {
        // Given: Tab bar tabs
        let tabs = ["首頁", "附近展覽", "收藏展覽", "展覽月曆", "個人檔案"]

        // Then: All tabs should be hittable
        for tabName in tabs {
            let tab = app.tabBars.buttons[tabName]
            if tab.exists {
                XCTAssertTrue(tab.isHittable, "\(tabName) tab 應該可以點擊")
            }
        }
    }

    // MARK: - Orientation Tests

    func testOrientation_PortraitWorks() throws {
        // Given: App in portrait mode
        XCUIDevice.shared.orientation = .portrait

        // Then: App should still function
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Portrait 模式下 Tab bar 應該存在")
    }

    // MARK: - Memory Tests

    func testMemory_SwitchingTabsDoesNotCrash() throws {
        // Given: Tab names
        let tabs = ["首頁", "附近展覽", "收藏展覽", "展覽月曆", "個人檔案"]

        // When: Rapidly switch between tabs
        for _ in 0..<3 {
            for tabName in tabs {
                let tab = app.tabBars.buttons[tabName]
                if tab.exists && tab.isHittable {
                    tab.tap()
                }
            }
        }

        // Then: App should not crash
        XCTAssertTrue(app.exists, "快速切換 Tab 後 App 應該正常運作")
    }

    // MARK: - Scroll Tests

    func testScroll_HomeScreenCanScroll() throws {
        // Given: Home screen
        let homeTab = app.tabBars.buttons["首頁"]
        homeTab.tap()

        // When: Scroll
        let tableView = app.tables.firstMatch
        if tableView.exists {
            tableView.swipeUp()
            tableView.swipeUp()
            tableView.swipeDown()
            tableView.swipeDown()
        }

        // Then: Should not crash
        XCTAssertTrue(app.exists, "滾動後 App 應該正常運作")
    }

    // MARK: - Background/Foreground Tests

    func testBackgroundForeground_AppResumes() throws {
        // Given: App is running
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)

        // When: Send to background and resume
        XCUIDevice.shared.press(.home)
        sleep(2)
        app.activate()
        sleep(1)

        // Then: App should resume properly
        XCTAssertTrue(app.tabBars.firstMatch.exists, "從背景恢復後 Tab bar 應該存在")
    }
}
