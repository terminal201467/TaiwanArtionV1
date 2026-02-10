//
//  NearSearchResultViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/17.
//

import UIKit
import RxSwift

class NearSearchResultViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = NearViewModel.shared
    
    private let nearSearchReaultView = NearSearchResultView()
    
    //MARK: -LifeCycle
    override func loadView() {
        super.loadView()
        view = nearSearchReaultView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setSearchTextField()
        setSearchHistory()
        viewModel.output.outputSearchHistory
            .subscribe(onNext: { [weak self] historyInfos in
                self?.nearSearchReaultView.configure(historys: historyInfos)
            })
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
    
    private func setSearchTextField() {
        nearSearchReaultView.searchBar.searchTextField.delegate = self
    }
    
    private func setSearchHistory() {
        viewModel.output.outputSearchHistory
            .subscribe(onNext: { [weak self] historyInfos in
                AppLogger.debug("historys:\(historyInfos)", category: .ui)
                self?.nearSearchReaultView.configure(historys: historyInfos)
            })
            .disposed(by: disposeBag)
    }

    private func setNavigationBar() {
        let leftButton = UIBarButtonItem(image: .init(named: "leftArrow")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem  = leftButton
        navigationItem.titleView = nearSearchReaultView.searchBar
    }
    
    @objc private func back() {
        dismiss(animated: true)
    }
}

extension NearSearchResultViewController: UISearchTextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        AppLogger.debug("searchTextField:\(textField.text!)", category: .ui)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.input.inputSearchKeyword.accept(textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.input.storeSearchRecordsSubject.onNext(())
        textField.resignFirstResponder()
        return true
    }
}
