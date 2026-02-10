//
//  ExhibitionCardDataSource.swift
//  TaiwanArtion
//
//  Created by Claude on 2024/2/10.
//

import UIKit

/// DataSource for ExhibitionCardViewController
/// Handles all TableView delegate and data source logic
class ExhibitionCardDataSource: NSObject {

    // MARK: - Properties

    private let viewModel = ExhibitionCardViewModel.shared

    var selectedItem: CardInfoItem = .overview

    /// Navigation action for evaluate section
    var navigateToEvaluate: (() -> Void)?

    // MARK: - Section Configuration

    func numberOfSections() -> Int {
        return viewModel.numberOfSections(by: selectedItem)
    }

    func numberOfRows(in section: Int) -> Int {
        return viewModel.numberOfRowInSection(chooseItem: selectedItem, section: section)
    }

    func heightForHeader(in section: Int) -> CGFloat {
        return viewModel.heightForHeaderFooterInSection(chooseItem: selectedItem, section: section) ?? 0
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRowInSection(chooseItem: selectedItem, indexPath: indexPath)
    }

    // MARK: - Header View Configuration

    func headerView(for section: Int) -> UIView? {
        switch selectedItem {
        case .overview:
            return configureOverviewHeader(section: section)
        case .introduce:
            return configureIntroduceHeader(section: section)
        case .ticketPrice:
            return configureTicketPriceHeader(section: section)
        case .location:
            return configureLocationHeader(section: section)
        case .evaluate:
            return configureEvaluateHeader()
        }
    }

    private func configureOverviewHeader(section: Int) -> UIView? {
        guard let sectionType = OverViewSection(rawValue: section) else { return nil }
        switch sectionType {
        case .overview:
            let view = NewsSectionView()
            view.configure(title: OverViewSection.overview.title)
            return view
        }
    }

    private func configureIntroduceHeader(section: Int) -> UIView? {
        guard let sectionType = IntroduceSection(rawValue: section) else { return nil }
        switch sectionType {
        case .intro:
            let view = NewsSectionView()
            view.configure(title: IntroduceSection.intro.title)
            return view
        }
    }

    private func configureTicketPriceHeader(section: Int) -> UIView? {
        guard let sectionType = TicketPriceSection(rawValue: section) else { return nil }
        switch sectionType {
        case .price:
            let view = NewsSectionView()
            view.configure(title: TicketPriceSection.price.title)
            return view
        }
    }

    private func configureLocationHeader(section: Int) -> UIView? {
        guard let sectionType = LocationSection(rawValue: section) else { return nil }
        switch sectionType {
        case .location:
            let view = NewsSectionView()
            view.configure(title: LocationSection.location.title)
            return view
        case .equipment:
            let view = NewsSectionView()
            view.configure(title: LocationSection.equipment.title)
            return view
        case .map, .route:
            return nil
        }
    }

    private func configureEvaluateHeader() -> UIView {
        let view = AllCommentHeaderView()
        view.exhibitionCardItemView.pushToViewController = { [weak self] in
            self?.navigateToEvaluate?()
        }
        view.configureAllComment(
            number: viewModel.evaluation.number,
            commentCount: viewModel.evaluation.allCommentCount,
            starScore: viewModel.evaluation.allCommentStar
        )
        viewModel.evaluation.allCommentRate.map { rate in
            view.scores.append(rate.contentRichness)
            view.scores.append(rate.equipment)
            view.scores.append(rate.geoLocation)
            view.scores.append(rate.price)
            view.scores.append(rate.service)
        }
        return view
    }

