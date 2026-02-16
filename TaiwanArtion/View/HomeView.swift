//
//  HomeView.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import UIKit
import RxSwift
import RxCocoa

class HomeView: UIView {
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Background
    private let rightTopImageView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "rightTopWave"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let lineImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "middleLine"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let leftImageView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "leftWave"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    //MARK: - Title
    private let titleView: UIView = {
        let view = UIView()
        return view
    }()
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "search"), for: .normal)
        button.accessibilityIdentifier = "searchButton"
        button.accessibilityLabel = "搜尋"
        return button
    }()

    let bellButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "bell"), for: .normal)
        button.accessibilityIdentifier = "bellButton"
        button.accessibilityLabel = "通知"
        return button
    }()
    
    private let logoImage: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [searchButton, bellButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    //MARK: - 基本佈局
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.accessibilityIdentifier = "homeTableView"
        tableView.backgroundColor = .white
        tableView.register(MonthTableViewCell.self, forCellReuseIdentifier: MonthTableViewCell.reuseIdentifier)
        tableView.register(HabbyTableViewCell.self, forCellReuseIdentifier: HabbyTableViewCell.reuseIdentifier)
        tableView.register(MainPhotosTableViewCell.self, forCellReuseIdentifier: MainPhotosTableViewCell.reuseIdentifier)
        tableView.register(HotHxhibitionTableViewCell.self, forCellReuseIdentifier: HotHxhibitionTableViewCell.reuseIdentifier)
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.reuseIdentifier)
        tableView.register(AllExhibitionTableViewCell.self, forCellReuseIdentifier: AllExhibitionTableViewCell.reuseIdentifier)
        tableView.register(TitleHeaderView.self, forHeaderFooterViewReuseIdentifier: TitleHeaderView.reuseIdentifier)
        tableView.setSpecificRoundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.applyShadow(color: .black, opacity: 0.3, offset: CGSize(width: 1, height: 1), radius: 4)
        // 效能優化：預估高度減少 Auto Layout 計算
        tableView.estimatedRowHeight = 200
        tableView.estimatedSectionHeaderHeight = 50
        tableView.estimatedSectionFooterHeight = 0
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackground()
        setForeground()
        setTitleView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setTitleView() {
        titleView.addSubview(titleStack)
        searchButton.snp.makeConstraints { make in
            make.width.equalTo(36)
            make.height.equalTo(36)
        }
        
        bellButton.snp.makeConstraints { make in
            make.width.equalTo(36)
            make.height.equalTo(36)
        }
        
        titleView.addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(114.0 / 390.0)
            make.height.equalToSuperview().multipliedBy(45.0 / 137.0)
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview().offset(24)
        }
        
        titleStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    private func setBackground() {
        backgroundColor = .caramelColor
        addSubview(leftImageView)
        leftImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        addSubview(lineImageView)
        lineImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        addSubview(rightTopImageView)
        rightTopImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        
    }
    
    private func setForeground() {
        addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(137.0 / 844.0)
        }
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(titleView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
}
