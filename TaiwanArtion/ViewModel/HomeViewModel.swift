//
//  HomeViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/18.
//

import Foundation
import FirebaseFirestore
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
    var newses: Observable<[NewsModel]> { get }
    var mainPhotos: Observable<[ExhibitionInfo]> { get }
    var hotExhibitions: Observable<[ExhibitionInfo]> { get }
    var allExhibitions: Observable<[ExhibitionInfo]> { get }
    var months: Observable<Month> { get }
    var habbys: Observable<HabbyItem?> { get }
    var items: Observable<Items> { get }
}

public protocol ViewDidLoad: AnyObject {
    var mainPhotos: Observable<[ExhibitionInfo]> { get }
    var hotExhibitions: Observable<[ExhibitionInfo]> { get }
    var newses: Observable<[NewsModel]> { get }
    var allExhibitions: Observable<[ExhibitionInfo]> { get }
}

public protocol HomeViewModelType: AnyObject {
    var inputs: HomeViewModelInput { get }
    var outputs: HomeViewModelOutput { get }
    var viewDidLoad: ViewDidLoad { get }
}

class HomeViewModel: HomeViewModelType, HomeViewModelInput, HomeViewModelOutput, ViewDidLoad {
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
    
    var viewDidLoad: ViewDidLoad { self }
    
    //MARK: - Store
    
    private let hotExhibitionRelay = BehaviorRelay<[ExhibitionInfo]>(value: [])
    
    private let mainPhotoRelay = BehaviorRelay<[ExhibitionInfo]>(value: [])
    
    private let newsRelay = BehaviorRelay<[NewsModel]>(value: [])
    
    private let allExhibitionRelay = BehaviorRelay<[ExhibitionInfo]>(value: [])
    
    var hotExhibitions: Observable<[ExhibitionInfo]> {
        return hotExhibitionRelay.asObservable()
    }
    
    var mainPhotos: Observable<[ExhibitionInfo]> {
        return mainPhotoRelay.asObservable()
    }
    
    var newses: Observable<[NewsModel]> {
        return newsRelay.asObservable()
    }
    
    var allExhibitions: Observable<[ExhibitionInfo]> {
        return allExhibitionRelay.asObservable()
    }
    
    //MARK: - CollectionViewSelectedRelay
    
    private let currentMonthsSubject = BehaviorSubject<Month>(value: .jan)
    
    private let currentHabbySubject = BehaviorSubject<HabbyItem?>(value: nil)
    
    private let currenItemSubject = BehaviorSubject<Items>(value: .highRank)
    
    var months: Observable<Month> { currentMonthsSubject.asObservable() }
    
    var habbys: Observable<HabbyItem?> { currentHabbySubject.asObservable() }
    
    var items: Observable<Items> { currenItemSubject.asObservable() }
    
    //MARK: - Intialization
    public init() {
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
                self.fetchDataKind(by: HabbyItem(rawValue: indexPath.row)!)
            })
            .disposed(by: disposeBag)
        
        itemSelected
            .subscribe(onNext: { indexPath in
                self.currenItemSubject.onNext(Items(rawValue: indexPath.row)!)
                self.fetchDataKind(by: Items(rawValue: indexPath.row)!)
            })
            .disposed(by: disposeBag)
        
        fetchDataRecentExhibition(by: 5)
    }
    
    //MARK: - Firebase
    
    private let firebase = FirebaseDatabase(collectionName: "exhibitions")

    func fetchDateKind(by month: Month) {
        firebase.readDocument(month: month.numberText) { data, error in
            if let error = error {
                print("error: \(error)")
            } else if data != nil{
                print("data:\(data)")
            }
        }
    }
    
    func fetchDataKind(by item: Items) {
        firebase.readDocument(item: item.text) { data, error in
            if let error = error {
                print("error:\(error)")
            } else if data != nil {
                print("data:\(data)")
            }
        }
    }
    
    //目前這個function應該是沒有什麼用
    func fetchDataKind(by habby: HabbyItem) {
        firebase.readDocument(habby: habby.titleText) { data, error in
            if let error = error {
                print("error:\(error)")
            } else if data != nil {
                print("data:\(data)")
//                self.allExhibitionRelay.accept(   －)
            }
        }
    }
    
    func fetchDataRecentExhibition(by count: Int) {
        firebase.getRandomDocuments(count: count) { data, error in
            if let error = error {
                print("error:\(error)")
            } else if let data = data {
                var info: [ExhibitionInfo] = []
                data.map { detailData in
                    guard let title = detailData["title"] as? String,
                          let image = detailData["imageUrl"] as? String,
                          let dateString = detailData["startDate"] as? String,
                          let agency = detailData["subUnit"] as? [String],
                          let official = detailData["showUnit"] as? String,
                          let showInfo = detailData["showInfo"] as? [[String: Any]],
                          let price = showInfo.first?["price"] as? String,
                          let time = showInfo.first?["time"] as? String,
                          let latitude = showInfo.first?["latitude"] as? String,
                          let longitude = showInfo.first?["longitude"] as? String,
                          let location = showInfo.first?["locationName"] as? String,
                          let address = showInfo.first?["location"] as? String else { return }
                    //這邊的image需要設計沒有相關圖片的圖
                    //分類的部分都會先給定一般
                    let exhibition = ExhibitionInfo(title: title, image: image == "" ? "noIdea" : "" , tag: "一般", dateString: dateString, time: time, agency: agency.map{$0}.joined(), official: official, telephone: "", advanceTicketPrice: price, unanimousVotePrice: price, studentPrice: price, groupPrice: price, lovePrice: price, free: "", earlyBirdPrice: "", city: String(location.prefix(3)), location: location, address: address, latitude: latitude, longtitude: longitude)
                    info.append(exhibition)
                }
                self.mainPhotoRelay.accept(info)
            }
        }
    }
    
    func fetchDataHotExhibition() {
        firebase.getHotDocument(count: 5) { data, error in
            if let error = error {
                print("error:\(error)")
            } else if let data = data {
                var info: [ExhibitionInfo] = []
                data.map { detailData in
                    guard let title = detailData["title"] as? String,
                          let image = detailData["imageUrl"] as? String,
                          let dateString = detailData["startDate"] as? String,
                          let agency = detailData["subUnit"] as? [String],
                          let official = detailData["showUnit"] as? String,
                          let showInfo = detailData["showInfo"] as? [[String: Any]],
                          let price = showInfo.first?["price"] as? String,
                          let time = showInfo.first?["time"] as? String,
                          let latitude = showInfo.first?["latitude"] as? String,
                          let longitude = showInfo.first?["longitude"] as? String,
                          let location = showInfo.first?["locationName"] as? String,
                          let address = showInfo.first?["location"] as? String else { return }
                    //這邊的image需要設計沒有相關圖片的圖
                    //分類的部分都會先給定一般
                    let exhibition = ExhibitionInfo(title: title, image: image == "" ? "noIdea" : "" , tag: "一般", dateString: dateString, time: time, agency: agency.map{$0}.joined(), official: official, telephone: "", advanceTicketPrice: price, unanimousVotePrice: price, studentPrice: price, groupPrice: price, lovePrice: price, free: "", earlyBirdPrice: "", city: String(location.prefix(3)), location: location, address: address, latitude: latitude, longtitude: longitude)
                    info.append(exhibition)
                }
                self.mainPhotoRelay.accept(info)
            }
        }
    }
}
