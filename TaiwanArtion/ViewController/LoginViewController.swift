//
//  LoginViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/13.
//

import UIKit
import RxSwift

enum LoginSection: Int, CaseIterable {
    case account = 0, password, loginButton, notMember
}

class LoginViewController: UIViewController {

    private let loginView = LoginView()
    
    private let viewModel = LoginViewModel()
    
    private let disposeBag = DisposeBag()
    
    var loginSuccess: (() -> Void)?
    
    override func loadView() {
        super.loadView()
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTableView()
        setLoginSuccess()
    }
    
    private func setTableView() {
        loginView.tableView.delegate = self
        loginView.tableView.dataSource = self
    }

    private func setNavigationBar() {
        title = "會員登入"
        let leftBarItem = UIBarButtonItem(image: .init(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarItem
    }
    
    private func setLoginSuccess() {
        self.viewModel.loginSuccessRelay.subscribe(onNext: { [weak self] loginSuccess in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
            self.loginSuccess?()
        })
        .disposed(by: disposeBag)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
}
extension LoginViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return LoginSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch LoginSection(rawValue: section) {
        case .account: return 1
        case .password: return 1
        case .loginButton: return 1
        case .notMember: return 1
        case .none: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch LoginSection(rawValue: section) {
        case .account: return 45
        case .password: return 45
        case .loginButton: return 45
        case .notMember: return 0
        case .none: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        let titleView = TitleHeaderView()
        containerView.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        switch LoginSection(rawValue: section) {
        case .account: titleView.configureTitle(with: "帳號")
        case .password: titleView.configureTitle(with: "密碼")
        case .loginButton: return nil
        case .notMember: return nil
        case .none: return nil
        }
        return containerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if LoginSection(rawValue: section) == .password {
            let passwordHintFooter = PasswordHintFooterView()
            passwordHintFooter.forgetAction = {
                let resetPasswordViewController = ResetPasswordViewController()
                self.navigationController?.pushViewController(resetPasswordViewController, animated: true)
            }
            return passwordHintFooter
        }
        
        if LoginSection(rawValue: section) == .notMember {
            let welcomeRegisterFooterView = WelcomeRegisterFooterView()
            return welcomeRegisterFooterView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch LoginSection(rawValue: indexPath.section) {
        case .account:
            let cell = tableView.dequeueReusableCell(withIdentifier: InputTextFieldTableViewCell.reuseIdentifier, for: indexPath) as! InputTextFieldTableViewCell
            cell.accountConfigure(placeholderText: "4-21碼小寫英文.數字")
            cell.inputAction = { inputText in
                print("註冊帳號：\(inputText)")
                self.viewModel.input.accountInput.accept(inputText)
            }
            return cell
        case .password:
            let cell = tableView.dequeueReusableCell(withIdentifier: InputTextFieldTableViewCell.reuseIdentifier, for: indexPath) as! InputTextFieldTableViewCell
            cell.passwordConfigure(isLocked: viewModel.output.isLocked.value, isPrevented: viewModel.output.isPrevented.value, placeholdText: "4-21碼小寫英文.數字")
            cell.inputAction = { inputText in
                print("註冊密碼:\(inputText)")
                self.viewModel.input.passwordInput.accept(inputText)
            }
            return cell
        case .loginButton:
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.reuseIdentifier, for: indexPath) as! ButtonTableViewCell
            //如果兩個輸入框都有輸入文字，且經過檢查，那登入鈕就會變成咖啡色
            cell.button.setTitleColor(.grayTextColor, for: .normal)
            cell.button.backgroundColor = .whiteGrayColor
//            cell.button.isEnabled = 
            cell.configure(buttonName: "登入")
            cell.action = {
                self.viewModel.input.loginActionSubject.onNext(())
            }
            return cell
        case .notMember:
            let cell = tableView.dequeueReusableCell(withIdentifier: NotMemberTableViewCell.reuseIdentifier, for: indexPath) as! NotMemberTableViewCell
            cell.forgetAction = {
                
            }
            
            cell.registerAction = {
                
            }
            return cell
        case .none: return UITableViewCell()
        }
    }
}
