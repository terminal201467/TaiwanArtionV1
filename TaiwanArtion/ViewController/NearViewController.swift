//
//  NearViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import UIKit
import RxSwift
import MapKit

class NearViewController: UIViewController {
    
    private let disposeBag = DisposeBag()

    private let nearView = NearView()
    
    private let viewModel = NearViewModel.shared
    
    private let resultViewController = NearSearchResultViewController()
    
    private lazy var searchResultViewController = UINavigationController(rootViewController: self.resultViewController)
    
    private lazy var searchViewController: UISearchController = {
       let searchViewController = UISearchController(searchResultsController: searchResultViewController)
        searchViewController.searchBar.searchTextField.roundCorners(cornerRadius: 20)
        searchViewController.searchBar.searchTextField.placeholder = "搜尋附近展覽館"
        searchViewController.showsSearchResultsController = true
        return searchViewController
    }()
    
    private let bottomUpView = BottomUpPopUpView(frame: .zero, type: .filter)
    
    private lazy var popUpViewController: PopUpViewController = {
        let popUpViewController = PopUpViewController(popUpView: bottomUpView)
        popUpViewController.modalPresentationStyle = .overFullScreen
        popUpViewController.modalTransitionStyle = .coverVertical
        bottomUpView.dismissFromController = {
            popUpViewController.dismiss(animated: true)
            self.nearView.filterButtonIsSelected.toggle()
        }
        return popUpViewController
    }()
    
    //MARK: - LifeCycle
    override func loadView() {
        super.loadView()
        view = nearView
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setNearView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.nearView.exhibitionMapView.locationInterface.checkLocationAuthorization()
        self.nearView.exhibitionMapView.showCurrentLocation(by: 1000, by: 1000)
    }
    
    private func setNavigationBar() {
        navigationItem.titleView = searchViewController.searchBar
    }
    
    private func setNearView() {
        nearView.filterSubject.subscribe(onNext: {
            self.present(self.popUpViewController, animated: true)
        })
        .disposed(by: disposeBag)
    }
}

extension NearViewController: UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        AppLogger.debug("searchTextField:\(String(describing: textField.text))", category: .ui)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Text field editing ended
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //紀錄到UserDefault裡面
        return true
    }
}


