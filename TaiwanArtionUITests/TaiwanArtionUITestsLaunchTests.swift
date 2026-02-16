//
//  TaiwanArtionUITestsLaunchTests.swift
//  TaiwanArtionUITests
//
//  Created by Jhen Mu on 2023/5/11.
//  Updated by Claude Code on 2026/2/16.
//

import XCTest

final class TaiwanArtionUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Launch Screenshot Tests

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // 等待首頁載入完成
        let tabBar = app.tabBars.firstMatch
        let exists = tabBar.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "Tab bar 應該在 5 秒內出現")

        // 截取啟動畫面
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Tab Screenshots

    func testHomeScreenshot() throws {
        let app = XCUIApplication()
        app.launch()

        // 確保在首頁
        let homeTab = app.tabBars.buttons["首頁"]
        if homeTab.exists {
            homeTab.tap()
        }
        sleep(2)

        // 截取首頁
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Home Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testNearExhibitionScreenshot() throws {
        let app = XCUIApplication()
        app.launch()

        // 導航到附近展覽
        let nearTab = app.tabBars.buttons["附近展覽"]
        if nearTab.exists {
            nearTab.tap()
        }
        sleep(2)

        // 截取畫面
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Near Exhibition Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testCollectionScreenshot() throws {
        let app = XCUIApplication()
        app.launch()

        // 導航到收藏
        let collectionTab = app.tabBars.buttons["收藏展覽"]
        if collectionTab.exists {
            collectionTab.tap()
        }
        sleep(2)

        // 截取畫面
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Collection Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testCalendarScreenshot() throws {
        let app = XCUIApplication()
        app.launch()

        // 導航到月曆
        let calendarTab = app.tabBars.buttons["展覽月曆"]
        if calendarTab.exists {
            calendarTab.tap()
        }
        sleep(2)

        // 截取畫面
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Calendar Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testProfileScreenshot() throws {
        let app = XCUIApplication()
        app.launch()

        // 導航到個人檔案
        let profileTab = app.tabBars.buttons["個人檔案"]
        if profileTab.exists {
            profileTab.tap()
        }
        sleep(2)

        // 截取畫面
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Profile Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Dark Mode Screenshot

    func testDarkModeScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-UIUserInterfaceStyle", "Dark"]
        app.launch()

        sleep(2)

        // 截取深色模式畫面
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Dark Mode Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Light Mode Screenshot

    func testLightModeScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-UIUserInterfaceStyle", "Light"]
        app.launch()

        sleep(2)

        // 截取淺色模式畫面
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Light Mode Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
