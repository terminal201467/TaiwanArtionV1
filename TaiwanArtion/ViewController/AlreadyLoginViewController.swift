//
//  AlreadyLoginViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/17.
//

import UIKit

enum AlreadyLoginCell: Int, CaseIterable {
    case editPersonInfo = 0, habbySetting, accountSetting, appEvaluation
    var title: String {
        switch self {
        case .editPersonInfo: return "編輯個人檔案"
        case .habbySetting: return "興趣設定"
        case .accountSetting: return "帳號設定"
        case .appEvaluation: return "APP評分"
        }
    }
    
    var logo: String {
        switch self {
        case .editPersonInfo: return "editPerson"
        case .habbySetting: return "habbySetting"
        case .accountSetting: return "accountSetting"
        case .appEvaluation: return "appEvaluation"
        }
    }
}

class AlreadyLoginViewController: UIViewController {
    
    private let alreadyLoginView = AlreadyLoginView()
    
    override func loadView() {
        super.loadView()
        view = alreadyLoginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        setNavigationBar()
    }
    
    private func setNavigationBar() {
        title = "個人檔案"
        let backButton = UIBarButtonItem(image: .init(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    private func setTable() {
        alreadyLoginView.tableView.delegate = self
        alreadyLoginView.tableView.dataSource = self
    }
    
    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }
}

extension AlreadyLoginViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AlreadyLoginCell.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UITableViewCell
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .white
        cell.imageView?.image = .init(named: AlreadyLoginCell.allCases[indexPath.row].logo)
        cell.textLabel?.text = AlreadyLoginCell.allCases[indexPath.row].title
        cell.textLabel?.textColor = .black
        cell.accessoryView = UIImageView.init(image: .init(named: "rightArrow"))
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch AlreadyLoginCell(rawValue: indexPath.row) {
        case .editPersonInfo:
            let viewController = PersonalInfoViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        case .habbySetting:
            //推向HabbyController
            AppLogger.debug("habbySetting", category: .ui)
        case .accountSetting:
            //推向
            let viewController = AccountSettingViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        case .appEvaluation:
            //評價
            AppLogger.debug("appEvaluation", category: .ui)
        case .none: AppLogger.debug("none", category: .ui)
        }
    }
}
