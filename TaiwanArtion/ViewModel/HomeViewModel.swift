//
//  HomeViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/18.
//

import Foundation
import FirebaseCore
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
            case .none: print("none")
            }
        })
        .disposed(by: disposeBag)
        
        fetchDataNewsExhibition(count: 5) { info in
            self.newsRelay.accept(info)
        }
    }
    
    //MARK: - Firebase
    
    private let exhibitionDataBase = FirebaseDatabase(collectionName: "exhibitions")
    
    private let newsDataBase = FirebaseDatabase(collectionName: "news")

    func fetchDateKind(by month: Month) {
        exhibitionDataBase.readDocument(month: month.numberText) { data, error in
            if let error = error {
                print("error: \(error)")
            } else if data != nil{
                print("data:\(data)")
            }
        }
    }
    
    //MARK: - Firebase fetch Method
    
    func fetchDataRecentExhibition(by count: Int, completion: @escaping (([ExhibitionInfo]) -> Void)) {
        exhibitionDataBase.getRandomDocuments(count: count) { data, error in
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
                    let exhibition = ExhibitionInfo(title: title, image: image == "" ? "defaultExhibition" : image , tag: "一般", dateString: dateString, time: time, agency: agency.map{$0}.joined(), official: official, telephone: "", advanceTicketPrice: price, unanimousVotePrice: price, studentPrice: price, groupPrice: price, lovePrice: price, free: "", earlyBirdPrice: "", city: String(location.prefix(3)), location: location, address: address, latitude: latitude, longtitude: longitude)
                    info.append(exhibition)
                }
                completion(info)
            }
        }
    }
    
    func fetchDataHotExhibition(by count: Int, completion: @escaping (([ExhibitionInfo]) -> Void)) {
        exhibitionDataBase.getHotDocument(count: count) { data, error in
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
                    let exhibition = ExhibitionInfo(title: title, image: image == "" ? "defaultExhibition" : image , tag: "一般", dateString: dateString, time: time, agency: agency.map{$0}.joined(), official: official, telephone: "", advanceTicketPrice: price, unanimousVotePrice: price, studentPrice: price, groupPrice: price, lovePrice: price, free: "", earlyBirdPrice: "", city: String(location.prefix(3)), location: location, address: address, latitude: latitude, longtitude: longitude)
                    info.append(exhibition)
                }
                completion(info)
            }
        }
    }
    
    func fetchDataNewsExhibition(count: Int, completion: @escaping (([News]) -> Void)) {
        newsDataBase.getRandomDocuments(count: count) { data, error in
            if let error = error {
                print("error:\(error)")
            } else if let data = data {
                var info: [News] = []
                data.map { newsData in
                    guard let title = newsData["title"] as? String,
                          let image = newsData["image"] as? String,
                          let date = newsData["date"] as? String,
                          let description = newsData["description"] as? String,
                          let id = newsData["id"] as? String,
                          let author = newsData["author"] as? String else { return }
                    //這邊的image需要設計沒有相關圖片的圖
                    //分類的部分都會先給定一般
                    let news = News(id: id, title: title, date: date, author: author, image: image == "" ? "defaultExhibition" : image, description: description)
                    info.append(news)
                }
                completion(info)
            }
        }
    }
    
    func fetchRecentExhibition(count: Int, completion: @escaping (([ExhibitionInfo]) -> Void)) {
        exhibitionDataBase.getRecentDocuments(count: count) { data, error in
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
                    let exhibition = ExhibitionInfo(title: title, image: image == "" ? "defaultExhibition" : image , tag: "一般", dateString: dateString, time: time, agency: agency.map{$0}.joined(), official: official, telephone: "", advanceTicketPrice: price, unanimousVotePrice: price, studentPrice: price, groupPrice: price, lovePrice: price, free: "", earlyBirdPrice: "", city: String(location.prefix(3)), location: location, address: address, latitude: latitude, longtitude: longitude)
                    info.append(exhibition)
                }
                completion(info)
            }
        }
    }
    
}
