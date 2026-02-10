//
//  NearExhibitionDetailTableViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/27.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class NearExhibitionDetailTableViewCell: BaseTableViewCell {

    var likeActionSignal: Signal<Void> = Signal.just(())

    private var isLiked: Bool = false {
        didSet {
            self.setLikeButton()
        }
    }
    
    private let contentMainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.roundCorners(cornerRadius: 8)
        return imageView
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let tagView: UIView = {
        let view = UIView()
        view.backgroundColor = .tagYellowColor
        view.setSpecificRoundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMinYCorner], radius: 8)
        return view
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(like), for: .touchDown)
        return button
    }()
    
    //MARK: -EvaluateInfo
    private let starEvaluatelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let starImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(named: "star")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let evaluateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .grayTextColor
        return label
    }()
    
    private lazy var evaluatesStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [starEvaluatelabel, starImage, evaluateLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }()
    
    //MARK: -detailInfo
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let timeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(named: "calendar")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private let locationImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(named: "locationIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private lazy var detailStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timeImage, timeLabel, locationImage, locationLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    override func setupCell() {
        autoLayout()
        setLikeButton()
    }

    override func cleanupForReuse() {
        isLiked = false
        likeButton.setImage(UIImage(named: "collect"), for: .normal)
        contentMainImage.image = nil
        tagLabel.text = nil
        titleLabel.text = nil
        timeLabel.text = nil
        locationLabel.text = nil
        starEvaluatelabel.text = nil
        evaluateLabel.text = nil
    }
    
    private func autoLayout() {
        contentView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(12.0)
            make.leading.equalTo(12.0)
            make.trailing.equalTo(-12.0)
            make.bottom.equalTo(-12.0)
            make.height.equalTo(260.0)
        }
        //圖片
        containerView.addSubview(contentMainImage)
        contentMainImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(180.0)
        }
        
        contentMainImage.addSubview(tagView)
        tagView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(40.0)
            make.height.equalTo(24.0)
        }
        
        tagView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
            make.top.equalTo(containerView.snp.top).offset(16)
            make.height.equalTo(30.0)
            make.width.equalTo(30.0)
        }
        
        //title
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentMainImage.snp.leading)
            make.top.equalTo(contentMainImage.snp.bottom).offset(6.5)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        //評價
        containerView.addSubview(evaluatesStack)
        evaluatesStack.snp.makeConstraints { make in
            make.trailing.equalTo(contentMainImage.snp.trailing)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(42.0)
        }
        
        //詳細內容
        timeImage.snp.makeConstraints { make in
            make.height.equalTo(24.0)
            make.width.equalTo(24.0)
        }
        
        locationImage.snp.makeConstraints { make in
            make.height.equalTo(24.0)
            make.width.equalTo(24.0)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(42.0)
        }
        
        containerView.addSubview(detailStack)
        detailStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6.5)
            make.leading.equalTo(contentMainImage.snp.leading)
            make.trailing.equalTo(contentMainImage.snp.trailing)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc private func like() {
        self.isLiked.toggle()
        self.setLikeButton()
    }

    private func setLikeButton() {
        likeButton.setImage(.init(named: isLiked ? "collectSelect": "collect"), for: .normal)
    }
    
    //評價
    func evaluateConfigure(with info: ExhibitionInfo) {
        starEvaluatelabel.text = "\(String(describing: info.evaluation?.allCommentStar))"
        evaluateLabel.text = "(\(String(describing: info.evaluation?.allCommentCount)))"
    }
    
    //細節內容
    func detailConfigure(with info: ExhibitionInfo) {
        // 使用 BaseCell 的圖片載入方法
        loadImage(from: info.image, into: contentMainImage)
        titleLabel.text = info.title
        timeLabel.text = info.dateString
        tagLabel.text = info.tag
        locationLabel.text = info.location
    }
}