    // MARK: - Cell Configuration

    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        switch selectedItem {
        case .overview:
            return configureOverviewCell(tableView: tableView, indexPath: indexPath)
        case .introduce:
            return configureIntroduceCell(tableView: tableView, indexPath: indexPath)
        case .ticketPrice:
            return configureTicketPriceCell(tableView: tableView, indexPath: indexPath)
        case .location:
            return configureLocationCell(tableView: tableView, indexPath: indexPath)
        case .evaluate:
            return configureEvaluateCell(tableView: tableView, indexPath: indexPath)
        }
    }

    // MARK: - Overview Cell

    private func configureOverviewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let section = OverViewSection(rawValue: indexPath.section),
              section == .overview,
              let cellType = OverViewContentCell(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsDetailTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! NewsDetailTableViewCell

        cell.selectionStyle = .none

        switch cellType {
        case .kind:
            cell.configureWithTag(title: cellType.title, tag: viewModel.exhibitionInfo.tag)
        case .date:
            cell.configure(title: cellType.title, contentText: viewModel.exhibitionInfo.dateString)
        case .time:
            cell.configure(title: cellType.title, contentText: viewModel.exhibitionInfo.time)
        case .agency:
            cell.configure(title: cellType.title, contentText: viewModel.exhibitionInfo.agency)
        case .official:
            cell.configure(title: cellType.title, contentText: viewModel.exhibitionInfo.official)
        case .telephone:
            cell.configure(title: cellType.title, contentText: viewModel.exhibitionInfo.telephone)
        }

        return cell
    }

    // MARK: - Introduce Cell

    private func configureIntroduceCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let section = IntroduceSection(rawValue: indexPath.section),
              section == .intro,
              let cellType = IntroduceContentCell(rawValue: indexPath.row),
              cellType == .content else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsContentTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! NewsContentTableViewCell

        cell.selectionStyle = .none
        cell.configureContent(text: getIntroduceContent())
        return cell
    }

    private func getIntroduceContent() -> String {
        return """
        自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...

        人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。

        『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...
        """
    }

    // MARK: - Ticket Price Cell

    private func configureTicketPriceCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let section = TicketPriceSection(rawValue: indexPath.section),
              section == .price,
              let cellType = TicketPriceContentCell(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: TicketPriceTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! TicketPriceTableViewCell

        cell.selectionStyle = .none
        configureTicketCell(cell, for: cellType)
        return cell
    }

    private func configureTicketCell(_ cell: TicketPriceTableViewCell, for type: TicketPriceContentCell) {
        let defaultNote = "備註：11/25-12/1優惠活動正式開跑,凡購買早鳥優惠送一顆大蘋果。"

        switch type {
        case .advanceTicketPrice:
            cell.configure(title: "預售票", ticketType: type.text, price: "199", note: defaultNote)
        case .unanimousVotePrice:
            cell.configure(title: "全票", ticketType: type.text, price: "199", note: defaultNote)
        case .studentPrice, .groupPrice, .lovePrice:
            cell.configure(title: nil, ticketType: type.text, price: "199", note: defaultNote)
        case .free:
            cell.configure(title: nil, ticketType: type.text, price: "199",
                          note: "須出示相關證件 年齡未滿五歲之兒童 (須由一位大人持票陪同入場)，未帶證件以身高110公分作判定。")
        case .earlyBirdPrice:
            cell.configure(title: "票價說明", ticketType: type.text, price: "199", note: defaultNote)
        }
    }

    // MARK: - Location Cell

    private func configureLocationCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = LocationSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch sectionType {
        case .location:
            return configureLocationDetailCell(tableView: tableView, indexPath: indexPath)
        case .equipment:
            return configureEquipmentCell(tableView: tableView, indexPath: indexPath)
        case .map:
            return configureMapCell(tableView: tableView, indexPath: indexPath)
        case .route:
            return configureRouteCell(tableView: tableView, indexPath: indexPath)
        }
    }

    private func configureLocationDetailCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cellType = LocationContentCell(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsDetailTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! NewsDetailTableViewCell

        cell.selectionStyle = .none

        switch cellType {
        case .location:
            cell.configureLocationDetail(title: cellType.title, contentText: viewModel.exhibitionInfo.location)
        case .address:
            cell.configureLocationDetail(title: cellType.title, contentText: viewModel.exhibitionInfo.address)
        }

        return cell
    }

    private func configureEquipmentCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: EquipmentTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! EquipmentTableViewCell

        cell.equipments = viewModel.exhibitionInfo.equipments ?? ["沒有相關設備"]
        return cell
    }

    private func configureMapCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MapTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! MapTableViewCell

        cell.configure(
            location: viewModel.exhibitionInfo.location,
            address: viewModel.exhibitionInfo.address
        )
        return cell
    }

    private func configureRouteCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ButtonTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! ButtonTableViewCell

        cell.configure(buttonName: "規劃路線")
        cell.action = {
            AppLogger.debug("規劃路線", category: .ui)
        }
        return cell
    }

    // MARK: - Evaluate Cell

    private func configureEvaluateCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = EvaluationSection(rawValue: indexPath.section),
              sectionType == .allComment else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: AllCommentTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! AllCommentTableViewCell

        cell.selectionStyle = .none
        cell.backgroundColor = .white

        guard let evaluationModel = viewModel.evaluationTableCellForRowAt(indexPath: indexPath) else {
            return UITableViewCell()
        }

        viewModel.evaluation.allCommentContents.map { content in
            cell.commentTypeScores.append(contentsOf: content.commentRate.map { $0.contentRichness })
            cell.commentTypeScores.append(contentsOf: content.commentRate.map { $0.geoLocation })
            cell.commentTypeScores.append(contentsOf: content.commentRate.map { $0.equipment })
            cell.commentTypeScores.append(contentsOf: content.commentRate.map { $0.price })
            cell.commentTypeScores.append(contentsOf: content.commentRate.map { $0.service })
        }

        cell.configurePersonComment(
            name: evaluationModel.userName,
            personImageText: evaluationModel.userImage,
            starScore: evaluationModel.star,
            date: evaluationModel.commentDate
        )

        return cell
    }
}

// MARK: - UITableViewDataSource

extension ExhibitionCardDataSource: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(for: tableView, at: indexPath)
    }
}

// MARK: - UITableViewDelegate

extension ExhibitionCardDataSource: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeader(in: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView(for: section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(at: indexPath)
    }
}
