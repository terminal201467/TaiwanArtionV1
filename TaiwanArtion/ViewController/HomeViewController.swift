//
//  HomeViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import UIKit

enum YearCell: Int, CaseIterable {
    case monthCell = 0, habbyCell, mainPhotoCell
}

enum HotCell: Int, CaseIterable {
    case hotExhibition = 0
    var title: String {
        switch self {
        case .hotExhibition: return "熱門展覽"
        }
    }
}

enum NewsCell: Int, CaseIterable {
    case newsExhibition = 0
    var title: String {
        switch self {
        case .newsExhibition: return "藝文新聞"
        }
    }
}

enum AllCell: Int, CaseIterable {
    case allExhibition = 0
    var title: String {
        switch self {
        case .allExhibition: return "所有展覽"
        }
    }
}

class HomeViewController: UIViewController {

    private let homeView = HomeView()
    
    private let viewModel = HomeViewModel.shared
    
    override func loadView() {
        super.loadView()
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTableView()
    }
    
    private func setNavigationBar() {
        navigationItem.hidesBackButton = true
//        let backButton = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .done, target: self, action: #selector(backAction))
//        navigationItem.backBarButtonItem = backButton
    }
    
    private func setTableView() {
        homeView.tableView.delegate = self
        homeView.tableView.dataSource = self
    }
    
//    @objc private func backAction() {
//        navigationController?.popViewController(animated: true)
//    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch HomeSections(rawValue: section) {
        case .year: return YearCell.allCases.count
        case .hot: return HotCell.allCases.count
        case .news: return NewsCell.allCases.count
        case .all: return AllCell.allCases.count
        case .none: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch HomeSections(rawValue: indexPath.section) {
        case .year:
            switch YearCell(rawValue: indexPath.row) {
            case .monthCell:
                let cell = tableView.dequeueReusableCell(withIdentifier: MonthTableViewCell.reuseIdentifier, for: indexPath) as! MonthTableViewCell
                cell.selectionStyle = .none
                return cell
            case .habbyCell:
                let cell = tableView.dequeueReusableCell(withIdentifier: HabbyTableViewCell.reuseIdentifier, for: indexPath) as! HabbyTableViewCell
                return cell
            case .mainPhotoCell:
                let cell = tableView.dequeueReusableCell(withIdentifier: MainPhotosTableViewCell.reuseIdentifier, for: indexPath) as! MainPhotosTableViewCell
                cell.selectionStyle = .none
                cell.mainPhotos = self.viewModel.mainPhoto
                cell.pushToViewController = { exhibition in
                    let viewController = ExhibitionCardViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                return cell
            case .none: return UITableViewCell()
            }
        case .hot:
            switch HotCell(rawValue: indexPath.row) {
            case .hotExhibition:
                let cell = tableView.dequeueReusableCell(withIdentifier: HotHxhibitionTableViewCell.reuseIdentifier, for: indexPath) as! HotHxhibitionTableViewCell
                cell.pushToViewController = { exhibition in
                    let viewController = ExhibitionCardViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                cell.selectionStyle = .none
                return cell
            case .none: return UITableViewCell()
            }
        case .news:
            switch NewsCell(rawValue: indexPath.row) {
            case .newsExhibition:
                let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.reuseIdentifier, for: indexPath) as! NewsTableViewCell
                cell.selectionStyle = .none
                cell.pushToViewController = { news in
                    let viewController = NewsViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
//                    viewController.backAction = {
//                        self.navigationController?.popViewController(animated: true)
//                    }
                }
                return cell
            case .none: return UITableViewCell()
            }
        case .all:
            switch AllCell(rawValue: indexPath.row) {
            case .allExhibition:
                let cell = tableView.dequeueReusableCell(withIdentifier: AllExhibitionTableViewCell.reuseIdentifier, for: indexPath) as!
                AllExhibitionTableViewCell
                cell.selectionStyle = .none
                cell.backgroundColor = .whiteGrayColor
                cell.pushToViewController = { exhibition in
                    let viewController = ExhibitionCardViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                return cell
            case .none: return UITableViewCell()
            }
        case .none: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch HomeSections(rawValue: section) {
        case .year:
            let yearView = TitleHeaderView()
            yearView.configureYear(with: "2023")
            return yearView
        case .hot:
            let hotView = TitleHeaderView()
            hotView.configureTitle(with: HomeSections.hot.title)
            return hotView
        case .news:
            let newsView = TitleHeaderView()
            newsView.configureTitle(with: HomeSections.news.title)
            newsView.checkMoreButton.isHidden = false
            return newsView
        case .all:
            let allView = TitleHeaderView()
            allView.contentView.backgroundColor = .whiteGrayColor
            allView.configureTitle(with: HomeSections.all.title)
            allView.backgroundColor = .whiteGrayColor
            return allView
        case .none: return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch HomeSections(rawValue: section) {
        case .year: return 50.0
        case .news: return 50.0
        case .hot: return 20.0
        case .all: return 50.0
        case .none: return 50.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch HomeSections(rawValue: indexPath.section) {
        case .year:
            switch YearCell(rawValue: indexPath.row) {
            case .monthCell: return 50.0
            case .habbyCell: return 140.0
            case .mainPhotoCell: return 280.0
            case .none: return 0
            }
        case .hot:
            switch HotCell(rawValue: indexPath.row) {
            case .hotExhibition: return 580.0
            case .none: return 0
            }
        case .news:
            switch NewsCell(rawValue: indexPath.row) {
            case .newsExhibition: return 268.0
            case .none: return 0
            }
        case .all:
            switch AllCell(rawValue: indexPath.row) {
            case .allExhibition: return 844.0
            case .none: return 0
            }
        case .none: return 0
        }
    }
}
