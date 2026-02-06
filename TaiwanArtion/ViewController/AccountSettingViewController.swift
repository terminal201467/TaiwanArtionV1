//
//  AccountSettingViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/18.
//

import UIKit

enum AccountSettingCell: Int, CaseIterable {
    case facebook = 0, google, line, twitter, password
    var title: String {
        switch self {
        case .facebook: return "Facebook帳號設定"
        case .google: return "Google帳號設定"
        case .line: return "Line帳號設定"
        case .twitter: return "Twitter帳號設定"
        case .password: return "密碼"
        }
    }
    var logo: String {
        switch self {
        case .facebook: return "facebookLittleIcon"
        case .google: return "googleLittleIcon"
        case .line: return "lineLittleIcon"
        case .twitter: return "twitterLittleIcon"
        case .password: return "lock"
        }
    }
    var acceccoryViewSetting: String {
        switch self {
        case .facebook: return "rightArrow"
        case .google: return "rightArrow"
        case .line: return "rightArrow"
        case .twitter: return "rightArrow"
        case .password: return "修改密碼"
        }
    }
}

class AccountSettingViewController: UIViewController {
    
    private let accountSettingView = AccountSettingView()

    override func loadView() {
        super.loadView()
        view = accountSettingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigatioinBar()
        setTableView()
    }
    
    private func setNavigatioinBar() {
        title = "帳號設定"
        let leftButton = UIBarButtonItem(image: .init(named: "back")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = leftButton
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setTableView() {
        accountSettingView.tableView.delegate = self
        accountSettingView.tableView.dataSource = self
    }
}

extension AccountSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AccountSettingCell.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UITableViewCell
        cell.selectionStyle = .none
        cell.backgroundColor = .white
        cell.imageView?.image = UIImage(named: AccountSettingCell.allCases[indexPath.row].logo)
        cell.textLabel?.text = AccountSettingCell.allCases[indexPath.row].title
        cell.textLabel?.textColor = .black
        if AccountSettingCell(rawValue: indexPath.row) == .password {
            let label: UILabel = {
                let label = UILabel()
                label.text = AccountSettingCell.password.acceccoryViewSetting
                label.textColor = .grayTextColor
                return label
            }()
            cell.contentView.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(-16)
            }
        } else {
            cell.accessoryView = UIImageView.init(image: .init(named: "rightArrow"))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch AccountSettingCell(rawValue: indexPath.row) {
        case .facebook:
            AppLogger.debug("facebook", category: .ui)
        case .google:
            AppLogger.debug("google", category: .ui)
        case .line:
            AppLogger.debug("line", category: .ui)
        case .twitter:
            AppLogger.debug("twitter", category: .ui)
        case .password:
            let viewController = ResetPasswordViewController()
            navigationController?.pushViewController(viewController, animated: true)
        case .none:
            AppLogger.debug("none", category: .ui)
        }
    }
}
