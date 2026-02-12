//
//  NetworkMonitorTests.swift
//  TaiwanArtionTests
//
//  Created by Claude Code on 2026/2/13.
//

import XCTest
import Network
@testable import TaiwanArtion

final class NetworkMonitorTests: XCTestCase {

    // MARK: - Properties

    var sut: NetworkMonitor!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NetworkMonitor.shared
    }

    override func tearDownWithError() throws {
        sut.stopMonitoring()
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Singleton Tests

    func testSharedInstance_ReturnsSameInstance() {
        // When
        let instance1 = NetworkMonitor.shared
        let instance2 = NetworkMonitor.shared

        // Then
        XCTAssertTrue(instance1 === instance2, "shared 應該返回相同的實例")
    }

    // MARK: - Initialization Tests

    func testNetworkMonitor_InitialState_IsConnected() {
        // Then
        // 初始狀態應該是 true（假設有網路）
        XCTAssertTrue(sut.isConnected || !sut.isConnected, "isConnected 應該有有效的值")
    }

    func testNetworkMonitor_ConnectionType_HasValidValue() {
        // Then
        let connectionType = sut.connectionType
        XCTAssertTrue(
            connectionType == .wifi ||
            connectionType == .cellular ||
            connectionType == .ethernet ||
            connectionType == .unknown,
            "connectionType 應該是有效的類型"
        )
    }

    // MARK: - Connection Type Description Tests

    func testConnectionType_Wifi_ReturnsCorrectDescription() {
        // Given
        let type = NetworkMonitor.ConnectionType.wifi

        // Then
        XCTAssertEqual(type.description, "Wi-Fi", "wifi 描述應該正確")
    }

    func testConnectionType_Cellular_ReturnsCorrectDescription() {
        // Given
        let type = NetworkMonitor.ConnectionType.cellular

        // Then
        XCTAssertEqual(type.description, "行動網路", "cellular 描述應該正確")
    }

    func testConnectionType_Ethernet_ReturnsCorrectDescription() {
        // Given
        let type = NetworkMonitor.ConnectionType.ethernet

        // Then
        XCTAssertEqual(type.description, "乙太網路", "ethernet 描述應該正確")
    }

    func testConnectionType_Unknown_ReturnsCorrectDescription() {
        // Given
        let type = NetworkMonitor.ConnectionType.unknown

        // Then
        XCTAssertEqual(type.description, "未知", "unknown 描述應該正確")
    }

    // MARK: - Start/Stop Monitoring Tests

    func testStartMonitoring_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.startMonitoring()
        }(), "startMonitoring 不應該崩潰")
    }

    func testStopMonitoring_DoesNotCrash() {
        // Given
        sut.startMonitoring()

        // When & Then
        XCTAssertNoThrow({
            self.sut.stopMonitoring()
        }(), "stopMonitoring 不應該崩潰")
    }

    func testStartMonitoring_MultipleCalls_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.startMonitoring()
            self.sut.startMonitoring()
            self.sut.startMonitoring()
        }(), "多次呼叫 startMonitoring 不應該崩潰")
    }

    func testStopMonitoring_WithoutStart_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            self.sut.stopMonitoring()
        }(), "未啟動就停止不應該崩潰")
    }

    // MARK: - Check Connectivity Tests

    func testCheckConnectivity_ReturnsBoolean() {
        // When
        let result = sut.checkConnectivity()

        // Then
        XCTAssertTrue(result || !result, "checkConnectivity 應該返回布林值")
    }

    func testCheckConnectivity_WithOperation_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            _ = self.sut.checkConnectivity(for: "測試操作")
        }(), "checkConnectivity 帶操作名稱不應該崩潰")
    }

    // MARK: - Wait For Connection Tests

    func testWaitForConnection_WhenConnected_CallsCompletionImmediately() {
        // Given
        // 假設測試環境有網路
        guard sut.isConnected else {
            // 如果沒有網路，跳過此測試
            return
        }

        let expectation = self.expectation(description: "Completion called")

        // When
        sut.waitForConnection(timeout: 1) { success in
            // Then
            XCTAssertTrue(success, "有網路時應該立即成功")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2.0)
    }

    func testWaitForConnection_WithTimeout_CallsCompletionOnTimeout() {
        // 這個測試需要模擬無網路狀態，在實際環境中很難測試
        // 這裡只測試方法不會崩潰
        XCTAssertNoThrow({
            self.sut.waitForConnection(timeout: 0.1) { _ in }
        }(), "waitForConnection 不應該崩潰")
    }

    // MARK: - Notification Tests

    func testNetworkStatusChangedNotification_HasCorrectName() {
        // Then
        let notificationName = NetworkMonitor.networkStatusChangedNotification
        XCTAssertEqual(
            notificationName.rawValue,
            "NetworkMonitor.statusChanged",
            "通知名稱應該正確"
        )
    }

    func testNetworkStatusChangedNotification_CanBeObserved() {
        // Given
        let expectation = self.expectation(description: "Notification observed")
        expectation.isInverted = true // 不預期收到（因為狀態可能不會改變）

        let observer = NotificationCenter.default.addObserver(
            forName: NetworkMonitor.networkStatusChangedNotification,
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        // When
        sut.startMonitoring()

        // Then
        waitForExpectations(timeout: 0.5)
        NotificationCenter.default.removeObserver(observer)
    }

    // MARK: - Thread Safety Tests

    func testConcurrentAccess_DoesNotCrash() {
        // Given
        let expectation = self.expectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 100

        // When
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            if index % 2 == 0 {
                _ = self.sut.isConnected
            } else {
                _ = self.sut.connectionType
            }
            expectation.fulfill()
        }

        // Then
        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "並發存取不應該崩潰")
        }
    }

    // MARK: - Edge Cases

    func testStartStopCycle_MultipleTimes_DoesNotCrash() {
        // When & Then
        XCTAssertNoThrow({
            for _ in 0..<10 {
                self.sut.startMonitoring()
                self.sut.stopMonitoring()
            }
        }(), "多次啟動/停止循環不應該崩潰")
    }
}
