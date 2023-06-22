//
//  InputTextFieldTableViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/6/15.
//

import UIKit
import RxSwift
import RxCocoa

class InputTextFieldTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "InputTextFieldTableViewCell"
    
    var inputAction: ((String) -> (Void))?

    private let disposeBag = DisposeBag()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .grayTextColor
        textField.roundCorners(cornerRadius: 12)
        textField.addBorder(borderWidth: 1, borderColor: .whiteGrayColor)
        textField.borderStyle = .roundedRect
        textField.leftViewMode = .always
        textField.rightViewMode = .whileEditing
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let leftViewContainer: UIView = {
       let view = UIView()
        return view
    }()
    
    private let rightViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .red
        label.isHidden = true
        return label
    }()
    
    private let fogetHintButton: UIButton = {
        let button = UIButton()
        button.setTitle("忘記密碼", for: .normal)
        button.setTitleColor(.brownTitleColor, for: .normal)
        button.isHidden = true
        return button
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setTextField()
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setTextField() {
        textField.delegate = self
    }
    
    private func autoLayout() {
        contentView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.height.equalTo(40.0)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(fogetHintButton)
        fogetHintButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(textField.snp.bottom)
        }
        
        contentView.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.leading.equalTo(textField.snp.leading)
            make.top.equalTo(textField.snp.bottom)
        }
        
        leftViewContainer.snp.makeConstraints { make in
            make.width.equalTo(30.0)
            make.height.equalTo(30.0)
        }
        
        rightViewContainer.snp.makeConstraints { make in
            make.width.equalTo(30.0)
            make.height.equalTo(30.0)
        }
    }
    
    func accountConfigure(placeholderText: String) {
        let personView = UIImageView(image: .init(named: "person"))
        leftViewContainer.addSubview(personView)
        personView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        textField.leftView = leftViewContainer
        textField.placeholder = placeholderText
    }
    
    func passwordConfigure(isLocked: Bool, isPrevented: Bool, placeholdText: String) {
        let lockView = UIImageView(image: .init(named: isLocked ? "redLock" : "lock"))
        let preventView = UIImageView(image: .init(named: isPrevented ? "passwordPrevent" : ""))
        leftViewContainer.addSubview(lockView)
        lockView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        rightViewContainer.addSubview(preventView)
        preventView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        textField.leftView = leftViewContainer
        textField.rightView = rightViewContainer
        textField.placeholder = placeholdText
    }
    
    func generalConfigure(placeholdText: String) {
        textField.placeholder = placeholdText
    }
}

extension InputTextFieldTableViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.inputAction?(textField.text!)
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.inputAction?(textField.text!)
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
}
