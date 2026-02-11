//
//  SearchView.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/31.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SearchView: UIView {
    
    var backAction: (() -> Void)?
    
    var searchValueChanged: ((String) -> Void)?
    
    var isBeginSearchMode: ((Bool) -> Void)?
    
    var endInputText: ((String) -> Void)?
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Background
    
    private let leftMiddleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "leftMiddleBackground")
        return imageView
    }()
    
    //MARK: - Foreground
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        return button
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.placeholder = "搜尋展覽"
        searchBar.searchTextField.textColor = .grayTextColor
        searchBar.searchTextField.roundCorners(cornerRadius: 20)
        searchBar.searchTextField.clearButtonMode = .whileEditing
        searchBar.searchTextField.keyboardType = .emailAddress
        return searchBar
    }()
    
    let filterContentCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(SearchingCollectionViewCell.self, forCellWithReuseIdentifier: SearchingCollectionViewCell.reuseIdentifier)
        collectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = nil
        return collectionView
    }()
    
    //MARK: - Foreground
    
    private let locationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "location"), for: .normal)
        return button
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "目前所在位置"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .grayTextColor
        return label
    }()
    
    private lazy var locationStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [locationButton, locationLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()
    
    let filterTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(HotHintTableViewCell.self, forCellReuseIdentifier: HotHintTableViewCell.reuseIdentifier)
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.reuseIdentifier)
        tableView.register(UnSearchModeChooseTableViewCell.self, forCellReuseIdentifier: UnSearchModeChooseTableViewCell.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.reuseIdentifier)
        tableView.allowsSelection = false
        tableView.isScrollEnabled = true
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        // 效能優化：預估高度減少 Auto Layout 計算
        tableView.estimatedRowHeight = 100
        tableView.estimatedSectionHeaderHeight = 50
        return tableView
    }()
    
    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [locationStack, filterTableView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 20
        stackView.setSpecificRoundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
        return stackView
    }()
    
    private let backgroundWhiteView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.setSpecificRoundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackButton()
        setSearchBarBinding()
        backgroundAutoLayout()
        foregroundAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hiddenThelocationStack(isHidden: Bool) {
        locationStack.isHidden = isHidden
    }
    
    private func setBackButton() {
        backButton.rx.tap
            .subscribe(onNext: {
                self.backAction?()
            })
            .disposed(by: disposeBag)
    }
    
    private func setSearchBarBinding() {
        searchBar.searchTextField.delegate = self
        searchBar.searchTextField.rx.text
            .orEmpty
            .debounce(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] searchText in
                self?.searchValueChanged?(searchText)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - AutoLayout
    private func backgroundAutoLayout() {
        backgroundColor = .caramelColor
        addSubview(leftMiddleImage)
        leftMiddleImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(150.0)
        }
    }
    
    private func foregroundAutoLayout() {
        locationButton.snp.makeConstraints { make in
            make.height.equalTo(40.0)
            make.width.equalTo(40.0)
        }
        
        backButton.snp.makeConstraints { make in
            make.height.equalTo(36.0)
            make.width.equalTo(36.0)
        }
        
        locationStack.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(frame.width)
        }
        
        addSubview(filterContentCollectionView)
        filterContentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(8.0)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(48)
        }
        
        filterTableView.snp.makeConstraints { make in
            make.height.equalTo(400.0)
            make.width.equalTo(frame.width)
        }
        
        addSubview(backgroundWhiteView)
        backgroundWhiteView.snp.makeConstraints { make in
            make.top.equalTo(filterContentCollectionView.snp.bottom).offset(16.0)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        backgroundWhiteView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(backgroundWhiteView).offset(16.0)
            make.leading.equalToSuperview().offset(16.0)
            make.trailing.equalToSuperview().offset(-16.0)
            make.bottom.equalToSuperview()
        }
    }
}

extension SearchView: UISearchTextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.endInputText?(textField.text ?? "")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        self.isBeginSearchMode?(true)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
}
