//
//  ResultViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/31.
//

import UIKit
import RxSwift

enum Mode: Int {
    case searchingMode = 0, nothingMode, filterMode
}

class ResultViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let resultView = ResultView()
    
    private let viewModel = ResultViewModel()
    
    private var searchHistoryView: SearchingHistoryView?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.roundCorners(cornerRadius: 20)
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.placeholder = "搜尋已收藏的展覽"
        return searchBar
    }()

    override func loadView() {
        super.loadView()
        view = resultView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu()
        setNavigationBar()
        setSearchTextField()
        viewModel.output.currentExhibitionMenu
            .subscribe(onNext: { menu in
                self.setViewInContainer(by: menu.rawValue)
            })
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.searchTextField.resignFirstResponder()
    }
    
    private func setSearchTextField() {
        searchBar.searchTextField.delegate = self
    }
    
    @objc func back() {
        dismiss(animated: true)
    }
    
    private func setNavigationBar() {
        let leftButton = UIBarButtonItem(image: .init(named: "leftArrow")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.titleView = searchBar
    }
    
    private func setMenu() {
        resultView.menu.selectedMenuItem = { selectItem in
            self.viewModel.input.currentMenuRelay.accept(CollectMenu(rawValue: selectItem)!)
        }
    }
    
    private func setViewInContainer(by menuOrder: Int) {
        resultView.removeAllSubviews(from: resultView.containerView)
        switch CollectMenu(rawValue: menuOrder) {
        case .collectExhibition:
            viewModel.output.storeHistoryObservable.subscribe(onNext: { historys in
                AppLogger.debug("history:\(historys)", category: .ui)
                self.searchHistoryView = SearchingHistoryView(frame: .zero, historys: historys.map{$0.title}, type: .exhibitionNothingSearch)
            })
            .disposed(by: disposeBag)
            if let view = searchHistoryView {
                resultView.containerView.addSubview(view)
                view.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        case .collectExhibitionHall:
            viewModel.output.storeExhibitionHallObservable.subscribe(onNext: { hallInfos in
                AppLogger.debug("hallInfo:\(hallInfos)", category: .ui)
                self.searchHistoryView = SearchingHistoryView(frame: .zero, historys: hallInfos.map{$0.title}, type: .exhibitionHallNothingSearch)
            })
            .disposed(by: disposeBag)
            if let view = searchHistoryView {
                resultView.containerView.addSubview(view)
                view.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        case .collectNews:
            viewModel.output.storeNewsObservable.subscribe(onNext: { news in
                AppLogger.debug("news:\(news)", category: .ui)
                self.searchHistoryView = SearchingHistoryView(frame: .zero, historys: news.map{$0.title}, type: .newsNothingSearch)
            })
            .disposed(by: disposeBag)
            if let view = searchHistoryView {
                resultView.containerView.addSubview(view)
                view.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        case .none: AppLogger.debug("none", category: .ui)
        }
    }
}

extension ResultViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        AppLogger.debug("text:\(String(describing: textField.text))", category: .ui)
        viewModel.textEditingRelay.accept(textField.text!)
        return true
    }
}
