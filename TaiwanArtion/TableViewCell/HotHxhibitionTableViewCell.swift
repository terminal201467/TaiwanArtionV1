//
//  HotHxhibitionTableViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class HotHxhibitionTableViewCell: BaseTableViewCell {

    private let viewModel = HomeViewModel.shared

    var pushToViewController: ((ExhibitionInfo) -> Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(HotDetailTableViewCell.self, forCellReuseIdentifier: HotDetailTableViewCell.reuseIdentifier)
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = true
        tableView.backgroundColor = .white
        return tableView
    }()
    
    override func setupCell() {
        setTableViewBinding()
        autoLayout()
    }

    override func cleanupForReuse() {
        pushToViewController = nil
    }
    
    private func setTableViewBinding() {
//        tableView.delegate = self
        viewModel.outputs.hotExhibitionRelay.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: HotDetailTableViewCell.reuseIdentifier, cellType: HotDetailTableViewCell.self)) { (row, item, cell) in
                cell.configure(number: "\(row + 1)", title: item.title, location: item.city, date: item.dateString, image: item.image)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.inputs.hotExhibitionSelected.onNext(indexPath)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func autoLayout() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension HotHxhibitionTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let seperatedHeight = 4 * CGFloat(8)
        let cellHeight = CGFloat(tableView.frame.height - seperatedHeight) / 5
        return cellHeight
    }
}
