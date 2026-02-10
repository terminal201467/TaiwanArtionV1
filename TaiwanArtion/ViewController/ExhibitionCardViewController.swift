//
//  ExhibitionCardViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/25.
//

import UIKit
import RxSwift
import RxCocoa

//MARK: - TableViewSection and Cell settings
enum OverViewSection: Int, CaseIterable {
    case overview = 0
    var title: String {
        switch self {
        case .overview: return "展覽總覽"
        }
    }
    var height: CGFloat {
        return 50.0
    }
}

enum IntroduceSection: Int, CaseIterable {
    case intro = 0
    var title: String {
        switch self {
        case .intro: return "展覽簡介"
        }
    }
    var height: CGFloat {
        return 50.0
    }
}

enum TicketPriceSection: Int, CaseIterable {
    case price = 0
    var title: String {
        switch self {
        case .price: return "展覽票價"
        }
    }
    var height: CGFloat {
        return 50.0
    }
}

enum LocationSection: Int, CaseIterable {
    case location = 0, equipment, map, route
    var title: String {
        switch self {
        case .location: return "展覽地點"
        case .equipment: return "展覽設施"
        case .map: return ""
        case .route: return "規劃路線"
        }
    }
    
    var height: CGFloat {
        switch self {
        case .location: return 40.0
        case .equipment: return 60.0
        case .map: return 450.0
        case .route: return 30.0
        }
    }
}

enum EvaluationSection: Int, CaseIterable {
    case allComment = 0
    var headerHeight: CGFloat {
        return 330.0
    }
    
    var cellHeight: CGFloat {
        return 330.0
    }
}

enum OverViewContentCell: Int, CaseIterable {
    case kind = 0, date, time, agency, official, telephone
    var title: String {
        switch self {
        case .kind: return "展覽類別"
        case .date: return "展覽日期"
        case .time: return "營業時間"
        case .agency: return "主辦單位"
        case .official: return "展覽官網"
        case .telephone: return "展覽電話"
        }
    }
}

enum IntroduceContentCell: Int, CaseIterable {
    case content = 0
}

enum TicketPriceContentCell: Int, CaseIterable {
    case advanceTicketPrice = 0, unanimousVotePrice, studentPrice, groupPrice, lovePrice, free, earlyBirdPrice
    var text: String {
        switch self {
        case .advanceTicketPrice: return "預售票"
        case .unanimousVotePrice: return "全票"
        case .studentPrice: return "學生票"
        case .groupPrice: return "團體票"
        case .lovePrice: return "愛心票"
        case .free: return "免票入場"
        case .earlyBirdPrice: return "早鳥優惠票"
        }
    }
}

enum LocationContentCell: Int, CaseIterable {
    case location = 0, address
    var title: String {
        switch self {
        case .location: return "展覽地點"
        case .address: return "展覽地址"
        }
    }
}


class ExhibitionCardViewController: UIViewController {

    private let exhibitionCardView = ExhibitionCardView()

    private let viewModel = ExhibitionCardViewModel.shared

    private let disposeBag = DisposeBag()

    private let dataSource = ExhibitionCardDataSource()

    //MARK: - LifeCycle
    override func loadView() {
        super.loadView()
        view = exhibitionCardView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setCardItems()
        setBackAction()
        setTitleAndBackground()
        setDataSourceActions()
    }

    private func setTableView() {
        exhibitionCardView.tableView.delegate = dataSource
        exhibitionCardView.tableView.dataSource = dataSource
    }

    private func setCardItems() {
        exhibitionCardView.exhibitionCardItems.chooseItem = { [weak self] chooseItem in
            guard let self = self else { return }
            self.dataSource.selectedItem = chooseItem
            self.exhibitionCardView.tableView.reloadData()
        }
    }

    private func setDataSourceActions() {
        dataSource.navigateToEvaluate = { [weak self] in
            guard let self = self else { return }
            let viewController = EvaluateViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func setTitleAndBackground() {
        exhibitionCardView.configure(image: "exhibitionCardBackground", title: viewModel.title)
    }

    private func setBackAction() {
        exhibitionCardView.backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

