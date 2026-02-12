//
//  UIComponentTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/13.
//

import XCTest
@testable import TaiwanArtion

// MARK: - SectionHeaderView Tests

final class SectionHeaderViewTests: XCTestCase {

    var sut: SectionHeaderView!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = SectionHeaderView()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testSectionHeaderView_DefaultInit_DoesNotCrash() {
        // Then
        XCTAssertNotNil(sut, "SectionHeaderView 應該能夠初始化")
    }

    func testSectionHeaderView_WithConfiguration_DoesNotCrash() {
        // When
        let view = SectionHeaderView(configuration: .withSeeAll)

        // Then
        XCTAssertNotNil(view, "帶 configuration 的初始化應該正常")
    }

    func testSectionHeaderView_DefaultConfiguration_IsCorrect() {
        // Given
        let config = SectionHeaderView.Configuration.default

        // Then
        XCTAssertFalse(config.showSeeAllButton, "預設不應該顯示查看全部按鈕")
        XCTAssertNil(config.buttonTitle, "預設 buttonTitle 應該是 nil")
        XCTAssertEqual(config.height, 50, "預設高度應該是 50")
    }

    func testSectionHeaderView_WithSeeAllConfiguration_IsCorrect() {
        // Given
        let config = SectionHeaderView.Configuration.withSeeAll

        // Then
        XCTAssertTrue(config.showSeeAllButton, "應該顯示查看全部按鈕")
        XCTAssertEqual(config.buttonTitle, "查看全部", "buttonTitle 應該是「查看全部」")
    }

    // MARK: - Configure Tests

    func testConfigure_WithTitle_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.configure(title: "測試標題")
        }(), "configure 不應該崩潰")
    }

    func testConfigure_WithTitleAndSubtitle_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.configure(title: "測試標題", subtitle: "測試副標題")
        }(), "configure 帶副標題不應該崩潰")
    }

    // MARK: - Button Tests

    func testSetButtonTitle_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.setButtonTitle("自訂按鈕")
        }(), "setButtonTitle 不應該崩潰")
    }

    func testSetButtonTitle_WithNil_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.setButtonTitle(nil)
        }(), "setButtonTitle(nil) 不應該崩潰")
    }

    func testHideButton_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.hideButton()
        }(), "hideButton 不應該崩潰")
    }

    func testShowButton_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.showButton()
        }(), "showButton 不應該崩潰")
    }

    // MARK: - Callback Tests

    func testOnButtonTapped_WhenSet_CanBeTriggered() {
        // Given
        var tapped = false
        sut.onButtonTapped = {
            tapped = true
        }

        // When
        sut.onButtonTapped?()

        // Then
        XCTAssertTrue(tapped, "onButtonTapped 應該被觸發")
    }

    func testOnButtonTapped_InitialValue_IsNil() {
        // Then
        XCTAssertNil(sut.onButtonTapped, "初始 onButtonTapped 應該是 nil")
    }
}

// MARK: - TagLabel Tests

final class TagLabelTests: XCTestCase {

    var sut: TagLabel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = TagLabel()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testTagLabel_DefaultInit_DoesNotCrash() {
        // Then
        XCTAssertNotNil(sut, "TagLabel 應該能夠初始化")
    }

    func testTagLabel_WithStyle_DoesNotCrash() {
        // When
        let primary = TagLabel(style: .primary)
        let secondary = TagLabel(style: .secondary)
        let outlined = TagLabel(style: .outlined)

        // Then
        XCTAssertNotNil(primary, "primary style 初始化應該正常")
        XCTAssertNotNil(secondary, "secondary style 初始化應該正常")
        XCTAssertNotNil(outlined, "outlined style 初始化應該正常")
    }

    // MARK: - Style Tests

