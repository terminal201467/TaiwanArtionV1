//
//  CollectViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class CollectViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    private let collectView = CollectView()
    
    private let viewModel = CollectViewModel()
    
    private let resultController = UINavigationController(rootViewController: ResultViewController())
    
    private lazy var searchViewController: UISearchController = {
       let searchViewController = UISearchController(searchResultsController: resultController)
        searchViewController.searchBar.searchTextField.roundCorners(cornerRadius: 20)
        searchViewController.searchBar.searchTextField.backgroundColor = .white
        searchViewController.searchBar.searchBarStyle = .default
        searchViewController.searchBar.showsCancelButton = false
        searchViewController.showsSearchResultsController = true
        searchViewController.searchBar.searchTextField.placeholder = "搜尋已收藏的展覽"
        return searchViewController
    }()
    
    override func loadView() {
        super.loadView()
        view = collectView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        setMenuSelected()
        setNavigationBar()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
    
    //MARK: -Methods
    private func setNavigationBar() {
        navigationItem.titleView = searchViewController.searchBar
    }
    
    private func setCollectionView() {
        collectView.exhibitionCollectionView.contents.delegate = self
        collectView.exhibitionCollectionView.contents.dataSource = self
    }
    
    private func setMenuSelected() {
        collectView.menu.selectedMenuItem = { selectedMenuItem in
            AppLogger.debug("selectedMenuItem:\(selectedMenuItem)", category: .ui)
            self.viewModel.input.currentCollectMenu.accept(selectedMenuItem)
        }
        
        viewModel.output.currentSelectedCollectMenuIndex
            .subscribe(onNext: { menuIndex in
                self.collectView.menu.currentMenu = menuIndex
            })
            .disposed(by: disposeBag)
        
        collectView.exhibitionCollectionView.selectedTimeMenu = { menuIndex in
            AppLogger.debug("menuIndex:\(menuIndex)", category: .ui)
            self.viewModel.input.currentTimeMenu.accept(menuIndex)
        }

        viewModel.output.currentSelectedTimeMenu
            .subscribe(onNext: { menuIndex in
                AppLogger.debug("menuIndex:\(menuIndex)", category: .ui)
                self.collectView.exhibitionCollectionView.currentTimeMenuSelected = menuIndex
            })
            .disposed(by: disposeBag)
    }
}

extension CollectViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.currentExhibitionContent.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllExhibitionCollectionViewCell.reuseIdentifier, for: indexPath) as! AllExhibitionCollectionViewCell
        AppLogger.debug("viewModel.output.currentExhibitionContent.value:\(viewModel.output.currentExhibitionContent.value)", category: .ui)
        cell.configure(with: viewModel.output.currentExhibitionContent.value[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = ExhibitionCardViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
        //這邊應該要提供給展覽資料
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (self.view.frame.width - (16 * 2) - 24) / 2
        let cellHeight = 233.0
        return .init(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: 0)
    }
}
