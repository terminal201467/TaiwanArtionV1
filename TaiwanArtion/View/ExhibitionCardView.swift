//
//  ExhibitionCardView.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/25.
//

import UIKit

class ExhibitionCardView: UIView {
    
    private let exhibitionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "backArrow"), for: .normal)
        return button
    }()
    
    let exhibitionCardItems = ExhibitionCardItems()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setSpecificRoundCorners(corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 20)
        return view
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.register(NewsDetailTableViewCell.self, forCellReuseIdentifier: NewsDetailTableViewCell.reuseIdentifier)
        tableView.register(NewsContentTableViewCell.self, forCellReuseIdentifier: NewsContentTableViewCell.reuseIdentifier)
        tableView.register(TicketPriceTableViewCell.self, forCellReuseIdentifier: TicketPriceTableViewCell.reuseIdentifier)
        tableView.register(EquipmentTableViewCell.self, forCellReuseIdentifier: EquipmentTableViewCell.reuseIdentifier)
        tableView.register(MapTableViewCell.self, forCellReuseIdentifier: MapTableViewCell.reuseIdentifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.reuseIdentifier)
        tableView.register(AllCommentTableViewCell.self, forCellReuseIdentifier: AllCommentTableViewCell.reuseIdentifier)
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        // 效能優化：預估高度減少 Auto Layout 計算
        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionHeaderHeight = 50
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func autoLayout() {
        addSubview(exhibitionImage)
        exhibitionImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.6)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        contentView.addSubview(exhibitionCardItems)
        exhibitionCardItems.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(60.0)
        }
        
        addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.width.equalTo(36.0)
            make.height.equalTo(36.0)
            make.leading.equalToSuperview().offset(16.0)
            make.top.equalToSuperview().offset(60.0)
        }
        
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(exhibitionCardItems.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(image: String, title: String) {
        titleLabel.text = title
        exhibitionImage.image = UIImage(named: image)
    }

}
