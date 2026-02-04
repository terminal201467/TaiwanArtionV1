//
//  NearViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/16.
//

import Foundation
import MapKit
import RxSwift
import RxRelay

protocol NearViewModelInput {
    //篩選Action：營業中、最高評價、距離最近
    var filterActionSubject: PublishSubject<Void> { get }
    
    //input附近展覽館
    var inputNearExhibitionHall: BehaviorRelay<[MKMapItem]> { get }
    
    //input附近展覽
    var inputNearExhibition: BehaviorRelay<String> { get }
    
    //input搜尋關鍵字（展覽館、展覽）
    var inputSearchKeyword: BehaviorRelay<String> { get }
    
    //確認搜尋ActionSubject
    var searchActionSubject: PublishSubject<Void> { get }
    
    //清除搜尋紀錄ActionSubject
    var clearSearchRecordSubject: PublishSubject<Void> { get }
    
    //清除單一搜尋紀錄ActionSubject
    var clearCertainSearchRecordSubject: PublishSubject<Void> { get }
    
    //儲存搜尋紀錄ActionSubject
    var storeSearchRecordsSubject: PublishSubject<Void> { get }
    
    //取得最近的展覽ActionSubject
    var getRecentExhibitionActionSubject: PublishSubject<Void> { get }
    
    //取得現在位置ActionSubject
    var getCurrentLocationActionSubject: PublishSubject<Void> { get }
    
    //查看位置ActionSubject
    var lookUpLocationActionSubject: PublishSubject<Void> { get }
    
    //查看展覽館展覽ActionSubject
    var lookUpExhibitionHallActionSubject: PublishSubject<Void> { get }
    
    //向右滑動展覽館ActionSubject
    var rightSwipeExhibitionActionSubject: PublishSubject<Void> { get }
    
    //向左滑動展覽館ActionSubject
    var leftSwipeExhibitionActionSubject: PublishSubject<Void> { get }
    
    //紀錄選取的MapItem
    var inputSelectedAnnotation: PublishRelay<MKAnnotation> { get }
}

protocol NearViewModelOutput {
    
    //篩選後的（展覽館）資料
    var outputExhibitionHall: BehaviorRelay<[ExhibitionHallInfo]> { get }
    
    //篩選後的（展覽）資料
    var outputExhibitionInfo: BehaviorRelay<[ExhibitionInfo]> { get }
    
    //輸出MapItem
    var outputMapItem: BehaviorRelay<[MKMapItem]> { get }
    
    //搜尋紀錄
    var outputSearchHistory: BehaviorRelay<[String]> { get }
    
    var outputSelectedAnnotation: PublishRelay<MKAnnotation> { get }
    
}

protocol NearInputOutputType {
    
    var input: NearViewModelInput { get }
    
    var output: NearViewModelOutput { get }
    
}

class NearViewModel: NearInputOutputType, NearViewModelInput, NearViewModelOutput {
    
    private let disposeBag = DisposeBag()
    
    static let shared = NearViewModel()
    
    private let locationInterface = LocationInterface.shared
    
    //MARK: -Repository

    private let exhibitionRepository: ExhibitionRepository

    //MARK: -UserDefault

    private let userDefault = UserDefaultInterface.shared
    
    //MARK: -input
    
    var filterActionSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var inputNearExhibitionHall: RxRelay.BehaviorRelay<[MKMapItem]> = BehaviorRelay(value: [])
    
    var inputNearExhibition: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var inputSearchKeyword: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var searchActionSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var clearSearchRecordSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var clearCertainSearchRecordSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var recordSearchRecordsSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var getRecentExhibitionActionSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var getCurrentLocationActionSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var lookUpLocationActionSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var lookUpExhibitionHallActionSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var rightSwipeExhibitionActionSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var leftSwipeExhibitionActionSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var inputSelectedAnnotation: PublishRelay<MKAnnotation> = PublishRelay()
    
    //MARK: -output
    
    var storeSearchRecordsSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    var outputExhibitionHall: RxRelay.BehaviorRelay<[ExhibitionHallInfo]> = BehaviorRelay(value: [])
    
    var outputExhibitionInfo: RxRelay.BehaviorRelay<[ExhibitionInfo]> = BehaviorRelay(value: [])
    
    var outputSearchHistory: RxRelay.BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    var outputMapItem: BehaviorRelay<[MKMapItem]> = BehaviorRelay(value: [])
    
    var outputSelectedAnnotation: PublishRelay<MKAnnotation> = PublishRelay()
    
    //MARK: -input/output
    
    var input: NearViewModelInput { self }
    
    var output: NearViewModelOutput { self }
    
    var mapItems: [MKMapItem] = []
    
    init(exhibitionRepository: ExhibitionRepository = FirebaseExhibitionRepository()) {
        self.exhibitionRepository = exhibitionRepository
        storeSearchRecordsSubject
            .subscribe(onNext: {
                self.storeSearchHistory(history: [self.inputSearchKeyword.value])
            })
            .disposed(by: disposeBag)
        
        outputSearchHistory.accept(getSearchHistory() ?? [])
        
        inputNearExhibitionHall
            .subscribe(onNext: { mapItems in
                self.outputMapItem.accept(mapItems)
                self.outputExhibitionHall.accept(self.transferExhibition(mapItems: mapItems))
            })
            .disposed(by: disposeBag)
        
        outputSelectedAnnotation = inputSelectedAnnotation
        
        ///這邊的資料是全部的資料，是沒有經過附近5000M推算的
        getFirebaseExhibitionInfo(count: 20) { infos in
            self.outputExhibitionInfo.accept(infos)
        }
//        outputExhibitionInfo.accept(getNearCurrentExhibition(count: 20))
    }
    
    //MARK: - Repository Fetch

    private func getFirebaseExhibitionInfo(count: Int, completion: @escaping ([ExhibitionInfo]) -> Void ) {
        exhibitionRepository.getRecentExhibitions(count: count) { result in
            switch result {
            case .success(let exhibitions):
                completion(exhibitions)
            case .failure(let error):
                AppLogger.error("error:\(error)", category: .viewModel, error: error)
            }
        }
    }
    
    func getNearCurrentExhibition(count: Int) -> [ExhibitionInfo] {
        var filterInfo: [ExhibitionInfo] = []
        self.getFirebaseExhibitionInfo(count: count) { infos in
            filterInfo = infos
        }
        return filterInfo
    }
    
    func transferExhibition(mapItems: [MKMapItem]) -> [ExhibitionHallInfo] {
        let exhibitionHallInfos = mapItems.map {ExhibitionHallInfo(hallImage: "",
                                                                   title: $0.placemark.title ?? "",
                                                                   location: $0.placemark.countryCode ?? "",
                                                                   locationCoordinate: $0.placemark.coordinate ?? CLLocationCoordinate2D(),
                                                                  time: "",
                                                                   telephone: $0.phoneNumber ?? "",
                                                                  adress: "",
                                                                  webSite: "")}
        return exhibitionHallInfos
    }
    
    private func storeSearchHistory(history: [String]) {
        userDefault.setStoreSearchHistory(searchHistory: history)
    }
    
    func getSearchHistory() -> [String]? {
        return userDefault.getStoreSearchHistory()
    }
    
}
