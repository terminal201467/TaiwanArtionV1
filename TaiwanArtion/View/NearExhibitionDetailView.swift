//
//  NearExhibitionDetailView.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/27.
//

import UIKit
import SnapKit
import RxSwift

class NearExhibitionDetailView: UIView {
    
    private let disposeBag = DisposeBag()
    
    var selectedExhibition: (() -> Void)?
     
    //MARK: -ViewModel
    private let viewModel = NearViewModel.shared

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(NearExhibitionDetailTableViewCell.self, forCellReuseIdentifier: NearExhibitionDetailTableViewCell.reuseIdentifier)
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private let nothingView = NothingSearchedView(frame: .zero, type: .nothingFoundInNear)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTableView()
        setContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func tableViewAutoLayout() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func nothingViewAutoLayout() {
        addSubview(nothingView)
        nothingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setContentView() {
        viewModel.output.outputExhibitionInfo.subscribe(onNext: { info in
            self.removeAllSubviews(from: self)
            if info.isEmpty {
                self.nothingViewAutoLayout()
            } else {
                self.tableViewAutoLayout()
            }
        })
        .disposed(by: disposeBag)
    }
}

extension NearExhibitionDetailView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.output.outputExhibitionInfo.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NearExhibitionDetailTableViewCell.reuseIdentifier, for: indexPath) as! NearExhibitionDetailTableViewCell
        cell.selectionStyle = .none
        cell.evaluateConfigure(with: viewModel.output.outputExhibitionInfo.value[indexPath.row])
        cell.detailConfigure(with: viewModel.output.outputExhibitionInfo.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedExhibition?()
    }
}

