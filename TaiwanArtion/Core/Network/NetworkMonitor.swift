//
//  NetworkMonitor.swift
//  TaiwanArtion
//
//  Created on 2026/2/6.
//

import Foundation
import Network

/// 網路狀態監控器，用於偵測網路連線狀態
final class NetworkMonitor {

    // MARK: - Singleton

    static let shared = NetworkMonitor()

    // MARK: - Properties

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.taiwanartion.NetworkMonitor", qos: .utility)

    /// 目前是否有網路連線
    private(set) var isConnected: Bool = true

    /// 目前的連線類型
    private(set) var connectionType: ConnectionType = .unknown

    /// 網路狀態變更通知名稱
    static let networkStatusChangedNotification = Foundation.Notification.Name("NetworkMonitor.statusChanged")

    // MARK: - Connection Type

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown

        var description: String {
            switch self {
            case .wifi: return "Wi-Fi"
            case .cellular: return "行動網路"
            case .ethernet: return "乙太網路"
            case .unknown: return "未知"
            }
        }
    }

    // MARK: - Init

    private init() {}

    // MARK: - Public Methods

    /// 開始監控網路狀態
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            let wasConnected = self.isConnected
            self.isConnected = path.status == .satisfied

            // 更新連線類型
            self.updateConnectionType(path)

            // 記錄狀態變更
            if wasConnected != self.isConnected {
                let status = self.isConnected ? "已連線" : "已斷線"
                AppLogger.info("網路狀態變更: \(status) (\(self.connectionType.description))", category: .network)

                // 發送通知
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NetworkMonitor.networkStatusChangedNotification,
                        object: nil,
                        userInfo: ["isConnected": self.isConnected, "connectionType": self.connectionType]
                    )
                }
            }
        }

        monitor.start(queue: queue)
        AppLogger.info("網路監控已啟動", category: .network)
    }

    /// 停止監控網路狀態
    func stopMonitoring() {
        monitor.cancel()
        AppLogger.info("網路監控已停止", category: .network)
    }

    // MARK: - Private Methods

    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}

// MARK: - Convenience Methods

extension NetworkMonitor {

    /// 檢查網路是否可用，若不可用則記錄警告
    /// - Parameter operation: 操作描述（用於日誌）
    /// - Returns: 網路是否可用
    @discardableResult
    func checkConnectivity(for operation: String = "網路操作") -> Bool {
        if !isConnected {
            AppLogger.warning("\(operation) 失敗：無網路連線", category: .network)
        }
        return isConnected
    }

    /// 等待網路恢復連線（帶有超時）
    /// - Parameters:
    ///   - timeout: 超時時間（秒）
    ///   - completion: 完成回調，回傳是否成功連線
    func waitForConnection(timeout: TimeInterval = 10, completion: @escaping (Bool) -> Void) {
        if isConnected {
            completion(true)
            return
        }

        var observer: NSObjectProtocol?
        var timeoutWorkItem: DispatchWorkItem?

        // 設定超時
        timeoutWorkItem = DispatchWorkItem {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
            completion(false)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: timeoutWorkItem!)

        // 監聽連線恢復
        observer = NotificationCenter.default.addObserver(
            forName: NetworkMonitor.networkStatusChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let isConnected = notification.userInfo?["isConnected"] as? Bool,
                  isConnected else { return }

            timeoutWorkItem?.cancel()
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
            completion(true)
        }
    }
}
