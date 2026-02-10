//
//  ButtonCollectionViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/6/3.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class ButtonCollectionViewCell: BaseCollectionViewCell {

    private var isImage: Bool = true

    var action: (() -> Void)?

    private let button: UIButton = {
        let button = UIButton()
        return button
    }()

    override func setupCell() {
        setButton()
        imageAutoLayout()
    }

    override func cleanupForReuse() {
        button.setImage(nil, for: .normal)
        button.setTitle(nil, for: .normal)
        button.backgroundColor = nil
        action = nil
        isImage = true
    }

    private func imageAutoLayout() {
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    private func roundButtonAutoLayout() {
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(40.0)
        }
    }

    private func setButton() {
        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.action?()
            })
            .disposed(by: disposeBag)
    }

    func configure(iconText: String) {
        button.setImage(UIImage(named: iconText), for: .normal)
    }

    func configureRoundButton(isAllowToTap: Bool, buttonTitle: String) {
        roundButtonAutoLayout()
        button.roundCorners(cornerRadius: 20)
        button.setTitle(buttonTitle, for: .normal)
        button.setTitleColor(isAllowToTap ? .white : .grayTextColor, for: .normal)
        button.backgroundColor = isAllowToTap ? .brownColor : .whiteGrayColor
    }
}
