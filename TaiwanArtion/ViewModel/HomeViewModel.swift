//
//  HomeViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/18.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

enum HomeSections: Int, CaseIterable {
    case year = 0, hot, news, all
    var title: String {
        switch self {
        case .year: return ""
        case .hot: return "熱門展覽"
        case .news: return "藝文新聞"
        case .all: return "所有展覽"
        }
    }
}

public protocol HomeViewModelInput: AnyObject {
    var monthSelected: PublishSubject<IndexPath> { get }
    var habbySelected: PublishSubject<IndexPath> { get }
    var mainPhotoSelected: PublishSubject<IndexPath> { get }
    var hotExhibitionSelected: PublishSubject<IndexPath> { get }
    var newsExhibitionSelected: PublishSubject<IndexPath> { get }
    var allExhibitionSelected: PublishSubject<IndexPath> { get }
    var itemSelected: PublishSubject<IndexPath> { get }
}

public protocol HomeViewModelOutput: AnyObject {
    var months: Observable<Month> { get }
    var habbys: Observable<HabbyItem?> { get }
    var items: Observable<Items> { get }
    var hotExhibitionRelay: BehaviorRelay<[ExhibitionInfo]> { get }
    var mainPhotoRelay: BehaviorRelay<[ExhibitionInfo]> { get }
    var newsRelay: BehaviorRelay<[News]> { get }
    var allExhibitionRelay: BehaviorRelay<[ExhibitionInfo]> { get }
    var isLoadingMoreRelay: BehaviorRelay<Bool> { get }
    var hasMoreExhibitionsRelay: BehaviorRelay<Bool> { get }
}

public protocol HomeViewModelType: AnyObject {
    var inputs: HomeViewModelInput { get }
    var outputs: HomeViewModelOutput { get }
}

class HomeViewModel: HomeViewModelType, HomeViewModelInput, HomeViewModelOutput {
    
    //Input
    var monthSelected: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    var habbySelected: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    var mainPhotoSelected: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    var hotExhibitionSelected: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    var newsExhibitionSelected: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    var allExhibitionSelected: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    var itemSelected: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    
    //Singleton
    static let shared = HomeViewModel()

    private let disposeBag = DisposeBag()

    //MARK: - Input、Output
    var inputs: HomeViewModelInput { self }

    var outputs: HomeViewModelOutput { self }
    
    //MARK: - Store
    
    let hotExhibitionRelay = BehaviorRelay<[ExhibitionInfo]>(value: [])
    
    let mainPhotoRelay = BehaviorRelay<[ExhibitionInfo]>(value: [])
    
    let newsRelay = BehaviorRelay<[News]>(value: [])
    
    let allExhibitionRelay = BehaviorRelay<[ExhibitionInfo]>(value: [])

    // MARK: - Pagination State

    let isLoadingMoreRelay = BehaviorRelay<Bool>(value: false)
    let hasMoreExhibitionsRelay = BehaviorRelay<Bool>(value: true)
    private var lastExhibitionDocument: Any?
    private let pageSize = 10

    //MARK: - CollectionViewSelectedRelay
    
    private let currentMonthsSubject = BehaviorSubject<Month>(value: .jan)
    
    private let currentHabbySubject = BehaviorSubject<HabbyItem?>(value: nil)
    
    private let currenItemSubject = BehaviorSubject<Items>(value: .newest)
    
    var months: Observable<Month> { currentMonthsSubject.asObservable() }
    
    var habbys: Observable<HabbyItem?> { currentHabbySubject.asObservable() }
    
    var items: Observable<Items> { currenItemSubject.asObservable() }
    
