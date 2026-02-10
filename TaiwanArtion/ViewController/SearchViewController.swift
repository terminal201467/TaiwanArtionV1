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

    private let dataSource = SearchDataSource()

    private var isSearchModeViewOn: Bool = false {
        didSet {
            self.viewModel.restartTheCurrentItem()
            self.dataSource.isSearchModeViewOn = isSearchModeViewOn
            self.searchView.filterContentCollectionView.reloadData()
            self.searchView.filterTableView.reloadData()
        }
    }

    var currentSelectedItem: Int? {
        didSet {
            AppLogger.debug("currentSelectedItem:\(String(describing: currentSelectedItem))", category: .ui)
            self.dataSource.currentSelectedItem = currentSelectedItem
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
        setDataSource()
        setSearchindModeChanged()
        viewModel.restartTheCurrentItem()
        searchView.backAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
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

    private func setDataSource() {
        searchView.filterTableView.delegate = dataSource
        searchView.filterTableView.dataSource = dataSource
        searchView.filterContentCollectionView.dataSource = dataSource
        searchView.filterContentCollectionView.delegate = dataSource

        dataSource.presentPopUp = { [weak self] in
            guard let self = self else { return }
            self.present(self.popUpViewController, animated: true)
        }

        dataSource.reloadTableView = { [weak self] in
            self?.searchView.filterTableView.reloadData()
        }

        dataSource.reloadCollectionView = { [weak self] in
            self?.searchView.filterContentCollectionView.reloadData()
        }
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

    private func setSearchindModeChanged() {
        searchView.isBeginSearchMode = { [weak self] isBegan in
            guard let self = self else { return }
            self.viewModel.changedModeWith(isSearching: isBegan)
            self.isSearchModeViewOn = isBegan
            self.searchView.filterContentCollectionView.reloadData()
            self.searchView.filterTableView.reloadData()
        }

        searchView.searchValueChanged = { [weak self] changed in
            guard let self = self else { return }
            AppLogger.debug("changed:\(changed)", category: .ui)
            self.viewModel.filterSearchTextFiled(withText: changed)
            self.searchView.filterContentCollectionView.reloadData()
            self.searchView.filterTableView.reloadData()
        }

        searchView.endInputText = { [weak self] endText in
            guard let self = self else { return }
            AppLogger.debug("finalSearch:\(endText)", category: .ui)
            self.viewModel.filterSearchTextFiled(withText: endText)
            self.searchView.filterContentCollectionView.reloadData()
            self.searchView.filterTableView.reloadData()
        }
    }

    private func setCurrentItem() {
        viewModel.getCurrentItem = { [weak self] item in
            self?.currentSelectedItem = item
        }
    }
}
