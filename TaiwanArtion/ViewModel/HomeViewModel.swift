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
    
    //MARK: - CollectionViewSelectedRelay
    
    private let currentMonthsSubject = BehaviorSubject<Month>(value: .jan)
    
    private let currentHabbySubject = BehaviorSubject<HabbyItem?>(value: nil)
    
    private let currenItemSubject = BehaviorSubject<Items>(value: .newest)
    
    var months: Observable<Month> { currentMonthsSubject.asObservable() }
    
    var habbys: Observable<HabbyItem?> { currentHabbySubject.asObservable() }
    
    var items: Observable<Items> { currenItemSubject.asObservable() }
    
    //MARK: - Intialization
    public init(
        exhibitionRepository: ExhibitionRepository = FirebaseExhibitionRepository(),
        newsRepository: NewsRepository = FirebaseNewsRepository()
    ) {
        self.exhibitionRepository = exhibitionRepository
        self.newsRepository = newsRepository
        //input
        monthSelected
            .subscribe(onNext: { indexPath in
                self.currentMonthsSubject.onNext(Month(rawValue: indexPath.row)!)
                self.fetchDateKind(by: Month(rawValue: indexPath.row)!)
            })
            .disposed(by: disposeBag)
        
        habbySelected
            .subscribe(onNext: { indexPath in
                self.currentHabbySubject.onNext(HabbyItem(rawValue: indexPath.row))
            })
            .disposed(by: disposeBag)
        
        itemSelected
            .subscribe(onNext: { indexPath in
                self.currenItemSubject.onNext(Items(rawValue: indexPath.row)!)
                self.allExhibitionSelected.onNext(indexPath)
            })
            .disposed(by: disposeBag)
        
        //主要圖像
        fetchRecentExhibition(count: 5) { info in
            self.mainPhotoRelay.accept(info)
            
        }
        
        //熱門展覽
        fetchRecentExhibition(count: 8) { info in
            self.hotExhibitionRelay.accept(info)
        }
        
        
        allExhibitionSelected.subscribe(onNext: { indexPath in
            switch Items(rawValue: indexPath.row) {
            case .newest:
                self.fetchRecentExhibition(count: 10) { info in
                    self.allExhibitionRelay.accept(info)
            }
            case .popular:
                self.fetchDataHotExhibition(by: 10) { info in
                    self.allExhibitionRelay.accept(info)
                }
            case .highRank:
                self.fetchDataHotExhibition(by: 10) { info in
                    self.allExhibitionRelay.accept(info)
                }
            case .recent:
                self.fetchRecentExhibition(count: 10) { info in
                    self.allExhibitionRelay.accept(info)
                }
            case .none: AppLogger.debug("none", category: .viewModel)
            }
        })
        .disposed(by: disposeBag)
        
        fetchDataNewsExhibition(count: 5) { info in
            self.newsRelay.accept(info)
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
    
}
