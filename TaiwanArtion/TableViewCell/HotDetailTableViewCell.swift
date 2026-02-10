//
//  HotDetailTableViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/18.
//

import UIKit
import SnapKit
import Kingfisher

class HotDetailTableViewCell: BaseTableViewCell {
    
    private let locationIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "near"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .grayTextColor
        return label
    }()
    
    private lazy var locationStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [locationIcon, cityLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }()
    
    private lazy var dateAndLoacationStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, locationStack])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 3
        return stackView
    }()
    
    //detail info
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .grayTextColor
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        label.lineBreakStrategy = .standard
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var detailStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateAndLoacationStack])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        return stackView
    }()

    private let exhibitionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.roundCorners(cornerRadius: 8)
        return imageView
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .brownTitleColor
        label.textAlignment = .center
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.roundCorners(cornerRadius: 12.0)
        return view
    }()

    override func setupCell() {
        autoLayout()
    }

    override func cleanupForReuse() {
        numberLabel.text = nil
        titleLabel.text = nil
        cityLabel.text = nil
        dateLabel.text = nil
        exhibitionImage.image = nil
    }
    
    private func autoLayout() {
        contentView.backgroundColor = .whiteGrayColor
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        containerView.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(19.0)
            make.width.equalTo(19.0)
        }
        
        containerView.addSubview(exhibitionImage)
        exhibitionImage.snp.makeConstraints { make in
            make.leading.equalTo(numberLabel.snp.trailing).offset(5)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(60.0)
            make.height.equalTo(60.0)
        }
        
        locationIcon.snp.makeConstraints { make in
            make.width.equalTo(11)
            make.height.equalTo(12)
        }
        
        containerView.addSubview(detailStack)
        detailStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(exhibitionImage.snp.height)
            make.leading.equalTo(exhibitionImage.snp.trailing).offset(5)
            make.trailing.equalToSuperview()
        }
    }

    func configure(number: String, title: String, location: String, date: String, image: String) {
        numberLabel.text = number
        titleLabel.text = title
        cityLabel.text = location
        dateLabel.text = date
        // 使用 BaseCell 的圖片載入方法
        loadImage(from: image, into: exhibitionImage)
    }
}
