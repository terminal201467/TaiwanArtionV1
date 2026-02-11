//
//  NearView.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/17.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import MapKit

enum NearViewSelectedItem: Int, CaseIterable {
    case nearExhibitionHall = 0, nearExhibition
    var text: String {
        switch self {
        case .nearExhibitionHall: return "附近展覽館"
        case .nearExhibition: return "附近展覽"
        }
    }
}

class NearView: UIView {
    
    private let disposeBag = DisposeBag()
    
    let filterSubject: PublishSubject<Void> = PublishSubject()
    
    var isHadSearchResult: Bool = true {
        didSet {
//            setContainerLayout()
        }
    }
    
    var currentIndex: ((Int) -> Void)?
    
    private var currentNearSelectedItem: NearViewSelectedItem = .nearExhibitionHall {
        didSet {
            self.setSelectedItemViewLayout()
            self.collectionView.reloadData()
        }
    }
    
    var searchText: String = ""
    
    var filterButtonIsSelected: Bool = false {
        didSet {
            setFilterButton()
        }
    }
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(SelectedItemsCollectionViewCell.self, forCellWithReuseIdentifier: SelectedItemsCollectionViewCell.reuseIdentifier)
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private let menuBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let containerView: UIView = {
       let view = UIView()
        return view
    }()
    
    private let nothingSearchedView = NothingSearchedView(frame: .zero, type: .nothingFoundInNear)
    
    let exhibitionMapView = ExhibitionMapView()
    
    private let exhibitionDetailView = NearExhibitionDetailView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setCollectionView()
        setButtonSubscription()
        setFilterButton()
        autoLayout()
        setNothingSearch()
        setSelectedItemViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setNothingSearch() {
        nothingSearchedView.keyword = searchText
    }
    
    private func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setButtonSubscription() {
        filterButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.filterButtonIsSelected.toggle()
                self.filterSubject.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    private func setFilterButton() {
        filterButton.setImage(.init(named: filterButtonIsSelected ? "selectedFilter" : "filter"), for: .normal)
    }
    
    private func autoLayout() {
        addSubview(menuBarView)
        menuBarView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.height.equalTo(68.0)
        }
        
        menuBarView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        menuBarView.addSubview(filterButton)
        filterButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(36.0)
            make.width.equalTo(36.0)
        }
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(menuBarView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    //地圖搜尋模式
    private func setFindExhibitionContainerLayout() {
        containerView.removeAllSubviews(from: containerView)
        if isHadSearchResult {
            containerView.addSubview(exhibitionMapView)
            exhibitionMapView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            containerView.addSubview(nothingSearchedView)
            nothingSearchedView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    //附近展覽搜尋模式
    private func setExhibitionDetailViewLayout() {
        containerView.addSubview(exhibitionDetailView)
        exhibitionDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //附近展覽篩選
    private func setSelectedItemViewLayout() {
        switch currentNearSelectedItem {
        case .nearExhibitionHall: setFindExhibitionContainerLayout()
        case .nearExhibition: setExhibitionDetailViewLayout()
        }
    }
}

//MARK: -CollectionView Methods
extension NearView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NearViewSelectedItem.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedItemsCollectionViewCell.reuseIdentifier, for: indexPath) as! SelectedItemsCollectionViewCell
        let isSelected = currentNearSelectedItem == NearViewSelectedItem(rawValue: indexPath.row)
        cell.configure(with: NearViewSelectedItem.allCases[indexPath.row].text, selected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentNearSelectedItem = NearViewSelectedItem(rawValue: indexPath.row)!
        currentIndex?(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 24, bottom: 16, right: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellwidth = (collectionView.frame.width - 24 * 2 - 16) / 2
        let cellHeight = 34.0
        return .init(width: cellwidth, height: cellHeight)
    }
}
