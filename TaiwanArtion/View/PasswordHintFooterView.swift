//
//  PasswordHintFooterView.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/25.
//

import UIKit
import RxSwift
import RxCocoa

class PasswordHintFooterView: UIView {
    
    private let disposeBag = DisposeBag()
    
    var forgetAction: (() -> Void)?

    private let passwordHintLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .red
        return label
    }()
    
    let forgetpasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("忘記密碼？", for: .normal)
        button.setTitleColor(.brownTitleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoLayout()
        setButtonSubscribe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func autoLayout() {
        addSubview(passwordHintLabel)
        passwordHintLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        addSubview(forgetpasswordButton)
        forgetpasswordButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(hint: String) {
        passwordHintLabel.text = hint
    }
    
    private func setButtonSubscribe() {
        forgetpasswordButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.forgetAction?()
            })
            .disposed(by: disposeBag)
    }
}
