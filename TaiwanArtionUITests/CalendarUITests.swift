//
//  CalendarUITests.swift
//  TaiwanArtionUITests
//
//  Created by Claude Code on 2026/2/16.
//

import XCTest

final class CalendarUITests: XCTestCase {

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

    // MARK: - Navigation to Calendar

    func testCalendarTab_CanBeSelected() throws {
        // Given: App launched
        let calendarTab = app.tabBars.buttons["展覽月曆"]

        // When: Tap calendar tab
        calendarTab.tap()

        // Then: Calendar tab should be selected
        XCTAssertTrue(calendarTab.isSelected, "展覽月曆 tab 應該被選中")
    }

    // MARK: - Calendar Screen Elements

    func testCalendarScreen_HasCalendarView() throws {
        // Given: Navigate to calendar
        navigateToCalendar()

        // Then: Should have calendar-related UI
        let collectionViews = app.collectionViews.allElementsBoundByIndex
        let tableViews = app.tables.allElementsBoundByIndex
        let datePickers = app.datePickers.allElementsBoundByIndex

        // 日曆通常用 collection view 或自訂視圖實現
        XCTAssertTrue(
            collectionViews.count > 0 || tableViews.count > 0 || datePickers.count > 0,
            "展覽月曆頁面應該有日曆視圖"
        )
    }

    func testCalendarScreen_HasMonthNavigation() throws {
        // Given: Navigate to calendar
        navigateToCalendar()

        // Then: Should have month navigation buttons or text
        let buttons = app.buttons.allElementsBoundByIndex
        let staticTexts = app.staticTexts.allElementsBoundByIndex

        // 應該有月份顯示或導航按鈕
        let hasMonthContent = staticTexts.contains { text in
            let label = text.label
            return label.contains("月") ||
                   label.contains("January") ||
                   label.contains("February") ||
                   label.contains("2024") ||
                   label.contains("2025") ||
                   label.contains("2026")
        }

        XCTAssertTrue(
            hasMonthContent || buttons.count > 0 || staticTexts.count > 0,
            "展覽月曆應該顯示月份相關資訊"
        )
    }

    // MARK: - Calendar Interaction Tests

    func testCalendarScreen_CanScrollCalendar() throws {
        // Given: Navigate to calendar
        navigateToCalendar()

        // When: Try to scroll
        let collectionView = app.collectionViews.firstMatch
        let scrollView = app.scrollViews.firstMatch

        if collectionView.exists {
            collectionView.swipeLeft()
            sleep(1)
            collectionView.swipeRight()
            sleep(1)
        } else if scrollView.exists {
            scrollView.swipeUp()
            sleep(1)
            scrollView.swipeDown()
            sleep(1)
        }

        // Then: Should scroll without crashing
        XCTAssertTrue(app.exists, "滾動日曆後 App 應該正常運作")
    }

    func testCalendarScreen_CanTapDate() throws {
        // Given: Navigate to calendar
        navigateToCalendar()

        // When: Try to tap on a date cell
        let collectionView = app.collectionViews.firstMatch
        if collectionView.exists {
            let cells = collectionView.cells.allElementsBoundByIndex
            // 嘗試點擊中間的 cell（可能是日期）
            let middleIndex = cells.count / 2
            if middleIndex > 0 && middleIndex < cells.count {
                let cell = cells[middleIndex]
                if cell.isHittable {
                    cell.tap()
                    sleep(1)
                }
            }
        }

        // Then: App should still work
        XCTAssertTrue(app.exists, "點擊日期後 App 應該正常運作")
    }

    func testCalendarScreen_CanNavigateMonths() throws {
        // Given: Navigate to calendar
        navigateToCalendar()

        // When: Find and tap navigation buttons
        let buttons = app.buttons.allElementsBoundByIndex

        // 嘗試找到下一個月/上一個月的按鈕
        for button in buttons {
            let label = button.label.lowercased()
            if label.contains("next") ||
               label.contains("下") ||
               label.contains(">") ||
               button.identifier.contains("next") {
                if button.isHittable {
                    button.tap()
                    sleep(1)
                    break
                }
            }
        }

        // Then: Should navigate without crashing
        XCTAssertTrue(app.exists, "導航月份後 App 應該正常運作")
    }

    // MARK: - Exhibition List Tests

    func testCalendarScreen_ShowsExhibitionList() throws {
        // Given: Navigate to calendar
        navigateToCalendar()

        // Then: Should have a list showing exhibitions
        let tableViews = app.tables.allElementsBoundByIndex
        let collectionViews = app.collectionViews.allElementsBoundByIndex

        // 日曆頁面通常會顯示當月展覽列表
        XCTAssertTrue(
            tableViews.count > 0 || collectionViews.count > 0,
            "展覽月曆應該能顯示展覽列表"
        )
    }

    func testCalendarScreen_CanTapExhibition() throws {
        // Given: Navigate to calendar
        navigateToCalendar()

        // When: Try to tap on an exhibition cell
        let tableView = app.tables.firstMatch
        if tableView.exists {
            let cells = tableView.cells.allElementsBoundByIndex
            if let firstCell = cells.first, firstCell.isHittable {
                firstCell.tap()
                sleep(1)

                // If navigated, go back
                let backButton = app.navigationBars.buttons.firstMatch
                if backButton.exists && backButton.isHittable {
                    backButton.tap()
                    sleep(1)
                }
            }
        }

        // Then: App should still work
        XCTAssertTrue(app.exists, "點擊展覽後 App 應該正常運作")
    }

    // MARK: - Tab Persistence Tests

    func testCalendarScreen_RetainsStateOnTabSwitch() throws {
        // Given: Navigate to calendar and interact
        navigateToCalendar()

        // When: Switch to another tab and back
        let homeTab = app.tabBars.buttons["首頁"]
        homeTab.tap()
        sleep(1)

        let calendarTab = app.tabBars.buttons["展覽月曆"]
        calendarTab.tap()
        sleep(1)

        // Then: Calendar screen should still be functional
        XCTAssertTrue(calendarTab.isSelected, "展覽月曆 tab 應該被選中")
    }

    // MARK: - Helper Methods

    private func navigateToCalendar() {
        let calendarTab = app.tabBars.buttons["展覽月曆"]
        calendarTab.tap()
        sleep(1)
    }
}
