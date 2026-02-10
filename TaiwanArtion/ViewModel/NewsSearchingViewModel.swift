//
//  NewsSearchingViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/28.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

enum NewsFilterItem: Int, CaseIterable {
    case recentNews = 0, popularNews, recentDate
    var text: String {
        switch self {
        case .recentNews: return "最新新聞"
        case .popularNews: return "人氣新聞"
        case .recentDate: return "最近日期"
        }
    }
}

protocol NewsSearchingInput {
    
    //輸入月份
    var inputMonth: PublishRelay<Month> { get }
    
    //輸入選擇嗜好
    var inputSelectHabby: PublishRelay<HabbyItem> { get }
    
    //輸入藝文新聞欄位選擇篩選資料項目
    var inputNewsFilter: PublishRelay<NewsFilterItem> { get }
    
    //輸入搜尋關鍵字
    var inputSearchingText: PublishRelay<String> { get }
    
    //輸入完成輸入
    var inputFinishEditing: PublishSubject<Void> { get }
    
}

protocol NewsSearchingOutput {
    
    //輸出月份
    var outputMonth: BehaviorRelay<Month> { get }
    
    //輸出選擇嗜好
    var outputHabby: BehaviorRelay<HabbyItem> { get }
    
    //輸出選擇嗜好
    var outputNewsFilter: BehaviorRelay<NewsFilterItem> { get }
    
    //輸出藝文新聞篩選過的新聞
    var outputFilterNews: BehaviorRelay<[News]> { get }
    
    //輸出新聞搜尋紀錄
    var outputNewsSearchingHistory: BehaviorRelay<[String]> { get }
    
    var outputIsSearchingMode: BehaviorRelay<Bool> { get }
    
}

protocol NewsSearchingType {
    
    var input: NewsSearchingInput { get }
    
    var output: NewsSearchingOutput { get }
    
}

class NewsSearchingViewModel: NewsSearchingType, NewsSearchingInput, NewsSearchingOutput {
    
    private let disposeBag = DisposeBag()
    
    static let shared = NewsSearchingViewModel()
    
    //MARK: -Input、Output
    var input: NewsSearchingInput { self }
    
    var output: NewsSearchingOutput { self }
    
    //MARK: -Input
    
    var inputMonth: PublishRelay<Month> = PublishRelay()
    
    var inputSelectHabby: PublishRelay<HabbyItem> = PublishRelay()
    
    var inputNewsFilter: PublishRelay<NewsFilterItem> = PublishRelay()
    
    var inputSearchingText: PublishRelay<String> = PublishRelay()
    
    var inputFinishEditing: PublishSubject<Void> = PublishSubject()
    
    //MARK: -Output
    
    var outputMonth: RxRelay.BehaviorRelay<Month> = BehaviorRelay(value: .jan)
    
    var outputHabby: RxRelay.BehaviorRelay<HabbyItem> = BehaviorRelay(value: .painting)
    
    var outputNewsFilter: RxRelay.BehaviorRelay<NewsFilterItem> = BehaviorRelay(value: .recentNews)
    
    var outputFilterNews: RxRelay.BehaviorRelay<[News]> = BehaviorRelay(value: [])
    
    var outputNewsSearchingHistory: RxRelay.BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    var outputIsSearchingMode: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    //MARK: -UserDefault
    
    private let userDefaultInterface = UserDefaultInterface.shared
    
    private var historySearchingObservable: Observable<[String]?> {
        return Observable.just(getSearchingHistoryFromUserDefault())
    }
    
    //MARK: -Firebase
    
    private let firebase = FirebaseDatabase(collectionName: "news")
    
    //MARK: - Initialization
    init() {
        //輸入月份
        inputMonth.asObservable()
            .bind(to: outputMonth)
            .disposed(by: disposeBag)
        
        //輸入嗜好
        inputSelectHabby.asObservable()
            .map({ [weak self] habby -> [News] in
                guard let self = self else { return [] }
                self.outputHabby.accept(habby)
                return self.getNewsByHabby(habby: habby)
            })
            .bind(to: outputFilterNews)
            .disposed(by: disposeBag)

        //輸入篩選條件
        inputNewsFilter.asObservable()
            .map({ [weak self] filter -> [News] in
                guard let self = self else { return [] }
                self.outputNewsFilter.accept(filter)
                return self.getNewsBySelected(selectedItem: filter)
            })
            .bind(to: outputFilterNews)
            .disposed(by: disposeBag)

        //輸入文字篩選暫存歷史關鍵字
        inputSearchingText.asObservable()
            .filter { [weak self] text in
                guard let self = self else { return false }
                return (self.getSearchingHistoryFromUserDefault() ?? []).contains(text)
            }
            .subscribe(onNext: { [weak self] filteredText in
                guard let self = self else { return }
                var currentHistory = self.outputNewsSearchingHistory.value
                currentHistory.append(filteredText)
                self.outputNewsSearchingHistory.accept(currentHistory)
            })
            .disposed(by: disposeBag)
            
    }
    
    private func getNewsByMonthFilter(month: Month) -> [News] {
        //月份篩選
        return []
    }
    
    private func getNewsByHabby(habby: HabbyItem) -> [News] {
        //嗜好篩選
        return []
    }
    
    private func getNewsBySelected(selectedItem: NewsFilterItem) -> [News] {
        //新聞選擇條件
        return []
    }
    
    private func getSearchingHistoryFromUserDefault() -> [String]? {
        return userDefaultInterface.getStoreNewsSearchHistory()
    }
}
