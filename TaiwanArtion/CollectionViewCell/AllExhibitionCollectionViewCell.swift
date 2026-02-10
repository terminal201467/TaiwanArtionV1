//
//  AllExhibitionCollectionViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Kingfisher

class AllExhibitionCollectionViewCell: BaseCollectionViewCell {

    private var collectedOrNot: Bool = false
    
    private let exhibitionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.roundCorners(cornerRadius: 8)
        return imageView
    }()
    
    private let collectButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "collect"), for: .normal)
        return button
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let tagContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .tagYellowColor
        view.setSpecificRoundCorners(corners: [.layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 8)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.lineBreakStrategy = .standard
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .grayTextColor
        return label
    }()
    
    private let iconImage: UIImageView = {
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
        let stackView = UIStackView(arrangedSubviews: [iconImage, cityLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }()
    
    private lazy var dateStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, locationStack])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 3
        return stackView
    }()
    
    private lazy var infoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateStack])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 3
        return stackView
    }()
    
    private let stackContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    override func setupCell() {
        autoLayout()
        setCollectButton()
    }

    override func cleanupForReuse() {
        collectedOrNot = false
        collectButton.setImage(UIImage(named: "collect"), for: .normal)
        exhibitionImage.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        cityLabel.text = nil
        tagLabel.text = nil
    }
    
    private func autoLayout() {
        contentView.addSubview(exhibitionImage)
        exhibitionImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(180.0 / frame.height)
        }
        
        contentView.addSubview(tagContainerView)
        tagContainerView.snp.makeConstraints { make in
            make.leading.equalTo(exhibitionImage.snp.leading)
            make.bottom.equalTo(exhibitionImage.snp.bottom)
            make.width.equalTo(40.0)
            make.height.equalTo(24.0)
        }
        
        tagContainerView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(collectButton)
        collectButton.snp.makeConstraints { make in
            make.trailing.equalTo(exhibitionImage.snp.trailing).offset(-13)
            make.top.equalTo(exhibitionImage.snp.top).offset(13)
        }
        
        iconImage.snp.makeConstraints { make in
            make.height.equalTo(13)
            make.width.equalTo(10)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(23.0)
        }
        
        contentView.addSubview(stackContainerView)
        stackContainerView.snp.makeConstraints { make in
            make.top.equalTo(exhibitionImage.snp.bottom).offset(4.5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        stackContainerView.addSubview(infoStack)
        infoStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with exhibition: ExhibitionInfo) {
        // 使用 BaseCell 的圖片載入方法
        loadImage(from: exhibition.image, into: exhibitionImage)
        titleLabel.text = exhibition.title
        dateLabel.text = exhibition.dateString
        cityLabel.text = exhibition.location
        tagLabel.text = exhibition.tag
    }

    private func setCollectButton() {
        collectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.collectedOrNot.toggle()
                self.collected()
            })
            .disposed(by: disposeBag)
    }
    
    private func collected() {
        if collectedOrNot {
            collectButton.setImage(UIImage(named: "collectSelect"), for: .normal)
        } else {
            collectButton.setImage(UIImage(named: "collect"), for: .normal)
        }
    }
}
