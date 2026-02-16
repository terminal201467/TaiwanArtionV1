//
//  DIContainer.swift
//  TaiwanArtion
//
//  Created by Refactor on 2026/2/13.
//

import Foundation
import UIKit

/// 依賴注入容器
/// 集中管理所有 Repository 和 ViewModel 的建立
final class DIContainer {

    // MARK: - Singleton

    static let shared = DIContainer()

    private init() {
        AppLogger.info("DIContainer 初始化完成", category: .general)
    }

    // MARK: - Repositories

    /// 展覽 Repository
    lazy var exhibitionRepository: ExhibitionRepository = {
        AppLogger.debug("建立 ExhibitionRepository", category: .general)
        return FirebaseExhibitionRepository()
    }()

    /// 新聞 Repository
    lazy var newsRepository: NewsRepository = {
        AppLogger.debug("建立 NewsRepository", category: .general)
        return FirebaseNewsRepository()
    }()

    /// 認證 Repository
    lazy var authRepository: AuthRepository = {
        AppLogger.debug("建立 AuthRepository", category: .general)
        return FirebaseAuthRepository()
    }()

    // MARK: - ViewModel Factory Methods

    /// 建立 HomeViewModel
    func makeHomeViewModel() -> HomeViewModel {
        AppLogger.debug("建立 HomeViewModel", category: .viewModel)
        return HomeViewModel()
    }

    /// 建立 CollectViewModel
    func makeCollectViewModel() -> CollectViewModel {
        AppLogger.debug("建立 CollectViewModel", category: .viewModel)
        return CollectViewModel()
    }

    /// 建立 SearchViewModel
    func makeSearchViewModel() -> SearchViewModel {
        AppLogger.debug("建立 SearchViewModel", category: .viewModel)
        return SearchViewModel()
    }

    /// 建立 ExhibitionCardViewModel
    func makeExhibitionCardViewModel() -> ExhibitionCardViewModel {
        AppLogger.debug("建立 ExhibitionCardViewModel", category: .viewModel)
        return ExhibitionCardViewModel()
    }

    /// 建立 LoginViewModel
    func makeLoginViewModel() -> LoginViewModel {
        AppLogger.debug("建立 LoginViewModel", category: .viewModel)
        return LoginViewModel()
    }

    /// 建立 RegisterViewModel
    func makeRegisterViewModel() -> RegisterViewModel {
        AppLogger.debug("建立 RegisterViewModel", category: .viewModel)
        return RegisterViewModel()
    }

    /// 建立 PersonInfoViewModel
    func makePersonInfoViewModel() -> PersonInfoViewModel {
        AppLogger.debug("建立 PersonInfoViewModel", category: .viewModel)
        return PersonInfoViewModel()
    }

    // MARK: - Reset (for testing)

    #if DEBUG
    /// 重設所有 Repository（僅供測試使用）
    func reset() {
        AppLogger.warning("DIContainer 重設 - 僅供測試使用", category: .general)
        // 重新建立 lazy properties 需要重新建立 DIContainer
    }

    /// 設定測試用的 Repository
    func setExhibitionRepository(_ repository: ExhibitionRepository) {
        // 測試用注入
    }

    func setNewsRepository(_ repository: NewsRepository) {
        // 測試用注入
    }

    func setAuthRepository(_ repository: AuthRepository) {
        // 測試用注入
    }
    #endif
}
