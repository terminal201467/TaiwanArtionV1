//
//  PersonalInfoView.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/6.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import SnapKit

class PersonalInfoView: UIView {
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(InputTextFieldTableViewCell.self, forCellReuseIdentifier: InputTextFieldTableViewCell.reuseIdentifier)
        tableView.register(BirthTableViewCell.self, forCellReuseIdentifier: BirthTableViewCell.reuseIdentifier)
        tableView.register(GenderTableViewCell.self, forCellReuseIdentifier: GenderTableViewCell.reuseIdentifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.reuseIdentifier)
        tableView.allowsSelection = false
        tableView.isScrollEnabled = true
        tableView.backgroundColor = .white
        tableView.setSpecificRoundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
        return tableView
    }()
    
    let dropDownContainerView: UIView = {
        let view = UIView()
        view.roundCorners(cornerRadius: 12)
        view.addBorder(borderWidth: 2, borderColor: .whiteGrayColor)
        return view
    }()
    
    let genderView: GenderView = {
        let view = GenderView()
        view.roundCorners(cornerRadius: 12)
        view.addBorder(borderWidth: 2, borderColor: .whiteGrayColor)
        view.isHidden = true
        return view
    }()
    
    let yearView: YearView = {
        let view = YearView()
        view.roundCorners(cornerRadius: 12)
        view.addBorder(borderWidth: 2, borderColor: .whiteGrayColor)
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func autoLayout() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(genderView)
        addSubview(yearView)
    }
}