    func testStyle_Primary_ReturnsCorrectValues() {
        // Given
        let style = TagLabel.Style.primary

        // Then
        XCTAssertEqual(style.backgroundColor, .tagYellowColor, "primary 背景色應該正確")
        XCTAssertEqual(style.textColor, .white, "primary 文字顏色應該是白色")
        XCTAssertEqual(style.borderWidth, 0, "primary 不應該有邊框")
    }

    func testStyle_Secondary_ReturnsCorrectValues() {
        // Given
        let style = TagLabel.Style.secondary

        // Then
        XCTAssertEqual(style.backgroundColor, .systemGray5, "secondary 背景色應該正確")
        XCTAssertEqual(style.textColor, .darkGray, "secondary 文字顏色應該正確")
        XCTAssertEqual(style.borderWidth, 0, "secondary 不應該有邊框")
    }

    func testStyle_Outlined_ReturnsCorrectValues() {
        // Given
        let style = TagLabel.Style.outlined

        // Then
        XCTAssertEqual(style.backgroundColor, .clear, "outlined 背景應該透明")
        XCTAssertEqual(style.textColor, .brownColor, "outlined 文字顏色應該正確")
        XCTAssertEqual(style.borderWidth, 1, "outlined 應該有邊框")
    }

    // MARK: - Configure Tests

    func testConfigure_WithText_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.configure(text: "標籤文字")
        }(), "configure 不應該崩潰")
    }

    func testConfigure_WithEmptyText_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.configure(text: "")
        }(), "configure 空字串不應該崩潰")
    }

    // MARK: - Set Style Tests

    func testSetStyle_ChangesStyle() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.setStyle(.primary)
            self.sut.setStyle(.secondary)
            self.sut.setStyle(.outlined)
        }(), "setStyle 不應該崩潰")
    }

    // MARK: - Text Property Tests

    func testText_GetSet_WorksCorrectly() {
        // Given
        let testText = "測試文字"

        // When
        sut.text = testText

        // Then
        XCTAssertEqual(sut.text, testText, "text 屬性應該能正常讀寫")
    }

    func testText_SetNil_WorksCorrectly() {
        // When
        sut.text = nil

        // Then
        XCTAssertNil(sut.text, "應該能設為 nil")
    }
}

// MARK: - ExhibitionInfoView Tests

final class ExhibitionInfoViewTests: XCTestCase {

    var sut: ExhibitionInfoView!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ExhibitionInfoView()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testExhibitionInfoView_DefaultInit_DoesNotCrash() {
        // Then
        XCTAssertNotNil(sut, "ExhibitionInfoView 應該能夠初始化")
    }

    func testExhibitionInfoView_WithConfiguration_DoesNotCrash() {
        // When
        let defaultView = ExhibitionInfoView(configuration: .default)
        let compactView = ExhibitionInfoView(configuration: .compact)

        // Then
        XCTAssertNotNil(defaultView, "default configuration 初始化應該正常")
        XCTAssertNotNil(compactView, "compact configuration 初始化應該正常")
    }

    // MARK: - Configuration Tests

    func testConfiguration_Default_HasCorrectValues() {
        // Given
        let config = ExhibitionInfoView.Configuration.default

        // Then
        XCTAssertTrue(config.showCollectButton, "預設應該顯示收藏按鈕")
        XCTAssertTrue(config.showLocationInfo, "預設應該顯示位置資訊")
        XCTAssertTrue(config.showTag, "預設應該顯示標籤")
        XCTAssertEqual(config.imageCornerRadius, 8, "預設圓角應該是 8")
    }

    func testConfiguration_Compact_HasCorrectValues() {
        // Given
        let config = ExhibitionInfoView.Configuration.compact

        // Then
        XCTAssertFalse(config.showLocationInfo, "compact 不應該顯示位置資訊")
    }

    // MARK: - Configure Tests

