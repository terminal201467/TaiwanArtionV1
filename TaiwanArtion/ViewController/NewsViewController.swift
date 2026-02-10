//
//  NewsViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

enum NewsSection: Int, CaseIterable {
    case overview = 0, content
    var title: String {
        switch self {
        case .overview: return "新聞總覽"
        case .content: return "新聞內容"
        }
    }
}

enum ContentCell: Int, CaseIterable {
    case kind = 0, date, author
    var title: String {
        switch self {
        case .kind: return "新聞類別"
        case .date: return "新聞日期"
        case .author: return "撰文者"
        }
    }
}

class NewsViewController: UIViewController {
    
    private let newsView = NewsView()
    
    var collected: Bool = false
    
    var shareAction: (() -> Void)?
    
    var backAction: (() -> Void)?
    
    private let disposeBag = DisposeBag()
     
    override func loadView() {
        super.loadView()
        view = newsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setNavigationBar()
        setBackgroundAndTitle()
        setBackAction()
        setTabButtons()
    }
    
    private func setNavigationBar() {
        navigationItem.hidesBackButton = true
    }
    
    private func setTableView() {
        newsView.tableView.delegate = self
        newsView.tableView.dataSource = self
    }
    
    private func setBackgroundAndTitle() {
        newsView.configure(title: "德國博物館483枚古金幣遭竊 損失數百萬歐元", backgroundImageText: "newsBackground")
    }
    
    private func setBackAction() {
        newsView.backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.backAction?()
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func setTabButtons() {
        newsView.collectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.collected.toggle()
                self.newsView.collectButton.setImage(UIImage(named: self.collected ? "love" : "collect"), for: .normal)
            })
            .disposed(by: disposeBag)

        newsView.shareButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.shareAction?()
            })
            .disposed(by: disposeBag)
    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return NewsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch NewsSection(rawValue: section) {
        case .overview: return ContentCell.allCases.count
        case .content: return 1
        case .none: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch NewsSection(rawValue: indexPath.section) {
        case .overview:
            switch ContentCell(rawValue: indexPath.row) {
            case .kind:
                let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
                cell.configureWithTag(title: ContentCell.allCases[indexPath.row].title, tag: "雕塑")
                cell.selectionStyle = .none
                return cell
            case .date:
                let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
                cell.configure(title: ContentCell.allCases[indexPath.row].title, contentText: "2022.12.01(ㄧ)")
                cell.selectionStyle = .none
                return cell
            case .author:
                let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
                cell.configure(title: ContentCell.allCases[indexPath.row].title, contentText: "陳悅玲")
                cell.selectionStyle = .none
                return cell
            case .none: return UITableViewCell()
            }
        case .content:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsContentTableViewCell.reuseIdentifier, for: indexPath) as! NewsContentTableViewCell
            cell.selectionStyle = .none
            cell.configureContent(text: """
            自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。

            人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。

            『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。

             有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。人將自己放到動物的環境中，探索動物與自然的關係，進而從中獲取如何與自然共處的教訓或智慧。讀者當然知道作者不可能真正化身為動物，然而卻又被刺激出了最高度的好奇心與跨物種的同情心。 有一個相當長的時代，從美國開始而影響全世界，將「動物小說」視為小孩，至少是小男孩成長必備的讀物，強調「動物小說」所能提供的特殊情感體驗。『野性的呼喚』和『鹿苑長春』就是那個時代中出現最具有代表性的經典作品...自然寫作中的一種特殊形式，是「動物小說」。
            """)
            return cell
        case .none: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch NewsSection(rawValue: section) {
        case .overview:
            let newsView = NewsSectionView()
            newsView.configure(title: NewsSection.overview.title)
            return newsView
        case .content:
            let newsView = NewsSectionView()
            newsView.configure(title: NewsSection.content.title)
            return newsView
        case .none: return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch NewsSection(rawValue: section) {
        case .overview: return 40.0
        case .content: return 40.0
        case .none: return 0
        }
    }
}
