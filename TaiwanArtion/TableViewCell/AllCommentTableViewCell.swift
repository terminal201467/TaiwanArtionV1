//
//  AllCommentTableViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/29.
//

import UIKit

class AllCommentTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "AllCommentTableViewCell"
    
    //MARK: - Intialization Consequense
    
    enum CommentType: Int, CaseIterable {
        case contentRichness = 0, equipment, geoLocation, price, serice
        var text: String {
            switch self {
            case .contentRichness: return "內容豐富度"
            case .equipment: return "設備"
            case .geoLocation: return "地理設備"
            case .price: return "價格"
            case .serice: return "服務"
            }
        }
    }
    
    var commentTypeScores: [Double] = []
    
    var averageScore: Int = 4
    
    //MARK: - UI settings
    
    private let containerBackgroundView = UIView()
    
    private let personImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.roundCorners(cornerRadius: imageView.frame.size.width / 2)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0, weight: .semibold)
        return label
    }()
    
    private let starCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(StarCollectionViewCell.self, forCellWithReuseIdentifier: StarCollectionViewCell.reuseIdentifier)
        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .grayTextColor
        return label
    }()
    
    private lazy var infoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, starCollectionView])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var personStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [personImage, infoStack])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    private let commentTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ScoreTableViewCell.self, forCellReuseIdentifier: ScoreTableViewCell.reuseIdentifier)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [personStack, commentTableView, footer])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    private let footer = LikeCommentFooter()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setTableView()
        setCollectionView()
        autoLayout()
        setFooterAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setTableView() {
        commentTableView.delegate = self
        commentTableView.dataSource = self
    }
    
    private func setCollectionView() {
        starCollectionView.dataSource = self
        starCollectionView.delegate = self
    }
    
    private func setFooterAction() {
        footer.likeAction = {
            AppLogger.debug("like", category: .ui)
        }
    }
    
    private func autoLayout() {
        contentView.addSubview(containerBackgroundView)
        containerBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        containerBackgroundView.addSubview(personStack)
        personStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(50.0)
            make.width.equalTo(150.0)
        }
        
        personImage.snp.makeConstraints { make in
            make.width.equalTo(40.0)
            make.height.equalTo(40.0)
        }
        
        starCollectionView.snp.makeConstraints { make in
            make.height.equalTo(16.0)
            make.width.equalTo(96.0)
        }
        
        containerBackgroundView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(containerBackgroundView.snp.trailing).offset(-16)
            make.centerY.equalTo(nameLabel.snp.centerY)
        }
        
        containerBackgroundView.addSubview(commentTableView)
        commentTableView.snp.makeConstraints { make in
            make.height.equalTo(180.0)
            make.top.equalTo(personStack.snp.bottom)
            make.leading.equalTo(personStack.snp.leading)
            make.trailing.equalTo(containerBackgroundView.snp.trailing).offset(-16)
        }
        containerBackgroundView.addSubview(footer)
        footer.snp.makeConstraints { make in
            make.top.equalTo(commentTableView.snp.bottom).offset(16)
            make.height.equalTo(34.0)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    func configurePersonComment(name: String, personImageText: String, starScore: Int, date: String) {
        nameLabel.text = name
        personImage.image = UIImage(named: personImageText)
        averageScore = starScore
        dateLabel.text = date
    }
    
}

extension AllCommentTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScoreTableViewCell.reuseIdentifier, for: indexPath) as! ScoreTableViewCell
        cell.configure(title: CommentType.allCases[indexPath.row].text,
                       score: commentTypeScores[indexPath.row])
        cell.scoreStack.backgroundColor = .white
        cell.selectionStyle = .none
        return cell
    }
}

extension AllCommentTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StarCollectionViewCell.reuseIdentifier, for: indexPath) as! StarCollectionViewCell
        cell.configure(isValueStar: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 16, height: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }

}
