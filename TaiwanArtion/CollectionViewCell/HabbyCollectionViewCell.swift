//
//  HabbyCollectionViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import UIKit
import SnapKit

class HabbyCollectionViewCell: BaseCollectionViewCell {

    private let habbyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let habbyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .grayTextColor
        return label
    }()

    private lazy var habbyStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [habbyImage, habbyLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 0
        return stackView
    }()

    private let habbyStackContainer: UIView = {
        let view = UIView()
        view.roundCorners(cornerRadius: 10)
        return view
    }()

    override func setupCell() {
        autoLayout()
    }

    override func cleanupForReuse() {
        habbyImage.image = nil
        habbyLabel.text = nil
        habbyStackContainer.backgroundColor = nil
        habbyStackContainer.layer.borderWidth = 0
        habbyImage.tintColor = nil
        habbyLabel.textColor = .grayTextColor
    }

    private func autoLayout() {
        contentView.addSubview(habbyStackContainer)
        habbyStackContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        habbyLabel.snp.makeConstraints { make in
            make.height.equalTo(20.0)
            make.width.equalTo(45.0)
        }

        habbyImage.snp.makeConstraints { make in
            make.width.equalTo(25.0)
            make.height.equalTo(25.0)
        }

        habbyStackContainer.addSubview(habbyStack)
        habbyStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    func configureImageAndLabel(by item: HabbyItem) {
        habbyImage.image = UIImage(named: item.imageText)
        habbyLabel.text = item.habbyTitleText
        habbyStackContainer.backgroundColor = .white
    }

    func configureHabby(by item: HabbyItem, isSelected: Bool) {
        habbyLabel.text = item.habbyTitleText
        configureItem(by: item, selected: isSelected)
        handleSelectedItemView(by: isSelected)
    }

    func handleSelectedItemView(by selected: Bool) {
        if selected {
            habbyStackContainer.addBorder(borderWidth: 2, borderColor: .brownColor)
            habbyImage.tintColor = .brownColor
            habbyLabel.textColor = .brownColor
        } else {
            habbyStackContainer.addBorder(borderWidth: 0, borderColor: .tintColor)
            habbyImage.tintColor = .middleGrayColor
            habbyLabel.textColor = .middleGrayColor
        }
    }

    func configureHabbyWithoutBorder(by item: HabbyItem, isSelected: Bool) {
        habbyLabel.text = item.habbyTitleText
        configureItem(by: item, selected: isSelected)
    }

    private func configureItem(by item: HabbyItem, selected: Bool) {
        if selected {
            habbyImage.image = UIImage(named: item.homeHabbyImageText + "Selected")
        } else {
            habbyImage.image = UIImage(named: item.homeHabbyImageText)
        }
    }
}
