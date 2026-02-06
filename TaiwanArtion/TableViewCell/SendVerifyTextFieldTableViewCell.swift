//
//  SendVerifyTextFieledTableViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/6/15.
//

import UIKit
import RxSwift
import RxCocoa

class SendVerifyTextFieldTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "SendVerifyTextFieldTableViewCell"
    
    private let disposeBag = DisposeBag()
    
    var sendAction: (() -> (Void))?
    
    var inputAction: ((String) -> (Void))?
    
    var timeTickAction: ((TimeInterval) -> (Void))?
    
    private var isSend: Bool = false
    
    private let timer = CountdownTimer(timeInterval: 60)

    private let textField: UITextField = {
        let textField = UITextField()
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "請輸入手機號碼", attributes: placeholderAttributes)
        textField.textColor = .grayTextColor
        textField.roundCorners(cornerRadius: 12)
        textField.borderStyle = .roundedRect
        textField.addBorder(borderWidth: 1, borderColor: .whiteGrayColor)
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .white
        return textField
    }()
    
    let sendVerifyButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.roundCorners(cornerRadius: 12)
        button.setTitle("發送驗證碼", for: .normal)
        button.backgroundColor = .brownColor
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = true
        return button
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .red
        label.isHidden = true
        return label
    }()
    
    private lazy var inputerStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, sendVerifyButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.delegate = self
        setSubscribeButton()
        autoLayout()
        setTime()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubscribeButton() {
        sendVerifyButton.rx.tap
            .subscribe(onNext: {
                self.sendAction?()
                self.timer.start()
                self.isSend = true
                //對Firebase送出簡訊申請
            })
            .disposed(by: disposeBag)
    }
    
    private func setTime() {
        if timer.timeRemaining == 0.0 {
            isSend = false
        }
        
        timer.onTick = { second in
            AppLogger.debug("second:\(second)", category: .ui)
            self.timeTickAction?(second)
        }
    }
    
    func stopTimer() {
        timer.stop()
    }

    private func autoLayout() {
        contentView.backgroundColor = .white
        contentView.addSubview(inputerStack)
        inputerStack.snp.makeConstraints { make in
            make.height.equalTo(40.0)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.65)
            make.height.equalTo(40.0)
        }
        
        sendVerifyButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(40.0)
        }
        
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom)
            make.leading.equalTo(textField.snp.leading)
        }
    }
    
    func configure(placeHolder: String) {
        textField.placeholder = placeHolder
    }
    
    func setSendButton(timeRemaining: TimeInterval) {
        sendVerifyButton.backgroundColor = .whiteGrayColor
        sendVerifyButton.setTitle("\(timeRemaining)s,重新發送", for: .normal)
        sendVerifyButton.setTitleColor(.grayTextColor, for: .normal)
        sendVerifyButton.isEnabled = false
    }
}

extension SendVerifyTextFieldTableViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.inputAction?(textField.text ?? "")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
}
