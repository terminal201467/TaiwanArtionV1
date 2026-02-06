//
//  MainPhotosCollectionViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/18.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import Kingfisher

class MainPhotosCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "MainPhotosCollectionViewCell"
    
    private let disposeBag = DisposeBag()
    
    private var collectedOrNot: Bool = false
    
    private let exhibitionImage: UIImageView = {
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .grayTextColor
        label.textAlignment = .left
        return label
    }()
    
    private let collectButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "collect"), for: .normal)
        return button
    }()
    
    private let titleStackContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleInfoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    private let backgroundWhiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.roundCorners(cornerRadius: 12)
        view.applyShadow(color: .gray, opacity: 0.1, offset: CGSize(width: 0.5, height: 0.5), radius: 1)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoLayout()
        setCollectButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func autoLayout() {
        contentView.addSubview(backgroundWhiteView)
        backgroundWhiteView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundWhiteView.addSubview(exhibitionImage)
        exhibitionImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(backgroundWhiteView.snp.height).multipliedBy(0.8)
        }
        
        contentView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { make in
            make.leading.equalTo(exhibitionImage.snp.leading)
            make.bottom.equalTo(exhibitionImage.snp.bottom)
            make.height.equalToSuperview().multipliedBy(24.0 / frame.height)
            make.width.equalToSuperview().multipliedBy(40.0 / frame.width)
        }
        
        backgroundWhiteView.addSubview(titleStackContainer)
        titleStackContainer.snp.makeConstraints { make in
            make.top.equalTo(exhibitionImage.snp.bottom)
            make.leading.equalTo(exhibitionImage.snp.leading)
            make.trailing.equalTo(exhibitionImage.snp.trailing)
            make.bottom.equalToSuperview()
        }
        
        titleStackContainer.addSubview(titleInfoStack)
        titleInfoStack.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }
        
        contentView.addSubview(collectButton)
        collectButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(23.0 / frame.width)
            make.height.equalToSuperview().multipliedBy(40.0 / frame.height)
            make.trailing.equalTo(exhibitionImage.snp.trailing).offset(-10)
            make.top.equalTo(exhibitionImage.snp.top).offset(5)
        }
    }
    
    func configure(item: ExhibitionInfo) {
        // 使用統一的圖片載入方法
        exhibitionImage.loadImage(from: item.image)
        titleLabel.text = item.title
        dateLabel.text = item.dateString
        tagLabel.text = item.tag
    }
    
    private func setCollectButton() {
        collectButton.rx.tap
            .subscribe(onNext: {
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
