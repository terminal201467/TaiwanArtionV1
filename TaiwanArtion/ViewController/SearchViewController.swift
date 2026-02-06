//
//  SearchViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/31.
//

import UIKit

class SearchViewController: UIViewController {

    private let viewModel = SearchViewModel.shared
    
    private let searchView = SearchView()
    
    private var isSearchModeViewOn: Bool = false {
        didSet {
            self.viewModel.restartTheCurrentItem()
            self.searchView.filterContentCollectionView.reloadData()
            self.searchView.filterTableView.reloadData()
        }
    }
    
    var currentSelectedItem: Int? {
        didSet {
            AppLogger.debug("currentSelectedItem:\(String(describing: currentSelectedItem))", category: .ui)
            self.hiddenLocation()
            self.searchView.filterTableView.reloadData()
            self.searchView.filterContentCollectionView.reloadData()
        }
    }
    
    private let searchFilterView = BottomUpPopUpView(frame: .infinite, type: .search)
    
    private lazy var popUpViewController: PopUpViewController = {
        let popUpViewController = PopUpViewController(popUpView: searchFilterView)
        popUpViewController.modalPresentationStyle = .overFullScreen
        popUpViewController.modalTransitionStyle = .coverVertical
        searchFilterView.dismissFromController = {
            popUpViewController.dismiss(animated: true)
        }
        return popUpViewController
    }()
    
    //MARK: - LifeCycle
    override func loadView() {
        super.loadView()
        view = searchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTableView()
        setCollectionView()
        setSearchindModeChanged()
        viewModel.restartTheCurrentItem()
        searchView.backAction = {
            self.navigationController?.popViewController(animated: true)
        }
        setCurrentItem()
        setSearchFilterSelected()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        isSearchModeViewOn = false
        searchView.filterTableView.endEditing(true)
        searchView.filterContentCollectionView.endEditing(true)
    }
    
    //MARK: - Methods
    private func setNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: .init(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.titleView = searchView.searchBar
    }
    
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setSearchFilterSelected() {
        searchFilterView.searchSelectedItem = { item in
            AppLogger.debug("item:\(item.text)", category: .ui)
        }
    }
    
    private func hiddenLocation() {
        if isSearchModeViewOn {
            searchView.hiddenThelocationStack(isHidden: true)
        } else {
            if currentSelectedItem == nil {
                searchView.hiddenThelocationStack(isHidden: false)
            } else {
                if let selectedItem = currentSelectedItem {
                    if selectedItem == 0 {
                        searchView.hiddenThelocationStack(isHidden: false)
                    } else {
                        searchView.hiddenThelocationStack(isHidden: true)
                    }
                }
            }
        }
    }
    
    private func setTableView() {
        searchView.filterTableView.delegate = self
        searchView.filterTableView.dataSource = self
    }
    
    private func setCollectionView() {
        searchView.filterContentCollectionView.dataSource = self
        searchView.filterContentCollectionView.delegate = self
    }
    
    private func setSearchindModeChanged() {
        searchView.isBeginSearchMode = { isBegan in
            self.viewModel.changedModeWith(isSearching: isBegan)
            self.isSearchModeViewOn = isBegan
            self.searchView.filterContentCollectionView.reloadData()
            self.searchView.filterTableView.reloadData()
        }
        
        searchView.searchValueChanged = { changed in
            AppLogger.debug("changed:\(changed)", category: .ui)
            self.viewModel.filterSearchTextFiled(withText: changed)
            self.searchView.filterContentCollectionView.reloadData()
            self.searchView.filterTableView.reloadData()
            
        }
        
        searchView.endInputText = { endText in
            AppLogger.debug("finalSearch:\(endText)", category: .ui)
            self.viewModel.filterSearchTextFiled(withText: endText)
            self.searchView.filterContentCollectionView.reloadData()
            self.searchView.filterTableView.reloadData()
        }
    }
    
    private func setCurrentItem() {
        viewModel.getCurrentItem = { item in
            self.currentSelectedItem = item
        }
    }
    
