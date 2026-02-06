//
//  SearchViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/31.
//

import Foundation

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


class SearchViewModel {
    
    //MARK: - data
    
    static let shared = SearchViewModel()
    
    private var store: [ExhibitionInfo] = [
        ExhibitionInfo(title: "未來身體-超自然雕塑", image: "noIdea", tag: "雕塑", dateString: "2023.05.18 - 05.20", time: "", agency: "", official: "", telephone: "00427022969", advanceTicketPrice: "199", unanimousVotePrice: "199", studentPrice: "199", groupPrice: "199", lovePrice: "199", free: "199", earlyBirdPrice: "199", city: "台南市", location: "台南市", address: "", equipments: ["","","",""], latitude: "", longtitude: "", evaluation: .init(number: 0, allCommentCount: 0, allCommentStar: 0, allCommentRate: [.init(contentRichness: 0, equipment: 0, geoLocation: 0, price: 0, service: 0)], allCommentContents: [.init(userImage: "", userName: "", star: 0, commentDate: "", commentRate: [.init(contentRichness: 0, equipment: 0, geoLocation: 0, price: 0, service: 0)])])),
        ExhibitionInfo(title: "未來身體-超自然雕塑", image: "noIdea", tag: "雕塑", dateString: "2023.05.18 - 05.20", time: "", agency: "", official: "", telephone: "00427022969", advanceTicketPrice: "199", unanimousVotePrice: "199", studentPrice: "199", groupPrice: "199", lovePrice: "199", free: "199", earlyBirdPrice: "199", city: "台南市", location: "台南市", address: "", equipments: ["","","",""], latitude: "", longtitude: "", evaluation: .init(number: 0, allCommentCount: 0, allCommentStar: 0, allCommentRate: [.init(contentRichness: 0, equipment: 0, geoLocation: 0, price: 0, service: 0)], allCommentContents: [.init(userImage: "", userName: "", star: 0, commentDate: "", commentRate: [.init(contentRichness: 0, equipment: 0, geoLocation: 0, price: 0, service: 0)])])),
        ExhibitionInfo(title: "未來身體-超自然雕塑", image: "noIdea", tag: "雕塑", dateString: "2023.05.18 - 05.20", time: "", agency: "", official: "", telephone: "00427022969", advanceTicketPrice: "199", unanimousVotePrice: "199", studentPrice: "199", groupPrice: "199", lovePrice: "199", free: "199", earlyBirdPrice: "199", city: "台南市", location: "台南市", address: "", equipments: ["","","",""], latitude: "", longtitude: "", evaluation: .init(number: 0, allCommentCount: 0, allCommentStar: 0, allCommentRate: [.init(contentRichness: 0, equipment: 0, geoLocation: 0, price: 0, service: 0)], allCommentContents: [.init(userImage: "", userName: "", star: 0, commentDate: "", commentRate: [.init(contentRichness: 0, equipment: 0, geoLocation: 0, price: 0, service: 0)])]))
    ]
    
    private var filterStore: [ExhibitionInfo] = []
    
    private var hotSearch: [String] = ["小王子","悲慘世界","久石讓","貓之日","蒙娜麗莎的探險之旅"]
    
    private var isSearchModeOn: Bool = false {
        didSet {
            restartTheCurrentItem()
        }
    }
    
    var getCurrentItem : ((Int?) -> (Void))?
    
    private var currentItem: Int? {
        didSet {
            AppLogger.debug("currentItem:\(String(describing: currentItem))", category: .viewModel)
            self.getCurrentItem?(currentItem)
            //清空選的
        }
    }
    
    //MARK: -SearchAction
    func filterSearchTextFiled(withText searchText: String) {
        AppLogger.debug("input SearchFilter:\(searchText)", category: .viewModel)
        let filterResult = store.filter{$0.title.contains(searchText)}
        AppLogger.debug("filterResult:\(filterResult)", category: .viewModel)
        filterStore = filterResult
    }
    
    //MARK: -CurrentItems
    public func restartTheCurrentItem() {
        currentItem = nil
    }
    
    public func changedModeWith(isSearching: Bool) {
        isSearchModeOn = isSearching
        AppLogger.debug("isSearchModeOn:\(isSearchModeOn)", category: .viewModel)
    }
    
    public func changeCurrentItem(by itemIndex: Int) {
        currentItem = itemIndex
    }
    
    //MARK: - CollectionView methods
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
        currentItem = indexPath.row
        AppLogger.debug("collectionViewDidSelectedRowAt:\(String(describing: currentItem))", category: .viewModel)
    }
    
    //Selected CollectionView
    func selectedCollectionViewAllCell(bySection section: Int) {
        AppLogger.debug("全選TableViewSection:\(section)", category: .viewModel)

    }
    
    //MARK: - TableView methods
    
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
            //hot search
            return 1
        }
    }
    
    func searchModeTableViewCellForRowAt(indexPath: IndexPath) -> [ExhibitionInfo] {
        currentItem = 0
        switch AlreadyFilter(rawValue: currentItem!) {
        case .result: return filterStore
        case .news: return filterStore
        case .nearest: return filterStore
        case .filterIcon: return filterStore
        case .none: return filterStore
        }
    }
    
    func unSearchModeTableViewCellForRowAt(indexPath: IndexPath) -> [String] {
        if currentItem == nil {
            return hotSearch.map {$0}
        } else {
            switch FilterType(rawValue: currentItem!) {
            case .city:
                switch Area(rawValue: indexPath.section) {
                case .north: return NorthernCity.allCases.map{$0.text}
                case .middle: return CentralCity.allCases.map{$0.text}
                case .south: return SouthernCity.allCases.map{$0.text}
                case .east: return EasternCity.allCases.map{$0.text}
                case .island: return OutlyingIslandCity.allCases.map{$0.text}
                case .correct: return [""]
                case .none: return hotSearch.map {$0}
                }
            case .place: return Place.allCases.map{$0.title}
            case .date: return DateKind.allCases.map{$0.text}
            case .price: return Price.allCases.map{$0.text}
            case .none: return hotSearch.map {$0}
            }
        }
    }
    
    func tableViewDidSelectedRowAt(indexPath: IndexPath) {
        
    }
    
    
}
