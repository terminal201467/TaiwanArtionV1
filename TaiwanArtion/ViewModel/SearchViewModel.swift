//
//  SearchViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/31.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

enum FilterType: Int, CaseIterable {
    case city = 0, place, date, price
    var text: String {
        switch self {
        case .city: return "縣市"
        case .place: return "展覽館"
        case .date: return "日期"
        case .price: return "票價"
        }
    }
}

enum AlreadyFilter: Int, CaseIterable {
    case result = 0, news, nearest, filterIcon
    var text: String {
        switch self {
        case .result: return "搜尋結果"
        case .news: return "藝文新聞"
        case .nearest: return "距離最近"
        case .filterIcon: return "filter"
        }
    }
}

// MARK: - Input Protocol

public protocol SearchViewModelInput: AnyObject {
    var searchTextInput: PublishRelay<String> { get }
    var searchModeChanged: PublishRelay<Bool> { get }
    var filterSelected: PublishRelay<Int> { get }
    var collectionItemSelected: PublishRelay<IndexPath> { get }
    var tableItemSelected: PublishRelay<IndexPath> { get }
}

// MARK: - Output Protocol

public protocol SearchViewModelOutput: AnyObject {
    var searchResultsRelay: BehaviorRelay<[ExhibitionInfo]> { get }
    var searchHistoryRelay: BehaviorRelay<[String]> { get }
    var isSearchingRelay: BehaviorRelay<Bool> { get }
    var currentFilterRelay: BehaviorRelay<Int?> { get }
    var hotSearchRelay: BehaviorRelay<[String]> { get }
}

public protocol SearchViewModelType: AnyObject {
    var inputs: SearchViewModelInput { get }
    var outputs: SearchViewModelOutput { get }
}

// MARK: - SearchViewModel

class SearchViewModel: SearchViewModelType, SearchViewModelInput, SearchViewModelOutput {

    // MARK: - Singleton (保留向後相容，建議使用依賴注入)
    static let shared = SearchViewModel()

    // MARK: - Dependencies
    private let exhibitionRepository: ExhibitionRepository
    private let disposeBag = DisposeBag()

    // MARK: - Input
    let searchTextInput = PublishRelay<String>()
    let searchModeChanged = PublishRelay<Bool>()
    let filterSelected = PublishRelay<Int>()
    let collectionItemSelected = PublishRelay<IndexPath>()
    let tableItemSelected = PublishRelay<IndexPath>()

    // MARK: - Output
    let searchResultsRelay = BehaviorRelay<[ExhibitionInfo]>(value: [])
    let searchHistoryRelay = BehaviorRelay<[String]>(value: [])
    let isSearchingRelay = BehaviorRelay<Bool>(value: false)
    let currentFilterRelay = BehaviorRelay<Int?>(value: nil)
    let hotSearchRelay = BehaviorRelay<[String]>(value: ["小王子", "悲慘世界", "久石讓", "貓之日", "蒙娜麗莎的探險之旅"])

    // MARK: - Input/Output
    var inputs: SearchViewModelInput { self }
    var outputs: SearchViewModelOutput { self }

    // MARK: - Private State
    private var isSearchModeOn: Bool = false {
        didSet {
            restartTheCurrentItem()
        }
    }

    private var currentItem: Int? {
        didSet {
            AppLogger.debug("currentItem:\(String(describing: currentItem))", category: .viewModel)
            currentFilterRelay.accept(currentItem)
        }
    }

    // MARK: - Legacy Callback (向後相容)
    var getCurrentItem: ((Int?) -> Void)?

    // MARK: - Initialization

    init(exhibitionRepository: ExhibitionRepository = FirebaseExhibitionRepository()) {
        self.exhibitionRepository = exhibitionRepository
        setupBindings()
    }

