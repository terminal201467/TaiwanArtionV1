//
//  CollectViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/27.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

protocol CollectInput {
    
    //傳入現在正在的頁籤事件：收藏展覽、收藏展覽館、收藏新聞
    var currentCollectMenu: BehaviorRelay<Int> { get }
    
    //傳入現在正在的menu事件：全部展覽、今天開始、明天開始、本週開始
    var currentTimeMenu: BehaviorRelay<Int> { get }
    
    //進入搜尋狀態與否
    var isSearchMode: BehaviorRelay<Bool> { get }
    
    //輸入清除所有搜尋紀錄
    var removeAllSearchHistory: PublishRelay<Void> { get }
    
    //清除個別搜尋紀錄
    var removeSpecificSearchHistory: PublishRelay<Int> { get }
    
}

protocol CollectOutput {
    
    var currentSelectedCollectMenuIndex: Observable<Int> { get }
    
    var currentSelectedTimeMenu: Observable<Int> { get }
    
    //輸出所有收藏展覽的內容
    var currentExhibitionContent: BehaviorRelay<[ExhibitionInfo]> { get }
    
    //輸出曾經的搜尋紀錄
    var searchExhibitionContentHistory: BehaviorRelay<[String]> { get }
    
    //輸出收藏的展覽館
    var collectExhibitionHall: BehaviorRelay<[String]> { get }
    
    //輸出收藏的新聞
    var collectNews: BehaviorRelay<[News]> { get }
    
    //輸出新聞搜尋紀錄
    var collectNewsSearchHistory: BehaviorRelay<[String]> { get }
    
}

protocol CollectInputOutputType {
    
    var input: CollectInput { get }
    var output: CollectOutput { get }
    
}

class CollectViewModel: CollectInputOutputType, CollectInput, CollectOutput {
    
    private let disposeBag = DisposeBag()

    //MARK: - input
    
    var currentCollectMenu: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    
    var currentTimeMenu: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    
    var isSearchMode: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var removeAllSearchHistory: RxRelay.PublishRelay<Void> = PublishRelay()
    
    var removeSpecificSearchHistory: RxRelay.PublishRelay<Int> = PublishRelay()
    
    //MARK: - output
    
    var currentSelectedCollectMenuIndex: RxSwift.Observable<Int> {
        return currentSelectedTimeMenu.asObservable()
    }
    
    var currentSelectedTimeMenu: RxSwift.Observable<Int> {
        return currentTimeMenu.asObservable()
    }
    
    var currentExhibitionContent: RxRelay.BehaviorRelay<[ExhibitionInfo]> = BehaviorRelay(value: [])
    
    var searchExhibitionContentHistory: RxRelay.BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    var collectExhibitionHall: RxRelay.BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    var collectNews: RxRelay.BehaviorRelay<[News]> = BehaviorRelay(value: [])
    
    var collectNewsSearchHistory: RxRelay.BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    
    //MARK: -Firebase
    
    private let firebase = FirebaseDatabase(collectionName: "exhibitions")
    
    //MARK: -input、output
    var input: CollectInput { self }
    var output: CollectOutput { self }
    
    //MARK: -Initialization
    init() {
        AppLogger.enter(category: .viewModel)

        fetchFirebaseCollectData(by: 10) { infos in
            AppLogger.logViewModelEvent(
                viewModel: "CollectViewModel",
                event: "FetchCollectData",
                data: ["count": infos.count]
            )
            self.currentExhibitionContent.accept(infos)
        }

        AppLogger.exit(category: .viewModel)
    }
    
