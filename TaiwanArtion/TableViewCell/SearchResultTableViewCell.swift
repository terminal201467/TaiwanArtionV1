//
//  SearchResultTableViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/6/4.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultTableViewCell: BaseTableViewCell {

    var collectAction: (() -> Void)?
    
    //MARK: - Images
    private let mainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.roundCorners(cornerRadius: 8)
        return imageView
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = .tagYellowColor
        label.textAlignment = .center
        label.setSpecificRoundCorners(corners: [.layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 8)
        return label
    }()
    
    private let collectButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "collect"), for: .normal)
        return button
    }()
    
    //MARK: - InfoStack
    
    private let calendarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "calendar")
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .grayTextColor
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .grayTextColor
        return label
    }()
    
    private let locationImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "location")
        return imageView
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .grayTextColor
        return label
    }()
    
    private lazy var infoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calendarImage,dateLabel,locationImage, cityLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var titleInfoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, infoStack])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        return stackView
    }()
    
    //MARK: - StarStack
    private let starCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let starImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "star")
        return imageView
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var commentsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [starCountLabel, starImage, commentLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        return stackView
    }()
    
    override func setupCell() {
        autoLayout()
        setCollectButton()
    }

    override func cleanupForReuse() {
        mainImage.image = nil
        tagLabel.text = nil
        titleLabel.text = nil
        dateLabel.text = nil
        cityLabel.text = nil
        starCountLabel.text = nil
        commentLabel.text = nil
        collectButton.setImage(UIImage(named: "collect"), for: .normal)
        collectAction = nil
    }
    
    private func autoLayout() {
        contentView.addSubview(mainImage)
        mainImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16.0)
            make.leading.equalToSuperview().offset(16.0)
            make.trailing.equalToSuperview().offset(-16.0)
        }
        
        contentView.addSubview(collectButton)
        collectButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }
        
        contentView.addSubview(titleInfoStack)
        titleInfoStack.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom)
            make.leading.equalTo(mainImage.snp.leading)
        }
        
        contentView.addSubview(commentsStack)
        commentsStack.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        contentView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { make in
            make.leading.equalTo(mainImage.snp.leading)
            make.bottom.equalTo(mainImage.snp.bottom)
            make.height.equalToSuperview().multipliedBy(24.0 / frame.height)
            make.width.equalToSuperview().multipliedBy(40.0 / frame.width)
        }
        
        calendarImage.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(24)
        }
        
        locationImage.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        starImage.snp.makeConstraints { make in
            make.height.equalTo(16.0)
            make.width.equalTo(16.0)
        }
        
    }
    
    func configure(image: String, tag: String, title: String, date: String, city: String, starCount: Int, commentCount: Int) {
        mainImage.image = UIImage(named: image)
        tagLabel.text = tag
        titleLabel.text = title
        dateLabel.text = date
        cityLabel.text = city
        starCountLabel.text = "\(starCount)"
        commentLabel.text = "(\(commentCount))"
    }
    
    func configureCollectButtonSelected(isSelected: Bool) {
        collectButton.setImage(UIImage(named: isSelected ? "collectSelected" : "collect"), for: .normal)
    }
    
    private func setCollectButton() {
        collectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.collectAction?()
            })
            .disposed(by: disposeBag)
    }
}
