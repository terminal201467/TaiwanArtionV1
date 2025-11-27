//
//  ExhibitionCardViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/25.
//

import UIKit
import RxSwift
import RxCocoa

//MARK: - TableViewSection and Cell settings
enum OverViewSection: Int, CaseIterable {
    case overview = 0
    var title: String {
        switch self {
        case .overview: return "展覽總覽"
        }
    }
    var height: CGFloat {
        return 50.0
    }
}

enum IntroduceSection: Int, CaseIterable {
    case intro = 0
    var title: String {
        switch self {
        case .intro: return "展覽簡介"
        }
    }
    var height: CGFloat {
        return 50.0
    }
}

enum TicketPriceSection: Int, CaseIterable {
    case price = 0
    var title: String {
        switch self {
        case .price: return "展覽票價"
        }
    }
    var height: CGFloat {
        return 50.0
    }
}

enum LocationSection: Int, CaseIterable {
    case location = 0, equipment, map, route
    var title: String {
        switch self {
        case .location: return "展覽地點"
        case .equipment: return "展覽設施"
        case .map: return ""
        case .route: return "規劃路線"
        }
    }
    
    var height: CGFloat {
        switch self {
        case .location: return 40.0
        case .equipment: return 60.0
        case .map: return 450.0
        case .route: return 30.0
        }
    }
}

enum EvaluationSection: Int, CaseIterable {
    case allComment = 0
    var headerHeight: CGFloat {
        return 330.0
    }
    
    var cellHeight: CGFloat {
        return 330.0
    }
}

enum OverViewContentCell: Int, CaseIterable {
    case kind = 0, date, time, agency, official, telephone
    var title: String {
        switch self {
        case .kind: return "展覽類別"
        case .date: return "展覽日期"
        case .time: return "營業時間"
        case .agency: return "主辦單位"
        case .official: return "展覽官網"
        case .telephone: return "展覽電話"
        }
    }
}

enum IntroduceContentCell: Int, CaseIterable {
    case content = 0
}

enum TicketPriceContentCell: Int, CaseIterable {
    case advanceTicketPrice = 0, unanimousVotePrice, studentPrice, groupPrice, lovePrice, free, earlyBirdPrice
    var text: String {
        switch self {
        case .advanceTicketPrice: return "預售票"
        case .unanimousVotePrice: return "全票"
        case .studentPrice: return "學生票"
        case .groupPrice: return "團體票"
        case .lovePrice: return "愛心票"
        case .free: return "免票入場"
        case .earlyBirdPrice: return "早鳥優惠票"
        }
    }
}

enum LocationContentCell: Int, CaseIterable {
    case location = 0, address
    var title: String {
        switch self {
        case .location: return "展覽地點"
        case .address: return "展覽地址"
        }
    }
}


class ExhibitionCardViewController: UIViewController {
    
    private let exhibitionCardView = ExhibitionCardView()
    
    private let viewModel = ExhibitionCardViewModel.shared
    
    private let disposeBag = DisposeBag()
    
    private var selectedItem: CardInfoItem = .overview {
        didSet {
            self.exhibitionCardView.tableView.reloadData()
        }
    }
    
    //MARK: - LifeCycle
    override func loadView() {
        super.loadView()
        view = exhibitionCardView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setCardItems()
        setBackAction()
        setTitleAndBackground()
    }
    
    private func setTableView() {
        exhibitionCardView.tableView.delegate = self
        exhibitionCardView.tableView.dataSource = self
    }
    
    private func setCardItems() {
        exhibitionCardView.exhibitionCardItems.chooseItem = { chooseItem in
//            self.viewModel.currentSelectedItem = chooseItem
            self.selectedItem = chooseItem
            self.exhibitionCardView.tableView.reloadData()
        }
    }
    
    private func setTitleAndBackground() {
        exhibitionCardView.configure(image: "exhibitionCardBackground", title: viewModel.title)
    }
    
