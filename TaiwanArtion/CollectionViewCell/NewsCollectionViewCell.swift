//
//  NewsCollectionViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/24.
//

import UIKit
import Kingfisher

class NewsCollectionViewCell: BaseCollectionViewCell {
    
    private let mainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.roundCorners(cornerRadius: 8)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakStrategy = .standard
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .grayTextColor
        label.textAlignment = .left
        return label
    }()
    
    private lazy var labelStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    override func setupCell() {
        autoLayout()
    }

    override func cleanupForReuse() {
        mainImage.image = nil
        titleLabel.text = nil
        subTitleLabel.text = nil
    }
    
    private func autoLayout() {
        contentView.addSubview(mainImage)
        mainImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(150.0 / contentView.frame.height)
        }
        
        contentView.addSubview(labelStack)
        labelStack.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom)
            make.leading.equalTo(mainImage.snp.leading)
            make.trailing.equalTo(mainImage.snp.trailing)
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(image: String, title: String, date: String, author: String) {
        // 使用 BaseCell 的圖片載入方法
        loadImage(from: image, into: mainImage)
        titleLabel.text = title
        subTitleLabel.text = "\(date)|\(author)"
    }
}
