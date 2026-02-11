//
//  TitleMonthCollectionViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/13.
//

import UIKit
import RxSwift

class TitleMonthCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "TitleMonthCollectionViewCell"
    
    private let disposeBag = DisposeBag()
    
    var changedTitleMonth: (() -> Void)?
    
    private var currentTitleMonth: String? {
        didSet {
            changedTitleMonth?()
            titleBarItem.title = currentTitleMonth
        }
    }
    
    var nextMonthAction: (() -> Void)?
    
    var preMonthAction: (() -> Void)?
    
    private let titleBarItem = UIBarButtonItem(title: nil, style: .plain, target: TitleMonthCollectionViewCell.self, action: nil)
    
    private let rightArrowButton = UIBarButtonItem(image: .init(named: "rightArrow")?.withRenderingMode(.alwaysOriginal), style: .plain, target: TitleMonthCollectionViewCell.self, action: nil)
    
    private let leftArrowButton = UIBarButtonItem(image: .init(named: "leftArrow")?.withRenderingMode(.alwaysOriginal), style: .plain, target: TitleMonthCollectionViewCell.self, action: nil)

    private lazy var monthTitleBar: UIToolbar = {
        titleBarItem.tintColor = .brownTitleColor
        let toolBar = UIToolbar()
        toolBar.barTintColor = .white
        toolBar.backgroundColor = .white
        toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolBar.items = [leftArrowButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), titleBarItem, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), rightArrowButton]
        return toolBar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoLayout()
        setButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setButtonAction() {
        rightArrowButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.nextMonthAction?()
            })
            .disposed(by: disposeBag)

        leftArrowButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.preMonthAction?()
            })
            .disposed(by: disposeBag)
    }
    
    private func autoLayout() {
        contentView.addSubview(monthTitleBar)
        monthTitleBar.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(currenMonth: Month) {
        currentTitleMonth = "\(currenMonth.numberText)" + "月" + "\(currenMonth.englishText)"
        AppLogger.debug("currentTitleMonth:\(currentTitleMonth!)", category: .ui)
    }
}
