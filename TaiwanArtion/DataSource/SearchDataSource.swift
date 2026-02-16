//
//  SearchDataSource.swift
//  TaiwanArtion
//
//  Created by Claude on 2024/2/11.
//

import UIKit

/// DataSource for SearchViewController
/// Handles all TableView and CollectionView delegate and data source logic
class SearchDataSource: NSObject {

    // MARK: - Properties

    private let viewModel = SearchViewModel.shared

    var isSearchModeViewOn: Bool = false
    var currentSelectedItem: Int?

    /// Actions
    var presentPopUp: (() -> Void)?
    var reloadTableView: (() -> Void)?
    var reloadCollectionView: (() -> Void)?

    // MARK: - CollectionView Configuration

    func collectionViewNumberOfItems(in section: Int) -> Int {
        return viewModel.collectionViewNumberOfRowInSection(section: section)
    }

    func collectionViewCellSize(for indexPath: IndexPath, viewWidth: CGFloat) -> CGSize {
        var cellWidth: CGFloat = 0.0
        let cellHeight: CGFloat = 48.0

        if isSearchModeViewOn {
            cellWidth = (viewWidth - 8 * 5) / 4
        } else {
            cellWidth = (viewWidth - 8 * 6) / 6
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }

    // MARK: - TableView Configuration

    func tableViewNumberOfSections() -> Int {
        return viewModel.numberOfSection()
    }

    func tableViewNumberOfRows(in section: Int) -> Int {
        if isSearchModeViewOn {
            return viewModel.searchModeTableViewNumberOfRowInSection(section: section)
        } else {
            return viewModel.unSearchModeTableViewNumberOfRowInSection(section: section)
        }
    }

    func tableViewHeaderHeight(for section: Int) -> CGFloat {
        return 50.0
    }

    // MARK: - CollectionView Cell Configuration

    func configureCollectionViewCell(
        _ collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cellInfo = viewModel.collectionViewCellForRowAt(indexPath: indexPath)

        if isSearchModeViewOn {
            return configureSearchModeCollectionCell(collectionView, at: indexPath, cellInfo: cellInfo)
        } else {
            return configureNormalModeCollectionCell(collectionView, at: indexPath, cellInfo: cellInfo)
        }
    }

    private func configureSearchModeCollectionCell(
        _ collectionView: UICollectionView,
        at indexPath: IndexPath,
        cellInfo: (title: String, isSelected: Bool?)
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchingCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! SearchingCollectionViewCell

        let buttonCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! ButtonCollectionViewCell

        switch AlreadyFilter(rawValue: indexPath.row) {
        case .result, .news, .nearest:
            cell.setAutoLayoutMode(by: true)
            cell.configure(title: cellInfo.title, isSelected: cellInfo.isSelected)
            return cell
        case .filterIcon:
            buttonCell.configure(iconText: cellInfo.title)
            buttonCell.action = { [weak self] in
                self?.presentPopUp?()
            }
            return buttonCell
        case .none:
            AppLogger.debug("none", category: .ui)
            return UICollectionViewCell()
        }
    }

    private func configureNormalModeCollectionCell(
        _ collectionView: UICollectionView,
        at indexPath: IndexPath,
        cellInfo: (title: String, isSelected: Bool?)
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchingCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! SearchingCollectionViewCell

        cell.configure(title: FilterType.allCases[indexPath.row].text, isSelected: cellInfo.isSelected)
        return cell
    }

    func collectionViewDidSelectItem(at indexPath: IndexPath) {
        AppLogger.debug("indexPath:\(indexPath)", category: .ui)
        viewModel.collectionViewDidSelectedRowAt(indexPath: indexPath)
        reloadCollectionView?()
        reloadTableView?()
    }

    // MARK: - TableView Header Configuration

    func configureTableViewHeader(for section: Int, buttonAction: @escaping () -> Void) -> UIView? {
        let containerView = UIView()
        let headerView = TitleHeaderView()

        headerView.buttonAction = buttonAction

        addHeaderViewToContainer(headerView, in: containerView)

        if isSearchModeViewOn {
            return configureSearchModeHeader(headerView, in: containerView)
        } else {
            return configureNormalModeHeader(headerView, in: containerView, section: section)
        }
    }

    private func addHeaderViewToContainer(_ headerView: TitleHeaderView, in containerView: UIView) {
        containerView.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.height.equalTo(50.0)
            make.edges.equalToSuperview()
        }
    }

    private func configureSearchModeHeader(_ headerView: TitleHeaderView, in containerView: UIView) -> UIView {
        if currentSelectedItem == nil {
            headerView.configureTitle(with: "熱門搜尋")
            headerView.button.isHidden = true
        } else {
            headerView.configureTitle(with: "找到\(0)筆展覽")
        }
        return containerView
    }