    private func setupBindings() {
        // 搜尋文字輸入 - 防抖動 300ms
        searchTextInput
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] keyword in
                guard let self = self else { return }
                self.performSearch(keyword: keyword)
            })
            .disposed(by: disposeBag)

        // 搜尋模式切換
        searchModeChanged
            .subscribe(onNext: { [weak self] isSearching in
                guard let self = self else { return }
                self.isSearchModeOn = isSearching
                self.isSearchingRelay.accept(isSearching)
                AppLogger.debug("isSearchModeOn:\(isSearching)", category: .viewModel)
            })
            .disposed(by: disposeBag)

        // 篩選器選擇
        filterSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.currentItem = index
            })
            .disposed(by: disposeBag)

        // CollectionView 選擇
        collectionItemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.currentItem = indexPath.row
                AppLogger.debug("collectionViewDidSelectedRowAt:\(String(describing: self.currentItem))", category: .viewModel)
            })
            .disposed(by: disposeBag)

        // 當 currentFilter 變化時通知 legacy callback
        currentFilterRelay
            .subscribe(onNext: { [weak self] item in
                self?.getCurrentItem?(item)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Search

    private func performSearch(keyword: String) {
        guard !keyword.isEmpty else {
            searchResultsRelay.accept([])
            return
        }

        AppLogger.debug("input SearchFilter:\(keyword)", category: .viewModel)

        // 添加到搜尋歷史
        addToSearchHistory(keyword)

        // 執行搜尋
        exhibitionRepository.searchExhibitions(keyword: keyword) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let exhibitions):
                AppLogger.debug("filterResult: \(exhibitions.count) items", category: .viewModel)
                self.searchResultsRelay.accept(exhibitions)
            case .failure(let error):
                AppLogger.error("搜尋失敗", category: .viewModel, error: error)
                self.searchResultsRelay.accept([])
            }
        }
    }

    private func addToSearchHistory(_ keyword: String) {
        var history = searchHistoryRelay.value
        // 移除重複
        history.removeAll { $0 == keyword }
        // 插入到開頭
        history.insert(keyword, at: 0)
        // 限制最多 10 個
        if history.count > 10 {
            history = Array(history.prefix(10))
        }
        searchHistoryRelay.accept(history)
    }

    // MARK: - Legacy Methods (向後相容)

    func filterSearchTextFiled(withText searchText: String) {
        searchTextInput.accept(searchText)
    }

    public func restartTheCurrentItem() {
        currentItem = nil
    }

    public func changedModeWith(isSearching: Bool) {
        searchModeChanged.accept(isSearching)
    }

    public func changeCurrentItem(by itemIndex: Int) {
        filterSelected.accept(itemIndex)
    }

    // MARK: - CollectionView Methods

    func collectionViewNumberOfRowInSection(section: Int) -> Int {
        return isSearchModeOn ? AlreadyFilter.allCases.count : FilterType.allCases.count
    }

    func collectionViewCellForRowAt(indexPath: IndexPath) -> (title: String, isSelected: Bool?) {
        if isSearchModeOn {
            if currentItem == nil {
                return (AlreadyFilter.allCases[indexPath.row].text, nil)
            } else {
                let isSelected = AlreadyFilter(rawValue: indexPath.row) == .init(rawValue: currentItem!)
                return (AlreadyFilter.allCases[indexPath.row].text, isSelected)
            }
        } else {
            if currentItem == nil {
                return (FilterType.allCases[indexPath.row].text, nil)
            } else {
                let isSelected = FilterType(rawValue: indexPath.row) == .init(rawValue: currentItem!)
                return (FilterType.allCases[indexPath.row].text, isSelected)
            }
        }
    }

    func collectionViewDidSelectedRowAt(indexPath: IndexPath) {
        collectionItemSelected.accept(indexPath)
    }

    func selectedCollectionViewAllCell(bySection section: Int) {
        AppLogger.debug("全選TableViewSection:\(section)", category: .viewModel)
    }

    // MARK: - TableView Methods

    func numberOfSection() -> Int {
        if isSearchModeOn {
            AppLogger.debug("isSearchModeOn:\(isSearchModeOn)", category: .viewModel)
            if let currentSelected = currentItem {
                switch AlreadyFilter(rawValue: currentSelected) {
                case .result: return 1
                case .news: return 1
                case .nearest: return 1
                case .filterIcon: return 1
                case .none: return 1
                }
            } else {
                return 1
            }
        } else {
            if let currentSelected = currentItem {
                switch FilterType(rawValue: currentSelected) {
                case .city: return Area.allCases.count
                case .place: return 1
                case .date: return 3
                case .price: return 1
                case .none: return 1
                }
            } else {
                return 1
            }
        }
    }

    func searchModeTableViewNumberOfRowInSection(section: Int) -> Int {
        switch AlreadyFilter(rawValue: section) {
        case .result: return 1
        case .news: return 1
        case .nearest: return 1
        case .filterIcon: return 1
        case .none: return 1
        }
    }

    func unSearchModeTableViewNumberOfRowInSection(section: Int) -> Int {
        if currentItem != nil {
            switch FilterType(rawValue: currentItem!) {
            case .city: return 1
            case .place: return 1
            case .date: return 1
            case .price: return 1
            case .none: return 1
            }
        } else {
            return 1
        }
    }

    func searchModeTableViewCellForRowAt(indexPath: IndexPath) -> [ExhibitionInfo] {
        return searchResultsRelay.value
    }

    func unSearchModeTableViewCellForRowAt(indexPath: IndexPath) -> [String] {
        if currentItem == nil {
            return hotSearchRelay.value
        } else {
            switch FilterType(rawValue: currentItem!) {
            case .city:
                switch Area(rawValue: indexPath.section) {
                case .north: return NorthernCity.allCases.map { $0.text }
                case .middle: return CentralCity.allCases.map { $0.text }
                case .south: return SouthernCity.allCases.map { $0.text }
                case .east: return EasternCity.allCases.map { $0.text }
                case .island: return OutlyingIslandCity.allCases.map { $0.text }
                case .correct: return [""]
                case .none: return hotSearchRelay.value
                }
            case .place: return Place.allCases.map { $0.title }
            case .date: return DateKind.allCases.map { $0.text }
            case .price: return Price.allCases.map { $0.text }
            case .none: return hotSearchRelay.value
            }
        }
    }

    func tableViewDidSelectedRowAt(indexPath: IndexPath) {
        tableItemSelected.accept(indexPath)
    }
}