    private func setContainerView(parentView: UIView, subView: UIView) {
        parentView.addSubview(subView)
        subView.snp.makeConstraints { make in
            make.height.equalTo(50.0)
            make.edges.equalToSuperview()
        }
    }
}
//MARK: - CollectionView
extension SearchViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.collectionViewNumberOfRowInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellInfo = viewModel.collectionViewCellForRowAt(indexPath: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchingCollectionViewCell.reuseIdentifier, for: indexPath) as! SearchingCollectionViewCell
        let buttonCell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier, for: indexPath) as! ButtonCollectionViewCell
        if isSearchModeViewOn {
            switch AlreadyFilter(rawValue: indexPath.row) {
            case .result:
                cell.setAutoLayoutMode(by: true)
                cell.configure(title: cellInfo.title, isSelected: cellInfo.isSelected)
                return cell
            case .news:
                cell.setAutoLayoutMode(by: true)
                cell.configure(title: cellInfo.title, isSelected: cellInfo.isSelected)
                return cell
            case .nearest:
                cell.setAutoLayoutMode(by: true)
                cell.configure(title: cellInfo.title, isSelected: cellInfo.isSelected)
                return cell
            case .filterIcon:
                buttonCell.configure(iconText: cellInfo.title)
                buttonCell.action = {
                    self.present(self.popUpViewController, animated: true)
                }
                return buttonCell
            case .none:
                AppLogger.debug("none", category: .ui)
                return UICollectionViewCell()
            }
        } else {
            cell.configure(title: FilterType.allCases[indexPath.row].text, isSelected: cellInfo.isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellWidth: CGFloat = 0.0
        var cellHeight: CGFloat = 0.0
        if isSearchModeViewOn {
            cellWidth = (view.frame.width - 8 * 5) / 4
            cellHeight = 48.0
        } else {
            cellWidth = (view.frame.width - 8 * 6) / 6
            cellHeight = 48.0
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppLogger.debug("indexPath:\(indexPath)", category: .ui)
        viewModel.collectionViewDidSelectedRowAt(indexPath: indexPath)
        searchView.filterContentCollectionView.reloadData()
        searchView.filterTableView.reloadData()
    }
}

//MARK: - TableView
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchModeViewOn {
            return viewModel.searchModeTableViewNumberOfRowInSection(section: section)
        } else {
            return viewModel.unSearchModeTableViewNumberOfRowInSection(section: section)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        let headerView = TitleHeaderView()
        headerView.buttonAction = {
            self.viewModel.selectedCollectionViewAllCell(bySection: section)
        }
        setContainerView(parentView: containerView, subView: headerView)
        if isSearchModeViewOn {
            if currentSelectedItem == nil {
                headerView.configureTitle(with: "熱門搜尋")
                headerView.button.isHidden = true
            } else {
                headerView.configureTitle(with: "找到\(0)筆展覽")
            }
        } else {
            if currentSelectedItem == nil {
                headerView.configureTitle(with: "熱門搜尋")
                headerView.button.isHidden = true
                return headerView
            } else {
                switch FilterType(rawValue: currentSelectedItem!) {
                case .city:
                    headerView.configureTitle(with: Area.allCases[section].text)
                    headerView.button.isHidden = false
                    headerView.configureTextButton(with: "全選")
                    if section == 5 {
                        headerView.isHidden = true
                    }
                case .place:
                    headerView.configureTitle(with: "展覽館")
                    headerView.button.isHidden = false
                    headerView.button.setTitle("全選", for: .normal)
                case .date:
                    switch TimeSection(rawValue: section) {
                    case .dateKind:
                        headerView.configureTitle(with: "時間")
                        headerView.button.isHidden = false
                        headerView.button.setTitle("全選", for: .normal)
                    case .calendar:
                        headerView.configureTitle(with: "日期")
                        headerView.button.isHidden = true
                        headerView.button.setTitle("全選", for: .normal)
                    case .correct:
                        headerView.isHidden = true
                    case .none:
                        return UIView()
                    }
                case .price:
                    headerView.configureTitle(with: "票價")
                    headerView.button.isHidden = false
                    headerView.button.setTitle("全選", for: .normal)
                case .none:
                    return UIView()
                }
            }
        }
        return containerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //搜尋狀態
        if isSearchModeViewOn {
            if let currentItem = currentSelectedItem {
                let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.reuseIdentifier, for: indexPath) as! SearchResultTableViewCell
                viewModel.searchModeTableViewCellForRowAt(indexPath: indexPath).map { info in
                    cell.configure(image: info.image,
                                   tag: info.tag,
                                   title: info.title,
                                   date: info.dateString,
                                   city: info.city,
                                   starCount: info.evaluation?.allCommentStar ?? 1,
                                   commentCount: info.evaluation?.allCommentCount ?? 1)
                }
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UnSearchModeChooseTableViewCell.reuseIdentifier, for: indexPath) as! UnSearchModeChooseTableViewCell
            let calendarCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UITableViewCell
            let correctButtonCell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.reuseIdentifier, for: indexPath) as! ButtonTableViewCell
            let unSearchModel = viewModel.unSearchModeTableViewCellForRowAt(indexPath: indexPath)
            if currentSelectedItem != nil {
                switch FilterType(rawValue: currentSelectedItem!) {
                case .city:
                    switch Area(rawValue: indexPath.section) {
                    case .north:  cell.configure(itemTitle: unSearchModel)
                    case .middle: cell.configure(itemTitle: unSearchModel)
                    case .south: cell.configure(itemTitle: unSearchModel)
                    case .east: cell.configure(itemTitle: unSearchModel)
                    case .island: cell.configure(itemTitle: unSearchModel)
                    case .correct:
                        correctButtonCell.configure(buttonName: "確定")
                        return correctButtonCell
                    case .none: return cell
                    }
                    return cell
                case .place:
                    cell.configure(itemTitle: Place.allCases.map{$0.title})
                    return cell
                case .date:
                    switch TimeSection(rawValue: indexPath.section) {
                    case .dateKind:
                        cell.configure(itemTitle: DateKind.allCases.map{$0.text})
                        return cell
                    case .calendar:
                        // TODO: 實作日曆視圖
                        AppLogger.debug("calendarView", category: .ui)
                    case .correct:
                        correctButtonCell.configure(buttonName: "確定")
                        return correctButtonCell
                    case .none: return cell
                    }
                    return cell
                case .price: cell.configure(itemTitle: Price.allCases.map{$0.text})
                    return cell
                case .none:
                    correctButtonCell.configure(buttonName: "確定")
                    return correctButtonCell
                }
            } else {
                let unSearchModel = viewModel.unSearchModeTableViewCellForRowAt(indexPath: indexPath)
                let cell = tableView.dequeueReusableCell(withIdentifier: UnSearchModeChooseTableViewCell.reuseIdentifier, for: indexPath) as! UnSearchModeChooseTableViewCell
                AppLogger.debug("unSearchModel：\(unSearchModel)", category: .ui)
                cell.configure(itemTitle: unSearchModel)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