    private func configureNormalModeHeader(
        _ headerView: TitleHeaderView,
        in containerView: UIView,
        section: Int
    ) -> UIView? {
        guard let selectedItem = currentSelectedItem else {
            headerView.configureTitle(with: "熱門搜尋")
            headerView.button.isHidden = true
            return headerView
        }

        switch FilterType(rawValue: selectedItem) {
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
            configureTimeSectionHeader(headerView, section: section)
        case .price:
            headerView.configureTitle(with: "票價")
            headerView.button.isHidden = false
            headerView.button.setTitle("全選", for: .normal)
        case .none:
            return UIView()
        }

        return containerView
    }

    private func configureTimeSectionHeader(_ headerView: TitleHeaderView, section: Int) {
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
            break
        }
    }

    // MARK: - TableView Cell Configuration

    func configureTableViewCell(
        _ tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        if isSearchModeViewOn {
            return configureSearchModeCell(tableView, at: indexPath)
        } else {
            return configureNormalModeCell(tableView, at: indexPath)
        }
    }

    private func configureSearchModeCell(
        _ tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        guard currentSelectedItem != nil else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! SearchResultTableViewCell

        viewModel.searchModeTableViewCellForRowAt(indexPath: indexPath).map { info in
            cell.configure(
                image: info.image,
                tag: info.tag,
                title: info.title,
                date: info.dateString,
                city: info.city,
                starCount: info.evaluation?.allCommentStar ?? 1,
                commentCount: info.evaluation?.allCommentCount ?? 1
            )
        }
        return cell
    }

    private func configureNormalModeCell(
        _ tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: UnSearchModeChooseTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! UnSearchModeChooseTableViewCell

        let correctButtonCell = tableView.dequeueReusableCell(
            withIdentifier: ButtonTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! ButtonTableViewCell

        let unSearchModel = viewModel.unSearchModeTableViewCellForRowAt(indexPath: indexPath)

        guard let selectedItem = currentSelectedItem else {
            cell.configure(itemTitle: unSearchModel)
            return cell
        }

        switch FilterType(rawValue: selectedItem) {
        case .city:
            return configureCityCell(cell, correctButtonCell, at: indexPath, model: unSearchModel)
        case .place:
            cell.configure(itemTitle: Place.allCases.map { $0.title })
            return cell
        case .date:
            return configureDateCell(cell, correctButtonCell, at: indexPath)
        case .price:
            cell.configure(itemTitle: Price.allCases.map { $0.text })
            return cell
        case .none:
            correctButtonCell.configure(buttonName: "確定")
            return correctButtonCell
        }
    }

    private func configureCityCell(
        _ cell: UnSearchModeChooseTableViewCell,
        _ correctButtonCell: ButtonTableViewCell,
        at indexPath: IndexPath,
        model: [String]
    ) -> UITableViewCell {
        switch Area(rawValue: indexPath.section) {
        case .north, .middle, .south, .east, .island:
            cell.configure(itemTitle: model)
            return cell
        case .correct:
            correctButtonCell.configure(buttonName: "確定")
            return correctButtonCell
        case .none:
            return cell
        }
    }

    private func configureDateCell(
        _ cell: UnSearchModeChooseTableViewCell,
        _ correctButtonCell: ButtonTableViewCell,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        switch TimeSection(rawValue: indexPath.section) {
        case .dateKind:
            cell.configure(itemTitle: DateKind.allCases.map { $0.text })
            return cell
        case .calendar:
            // TODO: 實作日曆視圖
            AppLogger.debug("calendarView", category: .ui)
            return cell
        case .correct:
            correctButtonCell.configure(buttonName: "確定")
            return correctButtonCell
        case .none:
            return cell
        }
    }

    // MARK: - Actions

    func selectAllInSection(_ section: Int) {
        viewModel.selectedCollectionViewAllCell(bySection: section)
    }
}

// MARK: - UICollectionViewDataSource

extension SearchDataSource: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewNumberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return configureCollectionViewCell(collectionView, at: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchDataSource: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionViewCellSize(for: indexPath, viewWidth: collectionView.superview?.frame.width ?? collectionView.frame.width)
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
        collectionViewDidSelectItem(at: indexPath)
    }
}

// MARK: - UITableViewDataSource

extension SearchDataSource: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewNumberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewNumberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureTableViewCell(tableView, at: indexPath)
    }
}

// MARK: - UITableViewDelegate

extension SearchDataSource: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewHeaderHeight(for: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return configureTableViewHeader(for: section) { [weak self] in
            self?.selectAllInSection(section)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