    private func setBackAction() {
        exhibitionCardView.backButton.rx.tap
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

}

//MARK: - TableView settings
extension ExhibitionCardViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections(by: selectedItem)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowInSection(chooseItem: selectedItem, section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForHeaderFooterInSection(chooseItem: selectedItem, section: section)!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch selectedItem {
        case .overview:
            switch OverViewSection(rawValue: section) {
            case .overview:
                let view = NewsSectionView()
                view.configure(title: OverViewSection.overview.title)
                return view
            case .none: return UIView()
            }
        case .introduce:
            switch IntroduceSection(rawValue: section) {
            case .intro:
                let view = NewsSectionView()
                view.configure(title: IntroduceSection.intro.title)
                return view
            case .none: return UIView()
            }
        case .ticketPrice:
            switch TicketPriceSection(rawValue: section) {
            case .price:
                let view = NewsSectionView()
                view.configure(title: TicketPriceSection.price.title)
                return view
            case .none: return UIView()
            }
        case .location:
            switch LocationSection(rawValue: section) {
            case .location:
                let view = NewsSectionView()
                view.configure(title: LocationSection.location.title)
                return view
            case .equipment:
                let view = NewsSectionView()
                view.configure(title: LocationSection.equipment.title)
                return view
            case .map: return nil
            case .route: return nil
            case .none: return nil
            }
        case .evaluate:
            let view = AllCommentHeaderView()
            view.exhibitionCardItemView.pushToViewController = { [weak self] in
                guard let self = self else { return }
                let viewController = EvaluateViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            view.configureAllComment(number: viewModel.evaluation.number,
                                     commentCount: viewModel.evaluation.allCommentCount,
                                     starScore: viewModel.evaluation.allCommentStar)
            viewModel.evaluation.allCommentRate.map { rate in
                view.scores.append(rate.contentRichness)
                view.scores.append(rate.equipment)
                view.scores.append(rate.geoLocation)
                view.scores.append(rate.price)
                view.scores.append(rate.service)
            }
            return view
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedItem {
        case .overview:
            switch OverViewSection(rawValue: indexPath.section) {
            case .overview:
                switch OverViewContentCell(rawValue: indexPath.row) {
                case .kind:
                    let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
                    cell.configureWithTag(title: OverViewContentCell.kind.title,
                                          tag: viewModel.exhibitionInfo.tag)
                    cell.selectionStyle = .none
                    return cell
                case .date:
                    let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
                    cell.configure(title: OverViewContentCell.date.title, contentText: viewModel.exhibitionInfo.dateString)
                    cell.selectionStyle = .none
                    return cell
                case .time:
                    let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
                    cell.configure(title: OverViewContentCell.time.title, contentText: viewModel.exhibitionInfo.time)
                    cell.selectionStyle = .none
                    return cell
                case .agency:
                    let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
                    cell.configure(title: OverViewContentCell.agency.title, contentText: viewModel.exhibitionInfo.agency)
                    cell.selectionStyle = .none
                    return cell
                case .official:
                    let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
                    cell.configure(title: OverViewContentCell.official.title, contentText: viewModel.exhibitionInfo.official)
                    cell.selectionStyle = .none
                    return cell
                case .telephone:
                    let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
                    cell.configure(title: OverViewContentCell.telephone.title, contentText: viewModel.exhibitionInfo.telephone)
                    cell.selectionStyle = .none
                    return cell
                case .none:
                    return UITableViewCell()
                }
            case .none: return UITableViewCell()
            }
        case .introduce:
            switch IntroduceSection(rawValue: indexPath.section) {
            case .intro:
                switch IntroduceContentCell(rawValue: indexPath.row) {
                case .content:
                    let cell = tableView.dequeueReusableCell(withIdentifier: NewsContentTableViewCell.reuseIdentifier, for: indexPath) as! NewsContentTableViewCell
                    cell.selectionStyle = .none
                    cell.configureContent(text: """
                    自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。
                
                    人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。
                
                    『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。
                """)
                    return cell
                case .none: return UITableViewCell()
                }
            case .none: return UITableViewCell()
            }
        case .ticketPrice:
            switch TicketPriceSection(rawValue: indexPath.section) {
            case .price:
                switch TicketPriceContentCell(rawValue: indexPath.row) {
                case .advanceTicketPrice:
                    let cell = tableView.dequeueReusableCell(withIdentifier: TicketPriceTableViewCell.reuseIdentifier, for: indexPath) as! TicketPriceTableViewCell
                    cell.configure(title: "預售票", ticketType: TicketPriceContentCell.advanceTicketPrice.text, price: "199", note: "備註：11/25-12/1優惠活動正式開跑,凡購買早鳥優惠送一顆大蘋果。")
                    cell.selectionStyle = .none
                    return cell
                case .unanimousVotePrice:
                    let cell = tableView.dequeueReusableCell(withIdentifier: TicketPriceTableViewCell.reuseIdentifier, for: indexPath) as! TicketPriceTableViewCell
                    cell.configure(title: "全票", ticketType: TicketPriceContentCell.unanimousVotePrice.text, price: "199", note: "備註：11/25-12/1優惠活動正式開跑,凡購買早鳥優惠送一顆大蘋果。")
                    cell.selectionStyle = .none
                    return cell
                case .studentPrice:
                    let cell = tableView.dequeueReusableCell(withIdentifier: TicketPriceTableViewCell.reuseIdentifier, for: indexPath) as! TicketPriceTableViewCell
                    cell.configure(title: nil, ticketType: TicketPriceContentCell.studentPrice.text, price: "199", note: "備註：11/25-12/1優惠活動正式開跑,凡購買早鳥優惠送一顆大蘋果。")
                    cell.selectionStyle = .none
                    return cell
                case .groupPrice:
                    let cell = tableView.dequeueReusableCell(withIdentifier: TicketPriceTableViewCell.reuseIdentifier, for: indexPath) as! TicketPriceTableViewCell
                    cell.configure(title: nil, ticketType: TicketPriceContentCell.groupPrice.text, price: "199", note: "備註：11/25-12/1優惠活動正式開跑,凡購買早鳥優惠送一顆大蘋果。")
                    cell.selectionStyle = .none
                    return cell
                case .lovePrice:
                    let cell = tableView.dequeueReusableCell(withIdentifier: TicketPriceTableViewCell.reuseIdentifier, for: indexPath) as! TicketPriceTableViewCell
                    cell.configure(title: nil, ticketType: TicketPriceContentCell.lovePrice.text, price: "199", note: "備註：11/25-12/1優惠活動正式開跑,凡購買早鳥優惠送一顆大蘋果。")
                    cell.selectionStyle = .none
                    return cell
                case .free:
                    let cell = tableView.dequeueReusableCell(withIdentifier: TicketPriceTableViewCell.reuseIdentifier, for: indexPath) as! TicketPriceTableViewCell
                    cell.configure(title: nil, ticketType: TicketPriceContentCell.free.text, price: "199", note: "須出示相關證件 年齡未滿五歲之兒童 (須由一位大人持票陪同入場)，未帶證件以身高110公分作判定。")
                    cell.selectionStyle = .none
                    return cell
                case .earlyBirdPrice:
                    let cell = tableView.dequeueReusableCell(withIdentifier: TicketPriceTableViewCell.reuseIdentifier, for: indexPath) as! TicketPriceTableViewCell
                    cell.configure(title: "票價說明", ticketType: TicketPriceContentCell.earlyBirdPrice.text, price: "199", note: "備註：11/25-12/1優惠活動正式開跑,凡購買早鳥優惠送一顆大蘋果。")
                    cell.selectionStyle = .none
                    return cell
                case .none:
                    print("none")
                }
            case .none: return UITableViewCell()
            }
        case .location:
            switch LocationSection(rawValue: indexPath.section) {
            case .location:
                switch LocationContentCell(rawValue: indexPath.row) {
                case .location:
                    let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
                    cell.configureLocationDetail(title: LocationContentCell.location.title,
                                                 contentText: viewModel.exhibitionInfo.location)
                    cell.selectionStyle = .none
                    return cell
                case .address:
                    let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
                    cell.configureLocationDetail(title: LocationContentCell.address.title,
                                                 contentText: viewModel.exhibitionInfo.address)
                    cell.selectionStyle = .none
                    return cell
                case .none: return UITableViewCell()
                }
            case .equipment:
                let cell = tableView.dequeueReusableCell(withIdentifier: EquipmentTableViewCell.reuseIdentifier, for: indexPath) as! EquipmentTableViewCell
                cell.equipments = viewModel.exhibitionInfo.equipments ?? ["沒有相關設備"]
                return cell
            case .map:
                let cell = tableView.dequeueReusableCell(withIdentifier: MapTableViewCell.reuseIdentifier, for: indexPath) as! MapTableViewCell
                cell.configure(location: viewModel.exhibitionInfo.location,
                               address: viewModel.exhibitionInfo.address)
                return cell
            case .route:
                let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.reuseIdentifier, for: indexPath) as! ButtonTableViewCell
                cell.configure(buttonName: "規劃路線")
                cell.action = {
                    print("規劃路線")
                }
                return cell
            case .none: return UITableViewCell()
            }
        case .evaluate:
            switch EvaluationSection(rawValue: indexPath.section) {
            case .allComment:
                let cell = tableView.dequeueReusableCell(withIdentifier: AllCommentTableViewCell.reuseIdentifier, for: indexPath) as! AllCommentTableViewCell
                cell.selectionStyle = .none
                cell.backgroundColor = .white
                guard let evaluationModel = viewModel.evaluationTableCellForRowAt(indexPath: indexPath) else { return UITableViewCell() }
                viewModel.evaluation.allCommentContents.map { content in
                    cell.commentTypeScores.append(contentsOf: content.commentRate.map{$0.contentRichness})
                    cell.commentTypeScores.append(contentsOf: content.commentRate.map{$0.geoLocation})
                    cell.commentTypeScores.append(contentsOf:content.commentRate.map{$0.equipment})
                    cell.commentTypeScores.append(contentsOf:content.commentRate.map{$0.price})
                    cell.commentTypeScores.append(contentsOf:content.commentRate.map{$0.service})
                }
                cell.configurePersonComment(name: evaluationModel.userName,
                                            personImageText: evaluationModel.userImage,
                                            starScore: evaluationModel.star,
                                            date: evaluationModel.commentDate)
                return cell
            case .none: return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRowInSection(chooseItem: selectedItem, indexPath: indexPath)
    }
}