    func testConfigure_WithExhibitionInfo_DoesNotCrash() {
        // Given
        let exhibition = ExhibitionInfo(
            id: "test",
            title: "測試展覽",
            image: "https://example.com/image.jpg",
            startDate: "2026-01-01",
            endDate: "2026-03-31",
            location: "測試地點",
            city: "台北市",
            latitude: 25.0,
            longitude: 121.0,
            tag: "免費",
            month: "01",
            official: "https://example.com",
            address: "測試地址"
        )

        // When & Then
        XCTAssertNoThrow({
            self.sut.configure(with: exhibition)
        }(), "configure(with:) 不應該崩潰")
    }

    func testConfigure_WithParameters_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.configure(
                image: "https://example.com/image.jpg",
                title: "測試標題",
                date: "2026/01/01 - 2026/03/31",
                location: "測試地點",
                tag: "免費"
            )
        }(), "configure(image:title:date:location:tag:) 不應該崩潰")
    }

    func testConfigure_WithMinimalParameters_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.configure(
                image: "",
                title: "標題",
                date: "日期"
            )
        }(), "最少參數的 configure 不應該崩潰")
    }

    // MARK: - Collected State Tests

    func testSetCollected_True_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.setCollected(true)
        }(), "setCollected(true) 不應該崩潰")
    }

    func testSetCollected_False_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.setCollected(false)
        }(), "setCollected(false) 不應該崩潰")
    }

    func testSetCollected_Toggle_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            for _ in 0..<10 {
                self.sut.setCollected(true)
                self.sut.setCollected(false)
            }
        }(), "快速切換收藏狀態不應該崩潰")
    }

    // MARK: - Reset Tests

    func testReset_DoesNotCrash() {
        // Given
        sut.configure(
            image: "https://example.com/image.jpg",
            title: "測試",
            date: "日期"
        )
        sut.setCollected(true)

        // When & Then
        XCTAssertNoThrow({
            self.sut.reset()
        }(), "reset 不應該崩潰")
    }

    // MARK: - Cancel Image Load Tests

    func testCancelImageLoad_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.cancelImageLoad()
        }(), "cancelImageLoad 不應該崩潰")
    }

    func testCancelImageLoad_AfterConfigure_DoesNotCrash() {
        // Given
        sut.configure(
            image: "https://example.com/image.jpg",
            title: "測試",
            date: "日期"
        )

        // When & Then
        XCTAssertNoThrow({
            self.sut.cancelImageLoad()
        }(), "configure 後 cancelImageLoad 不應該崩潰")
    }

    // MARK: - Callback Tests

    func testOnCollectTapped_WhenSet_CanBeTriggered() {
        // Given
        var tappedValue: Bool?
        sut.onCollectTapped = { isCollected in
            tappedValue = isCollected
        }

        // When
        sut.onCollectTapped?(true)

        // Then
        XCTAssertEqual(tappedValue, true, "callback 應該被觸發並傳入正確的值")
    }

    func testOnCollectTapped_InitialValue_IsNil() {
        // Then
        XCTAssertNil(sut.onCollectTapped, "初始 onCollectTapped 應該是 nil")
    }

    // MARK: - Edge Cases

    func testConfigure_WithEmptyStrings_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.configure(
                image: "",
                title: "",
                date: "",
                location: "",
                tag: ""
            )
        }(), "空字串不應該崩潰")
    }

    func testConfigure_WithLongStrings_DoesNotCrash() {
        // Given
        let longString = String(repeating: "測試", count: 1000)

        // When & Then
        XCTAssertNoThrow({
            self.sut.configure(
                image: longString,
                title: longString,
                date: longString,
                location: longString,
                tag: longString
            )
        }(), "長字串不應該崩潰")
    }

    func testConfigure_WithSpecialCharacters_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.configure(
                image: "https://example.com/image?param=!@#$%",
                title: "標題 <script>alert('xss')</script>",
                date: "2026/01/01 ~ 2026/03/31",
                location: "地點 & 更多",
                tag: "免費/優惠"
            )
        }(), "特殊字元不應該崩潰")
    }
}