    //MARK: - Intialization
    public init(
        exhibitionRepository: ExhibitionRepository? = nil,
        newsRepository: NewsRepository? = nil
    ) {
        self.exhibitionRepository = exhibitionRepository ?? DIContainer.shared.exhibitionRepository
        self.newsRepository = newsRepository ?? DIContainer.shared.newsRepository
        //input
        monthSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.currentMonthsSubject.onNext(Month(rawValue: indexPath.row)!)
                self.fetchDateKind(by: Month(rawValue: indexPath.row)!)
            })
            .disposed(by: disposeBag)

        habbySelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.currentHabbySubject.onNext(HabbyItem(rawValue: indexPath.row))
            })
            .disposed(by: disposeBag)

        itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.currenItemSubject.onNext(Items(rawValue: indexPath.row)!)
                self.allExhibitionSelected.onNext(indexPath)
            })
            .disposed(by: disposeBag)
        
        //主要圖像
        fetchRecentExhibition(count: 5) { [weak self] info in
            self?.mainPhotoRelay.accept(info)
        }

        //熱門展覽
        fetchRecentExhibition(count: 8) { [weak self] info in
            self?.hotExhibitionRelay.accept(info)
        }

        allExhibitionSelected.subscribe(onNext: { [weak self] indexPath in
            guard let self = self else { return }
            switch Items(rawValue: indexPath.row) {
            case .newest:
                self.fetchRecentExhibition(count: 10) { [weak self] info in
                    self?.allExhibitionRelay.accept(info)
                }
            case .popular:
                self.fetchDataHotExhibition(by: 10) { [weak self] info in
                    self?.allExhibitionRelay.accept(info)
                }
            case .highRank:
                self.fetchDataHotExhibition(by: 10) { [weak self] info in
                    self?.allExhibitionRelay.accept(info)
                }
            case .recent:
                self.fetchRecentExhibition(count: 10) { [weak self] info in
                    self?.allExhibitionRelay.accept(info)
                }
            case .none: AppLogger.debug("none", category: .viewModel)
            }
        })
        .disposed(by: disposeBag)

        fetchDataNewsExhibition(count: 5) { [weak self] info in
            self?.newsRelay.accept(info)
        }
    }
    
    //MARK: - Repository

    private let exhibitionRepository: ExhibitionRepository
    private let newsRepository: NewsRepository

    func fetchDateKind(by month: Month) {
        exhibitionRepository.getExhibitions(month: month.numberText) { result in
            switch result {
            case .success(let exhibitions):
                AppLogger.debug("data: \(exhibitions.count) exhibitions", category: .viewModel)
            case .failure(let error):
                AppLogger.error("error: \(error)", category: .viewModel)
            }
        }
    }
    
    //MARK: - Fetch Methods
    
    func fetchDataRecentExhibition(by count: Int, completion: @escaping (([ExhibitionInfo]) -> Void)) {
        exhibitionRepository.getRandomExhibitions(count: count) { result in
            switch result {
            case .success(let exhibitions):
                completion(exhibitions)
            case .failure(let error):
                AppLogger.error("error:\(error)", category: .viewModel)
            }
        }
    }
    
    func fetchDataHotExhibition(by count: Int, completion: @escaping (([ExhibitionInfo]) -> Void)) {
        exhibitionRepository.getHotExhibitions(count: count) { result in
            switch result {
            case .success(let exhibitions):
                completion(exhibitions)
            case .failure(let error):
                AppLogger.error("error:\(error)", category: .viewModel)
            }
        }
    }
    
    func fetchDataNewsExhibition(count: Int, completion: @escaping (([News]) -> Void)) {
        newsRepository.getRandomNews(count: count) { result in
            switch result {
            case .success(let newsList):
                completion(newsList)
            case .failure(let error):
                AppLogger.error("error:\(error)", category: .viewModel)
            }
        }
    }
    
    func fetchRecentExhibition(count: Int, completion: @escaping (([ExhibitionInfo]) -> Void)) {
        exhibitionRepository.getRecentExhibitions(count: count) { result in
            switch result {
            case .success(let exhibitions):
                completion(exhibitions)
            case .failure(let error):
                AppLogger.error("error:\(error)", category: .viewModel)
            }
        }
    }

    // MARK: - Pagination Methods

    /// 載入更多「所有展覽」資料（分頁）
    func loadMoreAllExhibitions() {
        // 防止重複載入
        guard !isLoadingMoreRelay.value else {
            AppLogger.debug("正在載入中，跳過", category: .viewModel)
            return
        }

        // 檢查是否還有更多資料
        guard hasMoreExhibitionsRelay.value else {
            AppLogger.debug("已無更多資料", category: .viewModel)
            return
        }

        isLoadingMoreRelay.accept(true)

        exhibitionRepository.getExhibitionsPaginated(
            pageSize: pageSize,
            lastDocument: lastExhibitionDocument
        ) { [weak self] result in
            guard let self = self else { return }

            self.isLoadingMoreRelay.accept(false)

            switch result {
            case .success(let paginatedResult):
                // 更新分頁游標
                self.lastExhibitionDocument = paginatedResult.lastDocument
                self.hasMoreExhibitionsRelay.accept(paginatedResult.hasMore)

                // 追加資料到現有列表
                let currentExhibitions = self.allExhibitionRelay.value
                let newExhibitions = currentExhibitions + paginatedResult.exhibitions
                self.allExhibitionRelay.accept(newExhibitions)

                AppLogger.info(
                    "分頁載入成功: 新增 \(paginatedResult.exhibitions.count) 筆, 總共 \(newExhibitions.count) 筆",
                    category: .viewModel
                )

            case .failure(let error):
                AppLogger.error("分頁載入失敗", category: .viewModel, error: error)
            }
        }
    }

    /// 重置分頁狀態（切換排序方式時呼叫）
    func resetPagination() {
        lastExhibitionDocument = nil
        hasMoreExhibitionsRelay.accept(true)
        allExhibitionRelay.accept([])
        AppLogger.debug("分頁狀態已重置", category: .viewModel)
    }

    /// 首次載入所有展覽（分頁模式）
    func loadInitialAllExhibitions() {
        resetPagination()
        loadMoreAllExhibitions()
    }
}
