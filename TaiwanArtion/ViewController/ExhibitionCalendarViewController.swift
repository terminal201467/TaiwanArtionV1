//
//  ExhibitionCalendarViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import UIKit

class ExhibitionCalendarViewController: UIViewController {
    
    private let viewModel = ExhibitionCalendarViewModel()
    
    private let exhibitionCalendarView = ExhibitionCalendarView()

    //MARK: - LifeCycle
    override func loadView() {
        super.loadView()
        view = exhibitionCalendarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
    }
    
    private func setDelegates() {
        exhibitionCalendarView.habbyCollectionView.delegate = self
        exhibitionCalendarView.habbyCollectionView.dataSource = self
        exhibitionCalendarView.tableView.delegate = self
        exhibitionCalendarView.tableView.dataSource = self
    }
    
}

extension ExhibitionCalendarViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HabbyItem.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HabbyCollectionViewCell.reuseIdentifier, for: indexPath) as! HabbyCollectionViewCell
        if viewModel.output.outputHabby.value != nil {
            let isSelected = viewModel.output.outputHabby.value == HabbyItem.allCases[indexPath.row]
            cell.configureHabbyWithoutBorder(by: HabbyItem.allCases[indexPath.row], isSelected: isSelected)
        } else {
            cell.configureHabbyWithoutBorder(by: HabbyItem.allCases[indexPath.row], isSelected: false)
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.inputHabby.accept(HabbyItem.allCases[indexPath.row])
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 8
        let cellHeight = 60.0
        return .init(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 8, left: 16, bottom: 8, right: 16)
    }
}

extension ExhibitionCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        let titleView = TitleHeaderView()
        containerView.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        viewModel.output.outputDate.value == nil ? titleView.configureTitle(with: "即將到來的展覽") : titleView.configureTitle(with: "\(viewModel.output.outputDate.value!)的展覽")
        titleView.configureImageButton(with: "edit")
        return containerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.output.outputExhibitions.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotifyTableViewCell.reuseIdentifier, for: indexPath) as! NotifyTableViewCell
        cell.beforeLabel.isHidden = true
        let info = viewModel.output.outputExhibitions.value[indexPath.row]
        cell.configure(image: info.image, title: info.title, date: info.dateString, location: info.location, dayBefore: info.dateBefore, tag: info.tag)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppLogger.debug("didSelected", category: .ui)
    }
}
