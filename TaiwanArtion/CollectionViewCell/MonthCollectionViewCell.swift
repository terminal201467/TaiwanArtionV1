//
//  MonthCollectionViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import UIKit

class MonthCollectionViewCell: BaseCollectionViewCell {

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private let englishMonthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    private lazy var monthStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [monthLabel, englishMonthLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }()

    override func setupCell() {
        autoLayout()
    }

    override func cleanupForReuse() {
        monthLabel.text = nil
        englishMonthLabel.text = nil
        monthStack.backgroundColor = .white
        monthLabel.textColor = .brownTitleColor
        englishMonthLabel.textColor = .grayTextColor
    }

    private func autoLayout() {
        addSubview(monthStack)
        monthStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        monthStack.roundCorners(cornerRadius: 4)
    }

    func configureLabel(month: Month, selected: Bool) {
        monthLabel.text = "\(month.numberText)月"
        englishMonthLabel.text = month.englishText
        selected ? configureSelectedMonthStack() : configureMonthStack()
    }

    //一般模式
    private func configureMonthStack() {
        monthStack.backgroundColor = .white
        monthLabel.textColor = .brownTitleColor
        englishMonthLabel.textColor = .grayTextColor
    }

    //點按模式
    private func configureSelectedMonthStack() {
        monthStack.backgroundColor = .brownTitleColor
        monthLabel.textColor = .white
        englishMonthLabel.textColor = .white
    }
}
