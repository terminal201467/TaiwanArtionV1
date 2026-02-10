//
//  NewsDetailTableViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/24.
//

import UIKit

class NewsDetailTableViewCell: BaseTableViewCell {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .grayTextColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var labelStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
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
        addSubview(labelStack)
        labelStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(56.0)
            make.height.equalTo(24.0)
        }
    }
    
    func configure(title: String, contentText: String) {
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .grayTextColor
        contentLabel.text = contentText
        contentLabel.backgroundColor = .white
        contentLabel.textColor = .grayTextColor
        contentLabel.roundCorners(cornerRadius: 0)
    }
    
    func configureWithTag(title: String, tag: String) {
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .grayTextColor
        contentLabel.text = tag
        contentLabel.backgroundColor = .tagYellowColor
        contentLabel.textColor = .white
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.roundCorners(cornerRadius: 14)
    }
    
    func  configureLocationDetail(title: String, contentText: String) {
        titleLabel.text = title
        titleLabel.textColor = .grayTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.text = contentText
        contentLabel.backgroundColor = .white
        contentLabel.textColor = .grayTextColor
        contentLabel.font = UIFont.systemFont(ofSize: 14)
    }
}