    //向firebase拿資料，藉由全部展覽、今天開始、明天開始、本週開始等四個頁籤去filter要拿取的資料
    private func fetchFirebaseCollectData(by count: Int, completion: @escaping (([ExhibitionInfo]) -> Void)) {
        firebase.getHotDocument(count: count) { data, error in
            if let error = error {
                AppLogger.error("獲取熱門展覽失敗", category: .viewModel, error: error)
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
    
    /// 向firebase fetch最近的搜尋紀錄
    /// - Parameters:
    ///   - userID: 使用者 ID
    ///   - completion: 完成回調
    private func fetchFirebaseCollectSearchingData(by userID: String, completion: @escaping (() -> Void)) {
        AppLogger.enter(category: .viewModel)

        let userFirebase = FirebaseDatabase(collectionName: "users")
        userFirebase.readDocument(documentID: userID) { [weak self] data, error in
            guard let self = self else { return }

            if let error = error {
                AppLogger.error("獲取搜尋紀錄失敗", category: .viewModel, error: error)
                completion()
                return
            }

            if let data = data,
               let searchHistory = data["collectSearchHistory"] as? [String] {
                AppLogger.logViewModelEvent(
                    viewModel: "CollectViewModel",
                    event: "FetchSearchHistory",
                    data: ["count": searchHistory.count]
                )
                self.searchExhibitionContentHistory.accept(searchHistory)
            } else {
                AppLogger.warning("搜尋紀錄為空", category: .viewModel)
                self.searchExhibitionContentHistory.accept([])
            }

            completion()
        }

        AppLogger.exit(category: .viewModel)
    }
    
    /// 向firebase fetch收藏的新聞資料
    /// - Parameters:
    ///   - userID: 使用者 ID
    ///   - completion: 完成回調，返回新聞陣列
    private func fetchFirebaseNewsData(by userID: String, completion: @escaping (([News]) -> Void)) {
        AppLogger.enter(category: .viewModel)

        let userFirebase = FirebaseDatabase(collectionName: "users")
        userFirebase.readDocument(documentID: userID) { [weak self] userData, error in
            guard let self = self else { return }

            if let error = error {
                AppLogger.error("獲取使用者收藏新聞 ID 失敗", category: .viewModel, error: error)
                completion([])
                return
            }

            guard let userData = userData,
                  let newsIDs = userData["collectNewsID"] as? [String],
                  !newsIDs.isEmpty else {
                AppLogger.warning("使用者無收藏新聞", category: .viewModel)
                completion([])
                return
            }

            AppLogger.info("找到 \(newsIDs.count) 個收藏新聞 ID", category: .viewModel)

            let newsFirebase = FirebaseDatabase(collectionName: "news")
            var newsList: [News] = []
            let dispatchGroup = DispatchGroup()

            for newsID in newsIDs {
                dispatchGroup.enter()
                newsFirebase.readDocument(documentID: newsID) { newsData, error in
                    defer { dispatchGroup.leave() }

                    if let error = error {
                        AppLogger.error("獲取新聞失敗: \(newsID)", category: .viewModel, error: error)
                        return
                    }

                    if let newsData = newsData,
                       let id = newsData["id"] as? String,
                       let title = newsData["title"] as? String,
                       let date = newsData["date"] as? String,
                       let author = newsData["author"] as? String,
                       let image = newsData["image"] as? String,
                       let description = newsData["description"] as? String {
                        let news = News(
                            id: id,
                            title: title,
                            date: date,
                            author: author,
                            image: image,
                            description: description
                        )
                        newsList.append(news)
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                AppLogger.logViewModelEvent(
                    viewModel: "CollectViewModel",
                    event: "FetchNewsData",
                    data: ["count": newsList.count]
                )
                self.collectNews.accept(newsList)
                completion(newsList)
            }
        }

        AppLogger.exit(category: .viewModel)
    }
    
    /// 根據當前選擇的時間篩選器來過濾展覽資料
    /// - Parameter currentMenuPage: 0-全部展覽, 1-今天開始, 2-明天開始, 3-本週開始
    private func fetchStore(currentMenuPage: Int) {
        AppLogger.enter(category: .viewModel)
        AppLogger.logViewModelEvent(
            viewModel: "CollectViewModel",
            event: "FilterExhibitions",
            data: ["menuPage": currentMenuPage]
        )

        let allExhibitions = currentExhibitionContent.value
        let filteredExhibitions: [ExhibitionInfo]

        switch currentMenuPage {
        case 0:
            // 全部展覽
            filteredExhibitions = allExhibitions
            AppLogger.debug("顯示全部展覽: \(allExhibitions.count) 個", category: .viewModel)

        case 1:
            // 今天開始
            filteredExhibitions = filterExhibitions(allExhibitions, startingFrom: Date())
            AppLogger.debug("顯示今天開始的展覽: \(filteredExhibitions.count) 個", category: .viewModel)

        case 2:
            // 明天開始
            if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                filteredExhibitions = filterExhibitions(allExhibitions, startingFrom: tomorrow)
                AppLogger.debug("顯示明天開始的展覽: \(filteredExhibitions.count) 個", category: .viewModel)
            } else {
                filteredExhibitions = []
                AppLogger.warning("無法計算明天日期", category: .viewModel)
            }

        case 3:
            // 本週開始
            if let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) {
                filteredExhibitions = filterExhibitions(allExhibitions, startingFrom: startOfWeek)
                AppLogger.debug("顯示本週開始的展覽: \(filteredExhibitions.count) 個", category: .viewModel)
            } else {
                filteredExhibitions = []
                AppLogger.warning("無法計算本週開始日期", category: .viewModel)
            }

        default:
            filteredExhibitions = allExhibitions
            AppLogger.warning("未知的 menuPage: \(currentMenuPage)，顯示全部展覽", category: .viewModel)
        }

        currentExhibitionContent.accept(filteredExhibitions)
        AppLogger.exit(category: .viewModel)
    }

    /// 過濾展覽：只保留指定日期之後開始的展覽
    /// - Parameters:
    ///   - exhibitions: 要過濾的展覽陣列
    ///   - startDate: 起始日期
    /// - Returns: 過濾後的展覽陣列
    private func filterExhibitions(_ exhibitions: [ExhibitionInfo], startingFrom startDate: Date) -> [ExhibitionInfo] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"

        return exhibitions.filter { exhibition in
            guard let exhibitionDate = dateFormatter.date(from: exhibition.dateString) else {
                AppLogger.warning("無法解析展覽日期: \(exhibition.dateString)", category: .viewModel)
                return false
            }
            return exhibitionDate >= startDate
        }
    }
    
}
