//
//  NotifyTableViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/6/1.
//

import UIKit
import SnapKit

class NotifyTableViewCell: BaseTableViewCell {

    private let backgroundWhiteGrayView: UIView = {
        let view = UIView()
        view.backgroundColor = .whiteGrayColor
        view.roundCorners(cornerRadius: 8)

        return view
    }()

    private let exhibitionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.roundCorners(cornerRadius: 8)
        return imageView
    }()
    
    private let redDotImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "redDot")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .grayTextColor
        return label
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
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "near")
        return imageView
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .grayTextColor
        return label
    }()
    
    let beforeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .grayTextColor
        return label
    }()
    
    lazy var locationStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImage, locationLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 3
        return stackView
    }()
    
    private lazy var dateLocationStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, locationStack])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 3
        return stackView
    }()
    
    private lazy var infoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateLocationStack])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func autoLayout() {
        contentView.backgroundColor = .white
        contentView.addSubview(backgroundWhiteGrayView)
        backgroundWhiteGrayView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }

        backgroundWhiteGrayView.addSubview(exhibitionImage)
        backgroundWhiteGrayView.addSubview(infoStack)
        backgroundWhiteGrayView.addSubview(beforeLabel)
        
        exhibitionImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(80.0)
            make.height.equalTo(80.0)
        }
        
        contentView.addSubview(redDotImage)
        redDotImage.snp.makeConstraints { make in
            make.centerY.equalTo(exhibitionImage.snp.top)
            make.centerX.equalTo(exhibitionImage.snp.leading)
            make.width.equalTo(8.0)
            make.height.equalTo(8.0)
        }
        
        iconImage.snp.makeConstraints { make in
            make.height.equalTo(12.0)
            make.width.equalTo(12.0)
        }
        
        infoStack.snp.makeConstraints { make in
            make.leading.equalTo(exhibitionImage.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        beforeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        
        exhibitionImage.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { make in
            make.leading.equalTo(exhibitionImage.snp.leading)
            make.bottom.equalTo(exhibitionImage.snp.bottom)
            make.height.equalTo(24.0)
            make.width.equalTo(40.0)
        }
    }
    
    func configure(image: String, title: String, date: String, location: String, dayBefore: Int, tag: String) {
        exhibitionImage.image = UIImage(named: image)
        titleLabel.text = title
        dateLabel.text = date
        locationLabel.text = location
        beforeLabel.text = "\(dayBefore)天前"
        tagLabel.text = tag
    }
    
    func isRead(isOn: Bool) {
        redDotImage.isHidden = isOn
    }
}
